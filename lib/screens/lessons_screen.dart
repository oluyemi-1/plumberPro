import 'package:flutter/material.dart';

import '../data/lessons_data.dart';
import '../data/backflow_lessons_data.dart';
import '../data/electrical_lessons_data.dart';
import '../data/fuels_lessons_data.dart';
import '../data/renewables_lessons_data.dart';
import '../data/quiz_data.dart';
import '../data/backflow_quiz_data.dart';
import '../data/electrical_quiz_data.dart';
import '../data/fuels_quiz_data.dart';
import '../data/renewables_quiz_data.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import 'quiz_session_screen.dart';

/// All lesson topics across the core and extension data files.
List<LessonTopic> get _allLessonTopics => [
      ...lessonTopics,
      ...electricalLessonTopics,
      ...renewablesLessonTopics,
      ...fuelsLessonTopics,
      ...backflowLessonTopics,
    ];

/// All quiz topics across the core and extension data files.
List<QuizTopic> get _allQuizTopics => [
      ...quizTopics,
      ...electricalQuizTopics,
      ...renewablesQuizTopics,
      ...fuelsQuizTopics,
      ...backflowQuizTopics,
    ];

/// Maps a lesson topic id to a related quiz topic id when one exists.
const Map<String, String> _lessonToQuiz = {
  'cold_water_basics': 'cold_water',
  'hot_water_systems': 'hot_water',
  'central_heating': 'central_heating',
  'drainage_and_traps': 'drainage',
  'pipe_materials_joints': 'materials',
  'regulations_safety': 'regs_safety',
  'rainwater_systems': 'rainwater',
  'unvented_systems': 'hot_water',
  'underfloor_heating': 'underfloor',
  'pressure_testing': 'pressure_testing',
  'electrical_principles': 'electrical_basics',
  'safe_isolation': 'safe_isolation',
  'heating_wiring': 'electrical_basics',
  'air_source_heat_pump': 'renewables_basics',
  'ground_source_heat_pump': 'renewables_basics',
  'solar_pv': 'renewables_install',
  'mvhr': 'renewables_install',
  'fuel_selection': 'fuels_basics',
  'combustion_basics': 'fuels_basics',
  'flues_chimneys': 'flues_install',
  'lpg_oil': 'flues_install',
  'fluid_categories': 'backflow_categories',
  'air_gaps_devices': 'backflow_devices',
  'backflow_practice': 'backflow_devices',
};

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  String _filter = 'All';

  List<String> get _categories {
    final s = <String>{'All'};
    for (final t in _allLessonTopics) {
      s.add(t.category);
    }
    return s.toList();
  }

  List<LessonTopic> get _filtered {
    final all = _allLessonTopics;
    if (_filter == 'All') return all;
    return all.where((t) => t.category == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final topics = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('Lessons and theory')),
      body: Column(children: [
        SizedBox(
          height: 56,
          child: ListView.separated(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          child: AnimatedBuilder(
            animation: ProgressService.instance,
            builder: (context, _) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            itemCount: topics.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final t = topics[i];
              final visited =
                  ProgressService.instance.hasVisited('lesson:${t.id}');
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                ProgressService.instance.markVisited('lesson:${t.id}');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonDetailScreen(topic: t),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (visited ? Colors.green : AppColors.primary)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                          visited ? Icons.check_circle : Icons.menu_book,
                          color: visited
                              ? Colors.green
                              : AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(t.title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ),
                            if (visited)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.check,
                                    color: Colors.green, size: 16),
                              ),
                          ]),
                          const SizedBox(height: 2),
                          Text('${t.category} · ${t.sections.length} sections',
                              style:
                                  Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 4),
                          Text(t.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
            },
          ),
          ),
        ),
      ]),
    );
  }
}

class LessonDetailScreen extends StatefulWidget {
  final LessonTopic topic;
  const LessonDetailScreen({super.key, required this.topic});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int? _speakingIndex;

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  Future<void> _speakAll() async {
    for (int i = 0; i < widget.topic.sections.length; i++) {
      if (!mounted) return;
      setState(() => _speakingIndex = i);
      await TtsService.instance.speak(widget.topic.sections[i].speakable);
    }
    if (mounted) setState(() => _speakingIndex = null);
  }

  Future<void> _speakOne(int i) async {
    setState(() => _speakingIndex = i);
    await TtsService.instance.speak(widget.topic.sections[i].speakable);
    if (mounted) setState(() => _speakingIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.topic;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.title),
        actions: [
          IconButton(
            tooltip: 'Read whole lesson',
            icon: const Icon(Icons.record_voice_over),
            onPressed: _speakAll,
          ),
          IconButton(
            tooltip: 'Stop',
            icon: const Icon(Icons.stop_circle),
            onPressed: () {
              TtsService.instance.stop();
              if (mounted) setState(() => _speakingIndex = null);
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: t.sections.length + 2,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          if (i == t.sections.length + 1) {
            final quizId = _lessonToQuiz[t.id];
            if (quizId == null) return const SizedBox.shrink();
            QuizTopic? quiz;
            for (final qt in _allQuizTopics) {
              if (qt.id == quizId) {
                quiz = qt;
                break;
              }
            }
            if (quiz == null) return const SizedBox.shrink();
            final selected = quiz;
            return Card(
              color: AppColors.accent.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.quiz, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text('Test your knowledge',
                          style: Theme.of(context).textTheme.titleMedium),
                    ]),
                    const SizedBox(height: 6),
                    Text(
                      'Try the ${selected.questions.length}-question quiz on this topic to see what stuck.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizSessionScreen(
                                topic: selected,
                                mode: QuizMode.practice,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.school),
                          label: const Text('Practice quiz'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizSessionScreen(
                                topic: selected,
                                mode: QuizMode.exam,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.timer),
                          label: const Text('Exam quiz'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          if (i == 0) {
            return Card(
              color: AppColors.primary.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.category,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(t.summary,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            );
          }
          final section = t.sections[i - 1];
          final highlighted = _speakingIndex == i - 1;
          return Card(
            color: highlighted ? AppColors.primary.withValues(alpha: 0.06) : null,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(section.heading,
                            style:
                                Theme.of(context).textTheme.titleMedium),
                      ),
                      IconButton(
                        tooltip: 'Read this section',
                        icon: Icon(highlighted
                            ? Icons.graphic_eq
                            : Icons.play_circle_outline),
                        onPressed: () => _speakOne(i - 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(section.body,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
