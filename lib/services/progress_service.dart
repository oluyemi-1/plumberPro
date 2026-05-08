import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks user progress across the app:
///   - which content items have been opened (`visitedIds`)
///   - the most recently opened items, MRU (`recentIds`, max 10)
///   - the current open-the-app daily streak counter
///
/// All state persists via shared_preferences. IDs follow the same
/// convention as `SearchEntry.id` in `data/content_index.dart`.
class ProgressService extends ChangeNotifier {
  ProgressService._();
  static final ProgressService instance = ProgressService._();

  static const _kVisited = 'progress_visited_v1';
  static const _kRecent = 'progress_recent_v1';
  static const _kStreak = 'progress_streak_v1';
  static const _kLastDate = 'progress_last_date_v1';
  static const _maxRecent = 10;

  final Set<String> _visited = <String>{};
  final List<String> _recent = <String>[];
  int _streak = 0;
  String? _lastDate;
  bool _loaded = false;

  Set<String> get visitedIds => Set.unmodifiable(_visited);
  List<String> get recentIds => List.unmodifiable(_recent);
  int get streak => _streak;
  String? get lastDate => _lastDate;
  bool get loaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _visited.addAll(prefs.getStringList(_kVisited) ?? const []);
    _recent.addAll(prefs.getStringList(_kRecent) ?? const []);
    _streak = prefs.getInt(_kStreak) ?? 0;
    _lastDate = prefs.getString(_kLastDate);
    _loaded = true;
    notifyListeners();
  }

  bool hasVisited(String id) => _visited.contains(id);

  /// Records that the user opened the content item with the given id.
  /// Updates the visited set and the MRU recent list. Saves to disk.
  Future<void> markVisited(String id) async {
    final wasNew = _visited.add(id);
    // Move to front of recent.
    _recent.remove(id);
    _recent.insert(0, id);
    while (_recent.length > _maxRecent) {
      _recent.removeLast();
    }
    final prefs = await SharedPreferences.getInstance();
    if (wasNew) {
      await prefs.setStringList(_kVisited, _visited.toList());
    }
    await prefs.setStringList(_kRecent, _recent);
    notifyListeners();
  }

  /// Counts a single open-the-app event for today. Increments the streak
  /// when called on a new day that follows yesterday's open. Resets to 1 if
  /// a day was missed. No-op for repeat opens on the same day.
  Future<void> recordOpenToday({DateTime? now}) async {
    final today = _yyyyMmDd(now ?? DateTime.now());
    if (_lastDate == today) return; // already counted today
    final prefs = await SharedPreferences.getInstance();
    if (_lastDate == null) {
      _streak = 1;
    } else {
      final yesterday = _yyyyMmDd(
        (now ?? DateTime.now()).subtract(const Duration(days: 1)),
      );
      _streak = (_lastDate == yesterday) ? _streak + 1 : 1;
    }
    _lastDate = today;
    await prefs.setInt(_kStreak, _streak);
    await prefs.setString(_kLastDate, today);
    notifyListeners();
  }

  /// Re-read all state from disk after a restore.
  Future<void> reload() async {
    _visited.clear();
    _recent.clear();
    _streak = 0;
    _lastDate = null;
    _loaded = false;
    await ensureLoaded();
  }

  Future<void> resetVisited() async {
    _visited.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kVisited);
    notifyListeners();
  }

  Future<void> resetAll() async {
    _visited.clear();
    _recent.clear();
    _streak = 0;
    _lastDate = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kVisited);
    await prefs.remove(_kRecent);
    await prefs.remove(_kStreak);
    await prefs.remove(_kLastDate);
    notifyListeners();
  }

  static String _yyyyMmDd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
