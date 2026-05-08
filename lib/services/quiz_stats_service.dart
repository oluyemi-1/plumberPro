import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Per-topic quiz best-score persistence using SharedPreferences.
///
/// Stats are keyed by topic id and consist of: best raw score, total
/// questions, total attempts and most-recent score. Listening to the singleton
/// notifies any UI when a result is recorded.
class QuizResult {
  final int correct;
  final int total;
  final DateTime when;
  const QuizResult({
    required this.correct,
    required this.total,
    required this.when,
  });

  double get percent => total == 0 ? 0 : correct / total;
}

class QuizTopicStats {
  final int bestCorrect;
  final int total;
  final int attempts;
  final DateTime? lastAttempt;

  const QuizTopicStats({
    required this.bestCorrect,
    required this.total,
    required this.attempts,
    required this.lastAttempt,
  });

  static const empty =
      QuizTopicStats(bestCorrect: 0, total: 0, attempts: 0, lastAttempt: null);

  double get bestPercent =>
      total == 0 ? 0 : bestCorrect / total;

  String get bestLabel => total == 0 ? '—' : '$bestCorrect / $total';
}

class QuizStatsService extends ChangeNotifier {
  QuizStatsService._();
  static final QuizStatsService instance = QuizStatsService._();

  final Map<String, QuizTopicStats> _cache = {};
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (!key.startsWith('quiz_')) continue;
      final id = key.substring('quiz_'.length);
      final raw = prefs.getStringList(key);
      if (raw == null || raw.length < 4) continue;
      _cache[id] = QuizTopicStats(
        bestCorrect: int.tryParse(raw[0]) ?? 0,
        total: int.tryParse(raw[1]) ?? 0,
        attempts: int.tryParse(raw[2]) ?? 0,
        lastAttempt: DateTime.tryParse(raw[3]),
      );
    }
  }

  Future<QuizTopicStats> statsFor(String topicId) async {
    await _ensureLoaded();
    return _cache[topicId] ?? QuizTopicStats.empty;
  }

  /// Synchronous accessor — returns empty stats until [_ensureLoaded] runs.
  QuizTopicStats statsForCached(String topicId) =>
      _cache[topicId] ?? QuizTopicStats.empty;

  Future<void> recordResult(String topicId, QuizResult result) async {
    await _ensureLoaded();
    final prev = _cache[topicId] ?? QuizTopicStats.empty;
    final newBest = result.correct > prev.bestCorrect
        ? result.correct
        : prev.bestCorrect;
    final newTotal = result.total > prev.total ? result.total : prev.total;
    final updated = QuizTopicStats(
      bestCorrect: newBest,
      total: newTotal,
      attempts: prev.attempts + 1,
      lastAttempt: result.when,
    );
    _cache[topicId] = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('quiz_$topicId', [
      updated.bestCorrect.toString(),
      updated.total.toString(),
      updated.attempts.toString(),
      updated.lastAttempt?.toIso8601String() ?? '',
    ]);
    notifyListeners();
  }

  Future<void> reset(String topicId) async {
    await _ensureLoaded();
    _cache.remove(topicId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quiz_$topicId');
    notifyListeners();
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where((k) => k.startsWith('quiz_'))) {
      await prefs.remove(key);
    }
    _cache.clear();
    notifyListeners();
  }

  Future<void> preload() async => _ensureLoaded();
}
