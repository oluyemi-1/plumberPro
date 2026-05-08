import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/expense_data.dart';

/// Singleton CRUD store for business expenses and mileage. Mileage rate is
/// kept here (rather than per-entry) so the user can change their default
/// once and have new trips inherit it. Each entry still records the rate it
/// was logged at, so historical totals stay correct.
class ExpenseService extends ChangeNotifier {
  ExpenseService._();
  static final ExpenseService instance = ExpenseService._();

  static const _kKey = 'expenses_v1';
  static const _kRate = 'mileage_rate_v1';

  /// HMRC simplified rate for sole traders / employees claiming car mileage:
  /// 45p / mile for the first 10,000 business miles in a tax year.
  static const double defaultMileageRate = 0.45;

  final List<Expense> _items = [];
  double _mileageRate = defaultMileageRate;
  bool _loaded = false;

  /// Newest first.
  List<Expense> get items => List.unmodifiable(_items);
  double get mileageRate => _mileageRate;
  bool get loaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _items.addAll(decodeExpenses(prefs.getString(_kKey)));
    _mileageRate = prefs.getDouble(_kRate) ?? defaultMileageRate;
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
    _items.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, encodeExpenses(_items));
  }

  Future<void> setMileageRate(double v) async {
    _mileageRate = v.clamp(0.0, 5.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kRate, _mileageRate);
    notifyListeners();
  }

  Future<Expense> add(Expense e) async {
    _items.add(e);
    _sort();
    await _save();
    notifyListeners();
    return e;
  }

  Future<void> update(Expense e) async {
    final i = _items.indexWhere((x) => x.id == e.id);
    if (i == -1) return;
    _items[i] = e;
    _sort();
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((x) => x.id == id);
    await _save();
    notifyListeners();
  }

  Expense? findById(String id) {
    for (final e in _items) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// All expenses linked to the given job, newest first.
  List<Expense> forJob(String jobId) =>
      _items.where((e) => e.jobId == jobId).toList();

  /// Total cost (£) of expenses linked to *any* of the given job ids. Used
  /// by the customer-history hub to aggregate parts + mileage spent on a
  /// single customer across all their jobs.
  double totalForJobs(Iterable<String> jobIds) {
    if (jobIds.isEmpty) return 0;
    final set = jobIds.toSet();
    var sum = 0.0;
    for (final e in _items) {
      if (e.jobId == null) continue;
      if (set.contains(e.jobId)) sum += e.computedAmountGbp;
    }
    return sum;
  }

  /// Total cost (£) of items in the given range (inclusive of [from], exclusive
  /// of [to]). Pass nulls to get the all-time total.
  double totalIn({DateTime? from, DateTime? to, ExpenseKind? kind}) {
    var sum = 0.0;
    for (final e in _items) {
      if (kind != null && e.kind != kind) continue;
      if (from != null && e.date.isBefore(from)) continue;
      if (to != null && !e.date.isBefore(to)) continue;
      sum += e.computedAmountGbp;
    }
    return sum;
  }

  /// Total miles in the given range.
  double milesIn({DateTime? from, DateTime? to}) {
    var sum = 0.0;
    for (final e in _items) {
      if (e.kind != ExpenseKind.mileage) continue;
      if (from != null && e.date.isBefore(from)) continue;
      if (to != null && !e.date.isBefore(to)) continue;
      sum += e.miles;
    }
    return sum;
  }
}
