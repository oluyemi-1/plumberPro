import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/reminder_data.dart';
import 'diagnostics_service.dart';
import 'notifications_service.dart';

/// Singleton CRUD store for service follow-up reminders. Each reminder also
/// schedules an OS-level notification on its due date (at 9am local time)
/// via [NotificationsService] — that way the user gets pinged even if they
/// haven't opened the app in months.
class ReminderService extends ChangeNotifier {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const _kKey = 'reminders_v1';

  /// Default time-of-day for the follow-up notification.
  static const int _notifyHour = 9;
  static const int _notifyMinute = 0;

  final List<ServiceReminder> _items = [];
  bool _loaded = false;

  /// Sorted by due date, soonest first.
  List<ServiceReminder> get items => List.unmodifiable(_items);
  bool get loaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _items.addAll(decodeReminders(prefs.getString(_kKey)));
    _sort();
    _loaded = true;
    notifyListeners();
    // Re-arm OS-level notifications in the background. This is the only
    // place where reminders loaded from disk get their alarms back, so it
    // covers app reinstall, backup restore, OS battery-saver clearing the
    // schedule, or the user simply not opening the app for a while.
    unawaited(_rearmAll());
  }

  /// Re-schedule every open reminder. Safe to call multiple times — the
  /// underlying `zonedSchedule` replaces an existing entry with the same id,
  /// so we don't end up with duplicate alarms.
  Future<void> _rearmAll() async {
    for (final r in List<ServiceReminder>.from(_items)) {
      if (r.completed) continue;
      try {
        await _scheduleNotification(r);
      } catch (e, st) {
        DiagnosticsService.instance.warning(
          'ReminderService',
          'Re-arm failed for reminder ${r.id} (${r.customerName}).',
          '$e\n$st',
        );
      }
    }
  }

  Future<void> reload() async {
    _items.clear();
    _loaded = false;
    await ensureLoaded();
  }

  void _sort() {
    _items.sort((a, b) {
      // Open ones first, by due date ascending; then completed at the end.
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      return a.dueDate.compareTo(b.dueDate);
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, encodeReminders(_items));
  }

  ServiceReminder? findById(String id) {
    for (final r in _items) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Open reminders due within [window] from now (default 30 days).
  List<ServiceReminder> dueSoon({Duration window = const Duration(days: 30)}) {
    final now = DateTime.now();
    return _items
        .where((r) =>
            !r.completed &&
            !r.isOverdue(now: now) &&
            r.isDueWithin(window, now: now))
        .toList();
  }

  List<ServiceReminder> overdue() {
    final now = DateTime.now();
    return _items.where((r) => r.isOverdue(now: now)).toList();
  }

  List<ServiceReminder> later({Duration window = const Duration(days: 30)}) {
    final now = DateTime.now();
    return _items
        .where((r) =>
            !r.completed &&
            !r.isOverdue(now: now) &&
            !r.isDueWithin(window, now: now))
        .toList();
  }

  /// Count of items needing the user's attention now (overdue + due soon).
  int get attentionCount {
    final now = DateTime.now();
    return _items
        .where((r) =>
            !r.completed &&
            (r.isOverdue(now: now) ||
                r.isDueWithin(const Duration(days: 30), now: now)))
        .length;
  }

  Future<ServiceReminder> add(ServiceReminder r) async {
    _items.add(r);
    _sort();
    await _save();
    await _scheduleNotification(r);
    notifyListeners();
    return r;
  }

  Future<void> update(ServiceReminder r) async {
    final i = _items.indexWhere((x) => x.id == r.id);
    if (i == -1) return;
    final prev = _items[i];
    _items[i] = r;
    _sort();
    await _save();
    // Re-schedule whenever the due date or completion state changes.
    if (prev.dueDate != r.dueDate || prev.completed != r.completed) {
      await NotificationsService.instance.cancelOneOff(r.notificationId);
      if (!r.completed) {
        await _scheduleNotification(r);
      }
    }
    notifyListeners();
  }

  Future<void> markDone(String id) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i == -1) return;
    final r = _items[i];
    _items[i] = r.copyWith(completed: true, completedAt: DateTime.now());
    _sort();
    await _save();
    await NotificationsService.instance.cancelOneOff(r.notificationId);
    notifyListeners();
  }

  Future<void> reopen(String id) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i == -1) return;
    final r = _items[i];
    _items[i] = r.copyWith(clearCompleted: true);
    _sort();
    await _save();
    await _scheduleNotification(_items[i]);
    notifyListeners();
  }

  Future<void> snooze(String id, Duration by) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i == -1) return;
    final r = _items[i];
    final newDue = r.dueDate.add(by);
    _items[i] = r.copyWith(dueDate: newDue);
    _sort();
    await _save();
    await NotificationsService.instance.cancelOneOff(r.notificationId);
    await _scheduleNotification(_items[i]);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i == -1) return;
    final r = _items[i];
    _items.removeAt(i);
    await _save();
    await NotificationsService.instance.cancelOneOff(r.notificationId);
    notifyListeners();
  }

  Future<void> _scheduleNotification(ServiceReminder r) async {
    if (r.completed) return;
    final when = DateTime(
      r.dueDate.year,
      r.dueDate.month,
      r.dueDate.day,
      _notifyHour,
      _notifyMinute,
    );
    final body = r.customerName.isEmpty
        ? r.description
        : '${r.customerName}: ${r.description}';
    await NotificationsService.instance.scheduleOneOff(
      id: r.notificationId,
      title: 'Service follow-up due',
      body: body,
      when: when,
    );
  }
}
