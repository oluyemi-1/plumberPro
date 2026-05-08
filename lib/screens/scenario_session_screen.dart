import 'dart:async';

import 'package:flutter/material.dart';

import '../data/scenarios_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class ScenarioSessionScreen extends StatefulWidget {
  final JobScenario scenario;
  const ScenarioSessionScreen({super.key, required this.scenario});

  @override
  State<ScenarioSessionScreen> createState() => _ScenarioSessionScreenState();
}

enum _Stage { brief, decisions, results }

class _ScenarioSessionScreenState extends State<ScenarioSessionScreen> {
  _Stage _stage = _Stage.brief;
  int _stepIndex = 0;
  // Per-step chosen option index (null = not yet chosen).
  late final List<int?> _chosen;
  // Per-step revealed (after pressing Confirm) so the user can read feedback.
  late final List<bool> _revealed;
  int _score = 0;
  bool _failedSafety = false;
  Timer? _ticker;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _chosen = List<int?>.filled(widget.scenario.steps.length, null);
    _revealed = List<bool>.filled(widget.scenario.steps.length, false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakBrief();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    TtsService.instance.stop();
    super.dispose();
  }

  void _speakBrief() {
    final s = widget.scenario;
    TtsService.instance.speak(
      'Customer brief. ${s.customerBrief} On arrival. ${s.onArrival} Safety. ${s.safetyNote}',
    );
  }

  void _speakStep() {
    final step = widget.scenario.steps[_stepIndex];
    final note = step.sceneNote == null ? '' : 'You see. ${step.sceneNote}.';
    TtsService.instance.speak('$note ${step.prompt}');
  }

  void _startSession() {
    setState(() {
      _stage = _Stage.decisions;
    });
    _speakStep();
    if (widget.scenario.timeLimitSeconds > 0) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _elapsedSeconds++);
        if (_elapsedSeconds >= widget.scenario.timeLimitSeconds) {
          _ticker?.cancel();
          _finish();
        }
      });
    }
  }

  void _selectOption(int i) {
    if (_revealed[_stepIndex]) return;
    setState(() => _chosen[_stepIndex] = i);
  }

  void _confirm() {
    final step = widget.scenario.steps[_stepIndex];
    final pick = _chosen[_stepIndex];
    if (pick == null) return;
    final option = step.options[pick];
    setState(() {
      _revealed[_stepIndex] = true;
      _score += option.pointsDelta;
      if (option.isDangerous) _failedSafety = true;
    });
    final intro = option.isCorrect
        ? 'Correct.'
        : option.isDangerous
            ? 'Critical safety error.'
            : 'Not the best action.';
    TtsService.instance.speak('$intro ${option.feedback}');
  }

  void _next() {
    if (_failedSafety) {
      _finish();
      return;
    }
    if (_stepIndex < widget.scenario.steps.length - 1) {
      setState(() => _stepIndex++);
      _speakStep();
    } else {
      _finish();
    }
  }

  void _finish() {
    _ticker?.cancel();
    setState(() => _stage = _Stage.results);
    final s = widget.scenario;
    final pct = s.maxScore == 0
        ? 0
        : ((_score.clamp(0, s.maxScore)) / s.maxScore * 100).round();
    final passed = !_failedSafety && pct >= 70;
    final intro = passed ? 'Pass.' : 'Job not passed.';
    final outcome = passed ? s.passOutcome : s.failOutcome;
    TtsService.instance
        .speak('$intro Final score $pct percent. $outcome');
  }

  String _fmtTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case _Stage.brief:
        return _buildBrief();
      case _Stage.decisions:
        return _buildDecisions();
      case _Stage.results:
        return _buildResults();
    }
  }

  Widget _buildBrief() {
    final s = widget.scenario;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.title),
        actions: [
          IconButton(
            tooltip: 'Read brief aloud',
            icon: const Icon(Icons.record_voice_over),
            onPressed: _speakBrief,
          ),
          IconButton(
            tooltip: 'Stop narration',
            icon: const Icon(Icons.stop_circle),
            onPressed: () => TtsService.instance.stop(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _BriefBlock(
            icon: Icons.headset_mic,
            title: 'Customer brief',
            body: s.customerBrief,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          _BriefBlock(
            icon: Icons.local_shipping,
            title: 'On arrival',
            body: s.onArrival,
            color: const Color(0xFF2A9D8F),
          ),
          const SizedBox(height: 10),
          _BriefBlock(
            icon: Icons.warning_amber,
            title: 'Safety note',
            body: s.safetyNote,
            color: AppColors.gas,
          ),
          const SizedBox(height: 16),
          if (s.timeLimitSeconds > 0)
            Card(
              color: AppColors.accent.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Clock: ${(s.timeLimitSeconds / 60).round()} minutes from when you press Start.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _startSession,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start the job'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisions() {
    final scenario = widget.scenario;
    final step = scenario.steps[_stepIndex];
    final pick = _chosen[_stepIndex];
    final revealed = _revealed[_stepIndex];
    final remaining = scenario.timeLimitSeconds - _elapsedSeconds;
    return Scaffold(
      appBar: AppBar(
        title: Text(scenario.title),
        actions: [
          IconButton(
            tooltip: 'Read step aloud',
            icon: const Icon(Icons.record_voice_over),
            onPressed: _speakStep,
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_stepIndex + 1) / scenario.steps.length,
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                Text(
                  'Step ${_stepIndex + 1} of ${scenario.steps.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Text('Score: $_score',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 12),
                if (scenario.timeLimitSeconds > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (remaining < 60
                              ? Colors.redAccent
                              : AppColors.primary)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer,
                            size: 14,
                            color: remaining < 60
                                ? Colors.redAccent
                                : AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          _fmtTime(remaining < 0 ? 0 : remaining),
                          style: TextStyle(
                            color: remaining < 60
                                ? Colors.redAccent
                                : AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (step.sceneNote != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.visibility,
                              color: AppColors.muted, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(step.sceneNote!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        step.prompt,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(step.options.length, (i) {
                    final opt = step.options[i];
                    final selected = pick == i;
                    Color border = Colors.black12;
                    Color? bg;
                    IconData icon = Icons.radio_button_unchecked;
                    Color iconColor = AppColors.muted;
                    if (revealed) {
                      if (opt.isCorrect) {
                        border = Colors.green;
                        bg = Colors.green.withValues(alpha: 0.08);
                        icon = Icons.check_circle;
                        iconColor = Colors.green;
                      } else if (selected && opt.isDangerous) {
                        border = Colors.red;
                        bg = Colors.red.withValues(alpha: 0.10);
                        icon = Icons.dangerous;
                        iconColor = Colors.red;
                      } else if (selected) {
                        border = Colors.redAccent;
                        bg = Colors.red.withValues(alpha: 0.05);
                        icon = Icons.cancel;
                        iconColor = Colors.redAccent;
                      }
                    } else if (selected) {
                      border = AppColors.primary;
                      bg = AppColors.primary.withValues(alpha: 0.06);
                      icon = Icons.radio_button_checked;
                      iconColor = AppColors.primary;
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _selectOption(i),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bg ?? AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border, width: 1.4),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(icon, color: iconColor, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(opt.text,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                    if (revealed) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        opt.feedback,
                                        style: TextStyle(
                                          color: opt.isCorrect
                                              ? Colors.green.shade800
                                              : AppColors.muted,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        opt.pointsDelta >= 0
                                            ? '+${opt.pointsDelta} points'
                                            : '${opt.pointsDelta} points',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: opt.pointsDelta >= 0
                                              ? Colors.green
                                              : Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (!revealed)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: pick != null ? _confirm : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Confirm choice'),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _next,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          _stepIndex == scenario.steps.length - 1 ||
                                  _failedSafety
                              ? 'See result'
                              : 'Next decision',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final s = widget.scenario;
    final clamped = _score.clamp(0, s.maxScore);
    final pct =
        s.maxScore == 0 ? 0 : (clamped / s.maxScore * 100).round();
    final passed = !_failedSafety && pct >= 70;
    final medal = passed
        ? (pct >= 95
            ? Icons.workspace_premium
            : pct >= 80
                ? Icons.military_tech
                : Icons.emoji_events)
        : Icons.report_problem;
    final medalColor = _failedSafety
        ? Colors.red
        : passed
            ? (pct >= 95 ? Colors.amber : Colors.blueGrey)
            : Colors.orange;
    return Scaffold(
      appBar: AppBar(title: Text('${s.title} — Outcome')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: (passed ? Colors.green : Colors.redAccent)
                .withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Icon(medal, color: medalColor, size: 56),
                  const SizedBox(height: 8),
                  Text(
                    _failedSafety
                        ? 'Job stopped on safety'
                        : passed
                            ? 'Pass'
                            : 'Not passed',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score $clamped of ${s.maxScore} ($pct%)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (s.timeLimitSeconds > 0) ...[
                    const SizedBox(height: 4),
                    Text('Time taken: ${_fmtTime(_elapsedSeconds)}',
                        style:
                            Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(passed ? 'Outcome' : 'Where it went wrong',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(passed ? s.passOutcome : s.failOutcome,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Decision review',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...List.generate(s.steps.length, (i) {
            final step = s.steps[i];
            final pickIdx = _chosen[i];
            if (pickIdx == null) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Q${i + 1}. ${step.prompt}\n\nNo answer given.',
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              );
            }
            final picked = step.options[pickIdx];
            final correct = step.options.firstWhere(
              (o) => o.isCorrect,
              orElse: () => step.options.first,
            );
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          picked.isCorrect
                              ? Icons.check_circle
                              : (picked.isDangerous
                                  ? Icons.dangerous
                                  : Icons.cancel),
                          color: picked.isCorrect
                              ? Colors.green
                              : (picked.isDangerous
                                  ? Colors.red
                                  : Colors.redAccent),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Step ${i + 1}. ${step.prompt}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('You chose: ${picked.text}',
                        style: TextStyle(
                          color: picked.isCorrect
                              ? Colors.green
                              : Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 4),
                    Text(picked.feedback,
                        style: Theme.of(context).textTheme.bodyMedium),
                    if (!picked.isCorrect) ...[
                      const SizedBox(height: 6),
                      Text('Best action: ${correct.text}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          ScenarioSessionScreen(scenario: widget.scenario),
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.list),
                  label: const Text('Back to scenarios'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BriefBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _BriefBlock({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(body,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
