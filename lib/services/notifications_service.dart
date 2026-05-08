import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'diagnostics_service.dart';
import 'progress_service.dart';

/// Singleton wrapper around `flutter_local_notifications` that schedules a
/// once-a-day study reminder. The user can enable/disable it and pick the
/// time of day from the settings screen.
///
/// Android scheduling uses `inexactAllowWhileIdle` so we don't need the
/// SCHEDULE_EXACT_ALARM permission. The reminder fires within a few minutes
/// of the chosen time — close enough for "your daily plumbing prompt."
class NotificationsService extends ChangeNotifier {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  static const _kEnabled = 'reminder_enabled_v1';
  static const _kHour = 'reminder_hour_v1';
  static const _kMinute = 'reminder_minute_v1';

  static const int _notificationId = 1001;
  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily reminder';
  static const String _channelDescription =
      'Once-a-day prompt to keep your plumbing study streak going.';

  static const String _serviceChannelId = 'service_reminder';
  static const String _serviceChannelName = 'Service follow-ups';
  static const String _serviceChannelDescription =
      'One-off notifications for upcoming customer service due dates.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialised = false;
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 0);
  bool _supported = true;

  bool get enabled => _enabled;
  TimeOfDay get time => _time;
  bool get supported => _supported;

  Future<void> ensureInitialised() async {
    if (_initialised) return;
    _initialised = true;

    // Notifications only exist on Android / iOS in this app — desktop /
    // web are no-ops so we can short-circuit those builds.
    _supported = _isMobilePlatform;

    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_kEnabled) ?? false;
    _time = TimeOfDay(
      hour: prefs.getInt(_kHour) ?? 7,
      minute: prefs.getInt(_kMinute) ?? 0,
    );

    if (!_supported) {
      notifyListeners();
      return;
    }

    try {
      tzdata.initializeTimeZones();
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (e, st) {
      DiagnosticsService.instance.warning(
        'NotificationsService',
        'Timezone init failed — daily reminder may fire at unexpected times.',
        '$e\n$st',
      );
    }

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    try {
      await _plugin.initialize(initSettings);
    } catch (e, st) {
      DiagnosticsService.instance.error(
        'NotificationsService',
        'Plugin initialize failed — notifications disabled this session.',
        '$e\n$st',
      );
      _supported = false;
    }

    // Re-arm the schedule on every app launch so the next firing has the
    // freshest "today" context, even if the OS rebooted.
    if (_supported && _enabled) {
      await _scheduleNext();
    }
    notifyListeners();
  }

  bool get _isMobilePlatform {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if permission is now granted (or already was). On older
  /// Android versions and desktop builds this is a no-op that returns true.
  Future<bool> _requestPermissions() async {
    if (!_supported) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        if (granted == false) return false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (granted == false) return false;
      }
    } catch (e, st) {
      DiagnosticsService.instance.warning(
        'NotificationsService',
        'Permission request failed.',
        '$e\n$st',
      );
      return false;
    }
    return true;
  }

  Future<bool> setEnabled(bool v) async {
    if (v && _supported) {
      final ok = await _requestPermissions();
      if (!ok) return false;
    }
    _enabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, v);
    if (_supported) {
      if (v) {
        await _scheduleNext();
      } else {
        await _plugin.cancel(_notificationId);
      }
    }
    notifyListeners();
    return true;
  }

  Future<void> setTime(TimeOfDay t) async {
    _time = t;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kHour, t.hour);
    await prefs.setInt(_kMinute, t.minute);
    if (_supported && _enabled) {
      await _scheduleNext();
    }
    notifyListeners();
  }

  Future<void> reload() async {
    _initialised = false;
    await ensureInitialised();
  }

  /// Build the next firing instant in local time. If today's HH:MM is still
  /// in the future, fire today; otherwise tomorrow.
  tz.TZDateTime _nextOccurrence() {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, _time.hour, _time.minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  Future<void> _scheduleNext() async {
    if (!_supported || !_enabled) return;
    try {
      await _plugin.cancel(_notificationId);
      final body = _composeMessage();
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _plugin.zonedSchedule(
        _notificationId,
        'Plumber Pro',
        body,
        _nextOccurrence(),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, st) {
      DiagnosticsService.instance.error(
        'NotificationsService',
        'Daily reminder schedule failed.',
        '$e\n$st',
      );
    }
  }

  /// Schedule a one-off notification at a specific local-time instant. Used
  /// by the service-reminder system to ping the user on a customer's due
  /// date. If the chosen time is in the past, scheduling is skipped (the
  /// caller can just decide whether to surface it in-app instead).
  Future<void> scheduleOneOff({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (!_supported) return;
    try {
      await ensureInitialised();
      final tzWhen = tz.TZDateTime.from(when, tz.local);
      final now = tz.TZDateTime.now(tz.local);
      if (!tzWhen.isAfter(now)) return;
      const androidDetails = AndroidNotificationDetails(
        _serviceChannelId,
        _serviceChannelName,
        channelDescription: _serviceChannelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzWhen,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e, st) {
      DiagnosticsService.instance.warning(
        'NotificationsService',
        'One-off schedule failed for id=$id ($title) — service follow-up will not fire on the due date.',
        '$e\n$st',
      );
    }
  }

  Future<void> cancelOneOff(int id) async {
    if (!_supported) return;
    try {
      await _plugin.cancel(id);
    } catch (e, st) {
      DiagnosticsService.instance.warning(
        'NotificationsService',
        'Cancel failed for id=$id — a stale alarm may still fire.',
        '$e\n$st',
      );
    }
  }

  /// Compose a one-line message. Includes streak context when available so
  /// the reminder feels personal rather than generic.
  String _composeMessage() {
    final streak = ProgressService.instance.streak;
    if (streak > 1) {
      return 'Day $streak streak — open a lesson, simulation or quiz to keep it alive.';
    }
    if (streak == 1) {
      return 'You started a streak yesterday — open the app to make it day 2.';
    }
    final tips = _genericPrompts;
    return tips[math.Random().nextInt(tips.length)];
  }

  static const _genericPrompts = <String>[
    'Five minutes today: pick a quiz, a simulation or a glossary review.',
    'A daily habit beats cramming — tap in for one short session.',
    'Today’s gas tip: combustion analysis pre and post service is non-negotiable.',
    'Today’s heating tip: balance radiators to a 11–20 °C ΔT for efficient flow.',
    'Today’s water tip: check stop-tap operation before any first-fix.',
    'Open the AI tutor and ask one thing you weren’t sure about on your last job.',
    'Open photo diagnosis — try a fault you spotted recently.',
  ];
}
