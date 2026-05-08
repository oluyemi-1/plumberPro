import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/synoptic_data.dart';
import '../theme.dart';
import 'synoptic_session_screen.dart';

/// Hub screen listing all available [SynopticAssessment]s. Each card shows
/// the title, coverage chips, time limit and total marks, plus the user's
/// best stored score (if any) for that assessment.
class SynopticScreen extends StatefulWidget {
  const SynopticScreen({super.key});

  @override
  State<SynopticScreen> createState() => _SynopticScreenState();
}

class _SynopticScreenState extends State<SynopticScreen> {
  final Map<String, _BestScore?> _bestScores = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    for (final a in synopticAssessments) {
      final raw = prefs.getString('synoptic_${a.id}');
      if (raw == null) {
        _bestScores[a.id] = null;
      } else {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          _bestScores[a.id] = _BestScore(
            correctMarks: (map['correctMarks'] as num).toInt(),
            totalMarks: (map['totalMarks'] as num).toInt(),
            timestamp:
                DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
          );
        } catch (_) {
          _bestScores[a.id] = null;
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openSession(SynopticAssessment a) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SynopticSessionScreen(assessment: a),
    ));
    // Reload scores when we return.
    if (mounted) {
      setState(() => _loading = true);
      await _loadScores();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synoptic mock assessments'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                Card(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment,
                            color: AppColors.primary, size: 32),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Each synoptic assessment combines theory, '
                            'calculation and decision making into one timed '
                            'exercise. Aim for 70 percent or above to pass.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...synopticAssessments.map((a) {
                  final best = _bestScores[a.id];
                  return _AssessmentCard(
                    assessment: a,
                    best: best,
                    onStart: () => _openSession(a),
                  );
                }),
              ],
            ),
    );
  }
}

class _BestScore {
  final int correctMarks;
  final int totalMarks;
  final DateTime timestamp;
  const _BestScore({
    required this.correctMarks,
    required this.totalMarks,
    required this.timestamp,
  });

  int get percent => totalMarks == 0
      ? 0
      : ((correctMarks / totalMarks) * 100).round();
}

class _AssessmentCard extends StatelessWidget {
  final SynopticAssessment assessment;
  final _BestScore? best;
  final VoidCallback onStart;
  const _AssessmentCard({
    required this.assessment,
    required this.best,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final coverageParts =
        assessment.coverage.split('|').map((s) => s.trim()).toList();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onStart,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.12),
                    child:
                        const Icon(Icons.task_alt, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      assessment.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: coverageParts
                    .map((c) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.coldWater
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.coldWater
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            c,
                            style: const TextStyle(
                              color: AppColors.coldWater,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.timer,
                      size: 16, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('${assessment.timeLimitMinutes} min',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 14),
                  const Icon(Icons.flag, size: 16, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('${assessment.totalMarks} marks',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 14),
                  const Icon(Icons.list, size: 16, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text('${assessment.tasks.length} tasks',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 10),
              if (best != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (best!.percent >= 70
                            ? Colors.green
                            : AppColors.gas)
                        .withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (best!.percent >= 70
                              ? Colors.green
                              : AppColors.gas)
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        best!.percent >= 70
                            ? Icons.emoji_events
                            : Icons.trending_up,
                        color: best!.percent >= 70
                            ? Colors.green
                            : AppColors.gas,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Best: ${best!.correctMarks} / '
                          '${best!.totalMarks} (${best!.percent}%)',
                          style: TextStyle(
                            color: best!.percent >= 70
                                ? Colors.green.shade800
                                : AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: AppColors.muted),
                      SizedBox(width: 8),
                      Text('Not yet attempted',
                          style: TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start assessment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
