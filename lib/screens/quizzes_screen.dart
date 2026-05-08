import 'package:flutter/material.dart';

import '../data/quiz_data.dart';
import '../data/backflow_quiz_data.dart';
import '../data/electrical_quiz_data.dart';
import '../data/fuels_quiz_data.dart';
import '../data/renewables_quiz_data.dart';
import '../services/quiz_stats_service.dart';
import '../theme.dart';
import 'quiz_session_screen.dart';

List<QuizTopic> get _allQuizTopics => [
      ...quizTopics,
      ...electricalQuizTopics,
      ...renewablesQuizTopics,
      ...fuelsQuizTopics,
      ...backflowQuizTopics,
    ];

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    QuizStatsService.instance.preload();
  }

  List<String> get _categories {
    final s = <String>{'All'};
    for (final t in _allQuizTopics) {
      s.add(t.category);
    }
    return s.toList();
  }

  List<QuizTopic> get _filtered {
    final all = _allQuizTopics;
    if (_filter == 'All') return all;
    return all.where((t) => t.category == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes & knowledge checks'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) async {
              if (v == 'reset_all') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Reset all scores?'),
                    content: const Text(
                        'This will clear best scores and attempts for every topic.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset')),
                    ],
                  ),
                );
                if (ok == true) {
                  await QuizStatsService.instance.resetAll();
                  if (mounted) setState(() {});
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'reset_all',
                child: Text('Reset all scores'),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: QuizStatsService.instance,
        builder: (context, _) {
          final topics = _filtered;
          final totalAttempts = _allQuizTopics
              .map((t) => QuizStatsService.instance.statsForCached(t.id))
              .fold<int>(0, (a, s) => a + s.attempts);
          final bestSum = _allQuizTopics
              .map((t) => QuizStatsService.instance.statsForCached(t.id))
              .fold<int>(0, (a, s) => a + s.bestCorrect);
          final maxSum =
              _allQuizTopics.fold<int>(0, (a, t) => a + t.questions.length);
          final percent = maxSum == 0 ? 0 : (bestSum / maxSum * 100).round();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Card(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.school,
                            color: AppColors.primary, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Overall progress',
                                  style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                '$bestSum of $maxSum points · $percent% · $totalAttempts attempt${totalAttempts == 1 ? '' : 's'}',
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: maxSum == 0 ? 0 : bestSum / maxSum,
                                  minHeight: 8,
                                  backgroundColor: Colors.black12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final c = _categories[i];
                    return ChoiceChip(
                      label: Text(c),
                      selected: _filter == c,
                      onSelected: (_) => setState(() => _filter = c),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
                  itemCount: topics.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final t = topics[i];
                    final stats =
                        QuizStatsService.instance.statsForCached(t.id);
                    return _TopicTile(
                      topic: t,
                      stats: stats,
                      onTap: (mode) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizSessionScreen(
                              topic: t,
                              mode: mode,
                            ),
                          ),
                        );
                        if (mounted) setState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final QuizTopic topic;
  final QuizTopicStats stats;
  final void Function(QuizMode) onTap;
  const _TopicTile({
    required this.topic,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = stats.total == 0 ? 0 : (stats.bestPercent * 100).round();
    final medal = stats.total == 0
        ? null
        : (percent >= 90
            ? Icons.workspace_premium
            : percent >= 70
                ? Icons.military_tech
                : Icons.flag);
    final medalColor = percent >= 90
        ? Colors.amber
        : percent >= 70
            ? Colors.blueGrey
            : AppColors.muted;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.quiz, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(topic.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${topic.category} · ${topic.questions.length} questions',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (medal != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(medal, color: medalColor),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(topic.summary,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: stats.bestPercent,
                      minHeight: 6,
                      backgroundColor: Colors.black12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  stats.total == 0
                      ? 'Not yet attempted'
                      : 'Best ${stats.bestLabel} · $percent%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => onTap(QuizMode.practice),
                  icon: const Icon(Icons.school),
                  label: const Text('Practice'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => onTap(QuizMode.exam),
                  icon: const Icon(Icons.timer),
                  label: const Text('Exam'),
                ),
                const Spacer(),
                Text(
                  '${stats.attempts} attempt${stats.attempts == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
