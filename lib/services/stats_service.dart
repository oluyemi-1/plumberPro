import '../data/content_index.dart';
import 'bookmarks_service.dart';
import 'progress_service.dart';
import 'quiz_stats_service.dart';

/// Snapshot of the user's progress across the app, computed by aggregating
/// the existing services. Not persisted — derived live each time the stats
/// screen is opened.
class StatsSnapshot {
  // Lessons
  final int totalLessons;
  final int lessonsRead;

  // Simulations
  final int totalSims;
  final int simsWatched;

  // Scenarios
  final int totalScenarios;
  final int scenariosOpened;

  // Quizzes — aggregates from QuizStatsService for the topics in the index.
  final int totalQuizTopics;
  final int quizTopicsAttempted;
  final int quizQuestionsTotal;
  final int quizBestCorrectTotal;
  final List<TopicScore> topicScores;

  // Bookmarks
  final int bookmarksCount;

  // Streak
  final int currentStreak;
  final String? lastOpenDate;

  // Hubs / specialism modules visited
  final int hubsVisited;

  const StatsSnapshot({
    required this.totalLessons,
    required this.lessonsRead,
    required this.totalSims,
    required this.simsWatched,
    required this.totalScenarios,
    required this.scenariosOpened,
    required this.totalQuizTopics,
    required this.quizTopicsAttempted,
    required this.quizQuestionsTotal,
    required this.quizBestCorrectTotal,
    required this.topicScores,
    required this.bookmarksCount,
    required this.currentStreak,
    required this.lastOpenDate,
    required this.hubsVisited,
  });

  double get lessonsPercent =>
      totalLessons == 0 ? 0 : lessonsRead / totalLessons;
  double get simsPercent => totalSims == 0 ? 0 : simsWatched / totalSims;
  double get quizPercent => quizQuestionsTotal == 0
      ? 0
      : quizBestCorrectTotal / quizQuestionsTotal;
  double get scenariosPercent =>
      totalScenarios == 0 ? 0 : scenariosOpened / totalScenarios;

  TopicScore? get weakestTopic {
    final attempted = topicScores.where((t) => t.attempted).toList();
    if (attempted.isEmpty) return null;
    attempted.sort((a, b) => a.percent.compareTo(b.percent));
    return attempted.first;
  }

  TopicScore? get strongestTopic {
    final attempted = topicScores.where((t) => t.attempted).toList();
    if (attempted.isEmpty) return null;
    attempted.sort((a, b) => b.percent.compareTo(a.percent));
    return attempted.first;
  }
}

class TopicScore {
  final String id;
  final String title;
  final String category;
  final int total;
  final int best;
  final bool attempted;
  const TopicScore({
    required this.id,
    required this.title,
    required this.category,
    required this.total,
    required this.best,
    required this.attempted,
  });
  double get percent => total == 0 ? 0 : best / total;
  String get label => '$best / $total';
}

class StatsService {
  StatsService._();
  static final StatsService instance = StatsService._();

  /// Build a snapshot. Caller should `await` the underlying service loads
  /// before calling this — which the screen does in initState.
  StatsSnapshot snapshot({required List<SearchEntry> all}) {
    final visited = ProgressService.instance.visitedIds;

    int countByType(String type) =>
        all.where((e) => e.type == type).length;
    int visitedByPrefix(String prefix) =>
        visited.where((id) => id.startsWith(prefix)).length;

    final totalLessons = countByType('Lesson');
    final totalSims = countByType('Simulation');
    final totalScenarios = countByType('Scenario');
    final totalHubs = countByType('Hub') + countByType('Calculator');

    // Quiz aggregates — iterate quiz entries from the index and pull each
    // topic's stats from QuizStatsService.
    final quizEntries = all.where((e) => e.type == 'Quiz').toList();
    final topicScores = <TopicScore>[];
    int quizQuestionsTotal = 0;
    int quizBestCorrectTotal = 0;
    int quizTopicsAttempted = 0;
    for (final q in quizEntries) {
      // SearchEntry id is 'quiz:<topicId>' — strip prefix.
      final topicId = q.id.startsWith('quiz:') ? q.id.substring(5) : q.id;
      final s = QuizStatsService.instance.statsForCached(topicId);
      final attempted = s.attempts > 0;
      if (attempted) quizTopicsAttempted++;
      quizQuestionsTotal += s.total;
      quizBestCorrectTotal += s.bestCorrect;
      topicScores.add(TopicScore(
        id: topicId,
        title: q.title,
        category: q.category,
        total: s.total,
        best: s.bestCorrect,
        attempted: attempted,
      ));
    }

    return StatsSnapshot(
      totalLessons: totalLessons,
      lessonsRead: visitedByPrefix('lesson:'),
      totalSims: totalSims,
      simsWatched: visitedByPrefix('sim:'),
      totalScenarios: totalScenarios,
      scenariosOpened: visitedByPrefix('scenario:'),
      totalQuizTopics: quizEntries.length,
      quizTopicsAttempted: quizTopicsAttempted,
      quizQuestionsTotal: quizQuestionsTotal,
      quizBestCorrectTotal: quizBestCorrectTotal,
      topicScores: topicScores,
      bookmarksCount: BookmarksService.instance.ids.length,
      currentStreak: ProgressService.instance.streak,
      lastOpenDate: ProgressService.instance.lastDate,
      hubsVisited: totalHubs == 0
          ? 0
          : visited.where((id) => id.startsWith('hub:')).length,
    );
  }
}
