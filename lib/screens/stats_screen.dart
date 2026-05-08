import 'package:flutter/material.dart';

import '../data/achievements_data.dart';
import '../data/content_index.dart';
import '../services/bookmarks_service.dart';
import '../services/progress_service.dart';
import '../services/quiz_stats_service.dart';
import '../services/stats_service.dart';
import '../theme.dart';
import '../widgets/responsive.dart';

/// Personal stats dashboard — aggregates progress across the app and shows
/// achievements as they are unlocked.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late final List<SearchEntry> _allContent;

  @override
  void initState() {
    super.initState();
    _allContent = buildContentIndex();
    QuizStatsService.instance.preload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your progress')),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          ProgressService.instance,
          BookmarksService.instance,
          QuizStatsService.instance,
        ]),
        builder: (context, _) {
          final s = StatsService.instance.snapshot(all: _allContent);
          final earned =
              achievements.where((a) => a.earned(s)).toList();
          final locked =
              achievements.where((a) => !a.earned(s)).toList();
          return MaxContentWidth(
            maxWidth: 980,
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _OverviewCard(s: s),
                const SizedBox(height: 12),
                _CategoriesGrid(s: s),
                const SizedBox(height: 12),
                if (s.weakestTopic != null || s.strongestTopic != null)
                  _TopicHighlight(s: s),
                const SizedBox(height: 12),
                _AchievementsSection(
                  earned: earned,
                  locked: locked,
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final StatsSnapshot s;
  const _OverviewCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OVERVIEW',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 18,
            runSpacing: 14,
            children: [
              _Metric(label: 'Streak', value: '${s.currentStreak} days', icon: Icons.local_fire_department),
              _Metric(label: 'Bookmarks', value: '${s.bookmarksCount}', icon: Icons.bookmark),
              _Metric(
                label: 'Quiz points',
                value: '${s.quizBestCorrectTotal} / ${s.quizQuestionsTotal}',
                icon: Icons.emoji_events,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  final StatsSnapshot s;
  const _CategoriesGrid({required this.s});

  @override
  Widget build(BuildContext context) {
    final entries = [
      _Cat(
        label: 'Lessons read',
        progress: s.lessonsPercent,
        value: '${s.lessonsRead} / ${s.totalLessons}',
        color: const Color(0xFF2A9D8F),
        icon: Icons.menu_book,
      ),
      _Cat(
        label: 'Simulations watched',
        progress: s.simsPercent,
        value: '${s.simsWatched} / ${s.totalSims}',
        color: AppColors.primary,
        icon: Icons.play_circle,
      ),
      _Cat(
        label: 'Job scenarios',
        progress: s.scenariosPercent,
        value: '${s.scenariosOpened} / ${s.totalScenarios}',
        color: const Color(0xFFD62828),
        icon: Icons.work_history,
      ),
      _Cat(
        label: 'Quizzes attempted',
        progress: s.totalQuizTopics == 0
            ? 0
            : s.quizTopicsAttempted / s.totalQuizTopics,
        value: '${s.quizTopicsAttempted} / ${s.totalQuizTopics}',
        color: const Color(0xFFE76F51),
        icon: Icons.quiz,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = constraints.maxWidth > 720 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 130,
          ),
          itemBuilder: (_, i) => _CategoryCard(c: entries[i]),
        );
      },
    );
  }
}

class _Cat {
  final String label;
  final double progress;
  final String value;
  final Color color;
  final IconData icon;
  const _Cat({
    required this.label,
    required this.progress,
    required this.value,
    required this.color,
    required this.icon,
  });
}

class _CategoryCard extends StatelessWidget {
  final _Cat c;
  const _CategoryCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(c.icon, color: c.color),
              ),
              const Spacer(),
              Text(
                '${(c.progress * 100).clamp(0, 100).round()}%',
                style: TextStyle(
                  color: c.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ]),
            const SizedBox(height: 6),
            Text(c.label,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: c.progress.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation(c.color),
              ),
            ),
            const SizedBox(height: 4),
            Text(c.value, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _TopicHighlight extends StatelessWidget {
  final StatsSnapshot s;
  const _TopicHighlight({required this.s});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quiz performance',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            if (s.strongestTopic != null)
              _topicRow(
                context,
                label: 'Strongest topic',
                topic: s.strongestTopic!,
                color: Colors.green,
                icon: Icons.trending_up,
              ),
            if (s.weakestTopic != null && s.weakestTopic != s.strongestTopic)
              _topicRow(
                context,
                label: 'Weakest topic',
                topic: s.weakestTopic!,
                color: Colors.redAccent,
                icon: Icons.trending_down,
              ),
            if (s.weakestTopic == null && s.strongestTopic == null)
              const Text('Take a quiz to see your strongest and weakest topic.'),
          ],
        ),
      ),
    );
  }

  Widget _topicRow(
    BuildContext context, {
    required String label,
    required TopicScore topic,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context).textTheme.bodySmall),
              Text(topic.title,
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
        Text('${(topic.percent * 100).round()}%',
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 18)),
      ]),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  final List<Achievement> earned;
  final List<Achievement> locked;
  const _AchievementsSection(
      {required this.earned, required this.locked});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Achievements',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Text(
                '${earned.length} / ${earned.length + locked.length}',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            if (earned.isNotEmpty) ...[
              const _SubHeader('Earned'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: earned
                    .map((a) => _AchievementChip(a: a, earned: true))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (locked.isNotEmpty) ...[
              const _SubHeader('Locked'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: locked
                    .map((a) => _AchievementChip(a: a, earned: false))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String text;
  const _SubHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      );
}

class _AchievementChip extends StatelessWidget {
  final Achievement a;
  final bool earned;
  const _AchievementChip({required this.a, required this.earned});

  @override
  Widget build(BuildContext context) {
    final color = earned ? a.color : AppColors.muted;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showDialog(context),
      child: Container(
        width: 152,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: earned
              ? color.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: earned ? 0.4 : 0.15),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(a.icon, color: color, size: 22),
              const Spacer(),
              if (earned)
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 16)
              else
                Icon(Icons.lock_outline,
                    color: AppColors.muted.withValues(alpha: 0.5), size: 16),
            ]),
            const SizedBox(height: 6),
            Text(a.title,
                style: TextStyle(
                  color: earned ? AppColors.text : AppColors.muted,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                )),
            const SizedBox(height: 2),
            Text(
              a.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: earned
                    ? AppColors.muted
                    : AppColors.muted.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [
          Icon(a.icon, color: a.color),
          const SizedBox(width: 8),
          Expanded(child: Text(a.title)),
        ]),
        content: Text(a.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(earned ? 'Cheers' : 'Got it'),
          ),
        ],
      ),
    );
  }
}
