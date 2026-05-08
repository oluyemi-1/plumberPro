import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/job_log_data.dart';
import '../data/quote_data.dart';
import 'job_log_service.dart';

/// Singleton CRUD store for pre-job estimates. Quotes live their own
/// lifecycle (draft → sent → accepted/rejected) and on acceptance can spawn
/// a real `Job` via [convertToJob].
class QuoteService extends ChangeNotifier {
  QuoteService._();
  static final QuoteService instance = QuoteService._();

  static const _kKey = 'quotes_v1';

  final List<Quote> _items = [];
  bool _loaded = false;

  /// Newest first (sorted by createdAt descending).
  List<Quote> get items => List.unmodifiable(_items);
  bool get loaded => _loaded;

  /// Quotes still awaiting acceptance — lets the home / Jobs screen surface
  /// a count badge. Excludes accepted (converted to jobs) and rejected.
  int get openCount => _items.where((q) => q.status.isOpen).length;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _items.addAll(decodeQuotes(prefs.getString(_kKey)));
    _sort();
    _loaded = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _items.clear();
    _loaded = false;
    await ensureLoaded();
  }

  void _sort() {
    _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, encodeQuotes(_items));
  }

  Quote? findById(String id) {
    for (final q in _items) {
      if (q.id == id) return q;
    }
    return null;
  }

  Future<Quote> create(Quote q) async {
    _items.add(q);
    _sort();
    await _save();
    notifyListeners();
    return q;
  }

  Future<void> update(Quote q) async {
    final i = _items.indexWhere((x) => x.id == q.id);
    if (i == -1) return;
    _items[i] = q;
    _sort();
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((q) => q.id == id);
    await _save();
    notifyListeners();
  }

  /// Mark a draft as sent — stamps `sentAt` so the PDF can show "Sent on …"
  /// and the list view can sort sent quotes after drafts.
  Future<void> markSent(String id) async {
    final i = _items.indexWhere((q) => q.id == id);
    if (i == -1) return;
    final q = _items[i];
    if (q.status != QuoteStatus.draft && q.status != QuoteStatus.sent) return;
    _items[i] = q.copyWith(
      status: QuoteStatus.sent,
      sentAt: q.sentAt ?? DateTime.now(),
    );
    await _save();
    notifyListeners();
  }

  Future<void> markAccepted(String id) async {
    final i = _items.indexWhere((q) => q.id == id);
    if (i == -1) return;
    _items[i] = _items[i].copyWith(
      status: QuoteStatus.accepted,
      respondedAt: DateTime.now(),
    );
    await _save();
    notifyListeners();
  }

  Future<void> markRejected(String id) async {
    final i = _items.indexWhere((q) => q.id == id);
    if (i == -1) return;
    _items[i] = _items[i].copyWith(
      status: QuoteStatus.rejected,
      respondedAt: DateTime.now(),
    );
    await _save();
    notifyListeners();
  }

  /// Reopens a quote that was previously rejected or accepted (without
  /// having been converted to a job). Useful when a customer changes their
  /// mind. Does not touch quotes already linked to a job.
  Future<void> reopen(String id) async {
    final i = _items.indexWhere((q) => q.id == id);
    if (i == -1) return;
    final q = _items[i];
    if (q.convertedJobId != null) return;
    _items[i] = q.copyWith(
      status: QuoteStatus.draft,
      clearRespondedAt: true,
    );
    await _save();
    notifyListeners();
  }

  /// Spawn a real Job pre-filled with the quote's contents and remember the
  /// link. The quote becomes accepted (if it wasn't already).
  ///
  /// Returns the new Job, or null if the quote could not be found.
  Future<Job?> convertToJob(String quoteId) async {
    final i = _items.indexWhere((q) => q.id == quoteId);
    if (i == -1) return null;
    final q = _items[i];
    if (q.convertedJobId != null) {
      // Already converted — return the existing job rather than create a
      // duplicate.
      return JobLogService.instance.findById(q.convertedJobId!);
    }

    final job = await JobLogService.instance.createJob(
      customer: q.customer,
      address: q.address,
      description: q.description,
      hourlyRateGbp: q.hourlyRateGbp,
      customerId: q.customerId,
    );

    // Seed the predicted parts onto the new job. They become real
    // MaterialLines the plumber can adjust as the work happens.
    for (var n = 0; n < q.lines.length; n++) {
      final l = q.lines[n];
      await JobLogService.instance.addMaterial(
        job.id,
        MaterialLine(
          id: 'm-${DateTime.now().millisecondsSinceEpoch}-$n',
          description: l.description,
          quantity: l.quantity,
          unitPriceGbp: l.unitPriceGbp,
        ),
      );
    }

    if (q.notes.trim().isNotEmpty) {
      await JobLogService.instance.updateNotes(job.id, q.notes);
    }

    _items[i] = q.copyWith(
      status: QuoteStatus.accepted,
      respondedAt: q.respondedAt ?? DateTime.now(),
      convertedJobId: job.id,
    );
    await _save();
    notifyListeners();
    // Return the freshest copy of the Job — the original `job` snapshot
    // was captured *before* materials and notes were seeded onto it, so
    // callers (and assertions) wouldn't see them.
    return JobLogService.instance.findById(job.id) ?? job;
  }
}
