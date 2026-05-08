import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/synoptic_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

enum _Phase { brief, running, results, expired }

/// A timed running session through one [SynopticAssessment]. Begins on the
/// scenario brief, then steps through each task, then shows a results page
/// with a per-task review and persists the best score.
class SynopticSessionScreen extends StatefulWidget {
  final SynopticAssessment assessment;
  const SynopticSessionScreen({super.key, required this.assessment});

  @override
  State<SynopticSessionScreen> createState() => _SynopticSessionScreenState();
}

class _SynopticSessionScreenState extends State<SynopticSessionScreen> {
  _Phase _phase = _Phase.brief;
  int _index = 0;

  // Stored answers — mc: int index; calc: double or null; freeText: String.
  late final List<dynamic> _answers;
  Timer? _timer;
  int _remainingSeconds = 0;

  final TextEditingController _calcController = TextEditingController();
  final TextEditingController _freeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _answers = List<dynamic>.filled(widget.assessment.tasks.length, null);
    _remainingSeconds = widget.assessment.timeLimitMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _calcController.dispose();
    _freeController.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  void _start() {
    setState(() {
      _phase = _Phase.running;
      _index = 0;
    });
    _startTimer();
    _loadCurrentAnswerToControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrent());
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        _onTimeExpired();
      }
    });
  }

  void _onTimeExpired() {
    if (!mounted) return;
    _captureCurrentAnswer();
    setState(() => _phase = _Phase.expired);
    _finalise();
  }

  void _speakCurrent() {
    final task = widget.assessment.tasks[_index];
    TtsService.instance.speak('Task ${_index + 1}. ${task.prompt}');
  }

  void _loadCurrentAnswerToControllers() {
    final task = widget.assessment.tasks[_index];
    final ans = _answers[_index];
    switch (task.type) {
      case SynopticTaskType.calculation:
        _calcController.text = ans is double ? ans.toString() : '';
        break;
      case SynopticTaskType.freeText:
        _freeController.text = ans is String ? ans : '';
        break;
      case SynopticTaskType.multipleChoice:
        break;
    }
  }

  void _captureCurrentAnswer() {
    final task = widget.assessment.tasks[_index];
    switch (task.type) {
      case SynopticTaskType.calculation:
        final parsed = double.tryParse(_calcController.text.trim());
        _answers[_index] = parsed;
        break;
      case SynopticTaskType.freeText:
        _answers[_index] = _freeController.text.trim();
        break;
      case SynopticTaskType.multipleChoice:
        // Already stored on tap.
        break;
    }
  }

  void _selectChoice(int i) {
    setState(() => _answers[_index] = i);
  }

  void _next() {
    _captureCurrentAnswer();
    if (_index < widget.assessment.tasks.length - 1) {
      setState(() => _index++);
      _loadCurrentAnswerToControllers();
      _speakCurrent();
    } else {
      _timer?.cancel();
      setState(() => _phase = _Phase.results);
      _finalise();
    }
  }

  void _previous() {
    _captureCurrentAnswer();
    if (_index > 0) {
      setState(() => _index--);
      _loadCurrentAnswerToControllers();
      _speakCurrent();
    }
  }

  int _marksFor(int i) {
    final task = widget.assessment.tasks[i];
    final ans = _answers[i];
    switch (task.type) {
      case SynopticTaskType.multipleChoice:
        if (ans is int && ans == task.correctIndex) return task.marks;
        return 0;
      case SynopticTaskType.calculation:
        if (ans is double &&
            task.expectedValue != null &&
            task.tolerance != null) {
          if ((ans - task.expectedValue!).abs() <= task.tolerance!) {
            return task.marks;
          }
        }
        return 0;
      case SynopticTaskType.freeText:
        // Partial marks if non-empty: half (rounded up), full only on review.
        if (ans is String && ans.trim().isNotEmpty) {
          // Award half marks rounded up for any non-empty effort.
          return (task.marks / 2).ceil();
        }
        return 0;
    }
  }

  int get _totalCorrectMarks {
    int total = 0;
    for (int i = 0; i < widget.assessment.tasks.length; i++) {
      total += _marksFor(i);
    }
    return total;
  }

  Future<void> _finalise() async {
    final correct = _totalCorrectMarks;
    final total = widget.assessment.totalMarks;
    final pct = total == 0 ? 0 : ((correct / total) * 100).round();
    await TtsService.instance.speak(
      'Assessment complete. You scored $correct out of $total, $pct percent.',
    );
    final prefs = await SharedPreferences.getInstance();
    final key = 'synoptic_${widget.assessment.id}';
    final existingRaw = prefs.getString(key);
    bool storeNew = true;
    if (existingRaw != null) {
      try {
        final m = jsonDecode(existingRaw) as Map<String, dynamic>;
        final prevPct = ((m['correctMarks'] as num) /
                (m['totalMarks'] as num) *
                100)
            .round();
        if (prevPct >= pct) storeNew = false;
      } catch (_) {}
    }
    if (storeNew) {
      await prefs.setString(
        key,
        jsonEncode({
          'correctMarks': correct,
          'totalMarks': total,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == _Phase.brief) return _buildBrief(context);
    if (_phase == _Phase.results || _phase == _Phase.expired) {
      return _buildResults(context);
    }
    return _buildRunning(context);
  }

  Widget _buildBrief(BuildContext context) {
    final a = widget.assessment;
    final coverage = a.coverage.split('|').map((s) => s.trim()).toList();
    return Scaffold(
      appBar: AppBar(title: Text(a.title)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: AppColors.primary.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_late,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Scenario brief',
                          style: Theme.of(context).textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(a.scenario,
                      style: Theme.of(context).textTheme.bodyLarge),
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
                  Text('Coverage',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: coverage
                        .map((c) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.accent
                                    .withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color: AppColors.accent
                                        .withValues(alpha: 0.4)),
                              ),
                              child: Text(c,
                                  style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text('${a.timeLimitMinutes} minute time limit',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.flag, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${a.totalMarks} marks total — pass mark 70 percent',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _start,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start assessment'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => TtsService.instance.speak(a.scenario),
            icon: const Icon(Icons.record_voice_over),
            label: const Text('Read scenario aloud'),
          ),
        ],
      ),
    );
  }

  Widget _buildRunning(BuildContext context) {
    final task = widget.assessment.tasks[_index];
    final lowTime = _remainingSeconds <= 60;
    return Scaffold(
      appBar: AppBar(
        title: Text('Task ${_index + 1} of ${widget.assessment.tasks.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (lowTime ? AppColors.hotWater : Colors.white)
                      .withValues(alpha: lowTime ? 0.85 : 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Read prompt aloud',
            icon: const Icon(Icons.record_voice_over),
            onPressed: _speakCurrent,
          ),
          IconButton(
            tooltip: 'Stop narration',
            icon: const Icon(Icons.stop_circle),
            onPressed: () => TtsService.instance.stop(),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / widget.assessment.tasks.length,
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _TaskTypeChip(type: task.type),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${task.marks} ${task.marks == 1 ? "mark" : "marks"}',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(task.prompt,
                              style:
                                  Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAnswerInput(task),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _index == 0 ? null : _previous,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _next,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        _index == widget.assessment.tasks.length - 1
                            ? 'Finish'
                            : 'Next',
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

  Widget _buildAnswerInput(SynopticTask task) {
    switch (task.type) {
      case SynopticTaskType.multipleChoice:
        final selected = _answers[_index] is int
            ? _answers[_index] as int
            : null;
        final choices = task.choices ?? const <String>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(choices.length, (i) {
            final isSelected = selected == i;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _selectChoice(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.07)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.black12,
                      width: 1.4,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.cardBg,
                        child: Text(
                          String.fromCharCode(65 + i),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(choices[i],
                            style:
                                Theme.of(context).textTheme.bodyLarge),
                      ),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      case SynopticTaskType.calculation:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Numeric answer',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _calcController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: false),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter your calculated value',
                    suffixText: task.unit ?? '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tolerance ±${task.tolerance ?? 0} ${task.unit ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      case SynopticTaskType.freeText:
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Written answer',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _freeController,
                  maxLines: 5,
                  minLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Type your response here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A non-empty answer scores partial marks. Full marks are '
                  'awarded on review of an appropriate response.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildResults(BuildContext context) {
    final correct = _totalCorrectMarks;
    final total = widget.assessment.totalMarks;
    final pct = total == 0 ? 0 : ((correct / total) * 100).round();
    final passed = pct >= 70;
    final expired = _phase == _Phase.expired;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.assessment.title} — Results'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: (passed ? Colors.green : AppColors.gas)
                .withValues(alpha: 0.10),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Icon(
                    passed ? Icons.workspace_premium : Icons.flag,
                    color: passed ? Colors.green : AppColors.gas,
                    size: 56,
                  ),
                  const SizedBox(height: 8),
                  Text('$correct / $total marks',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text('$pct%',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    expired
                        ? 'Time expired — auto-submitted'
                        : (passed
                            ? 'Pass — well done'
                            : 'Below pass mark of 70 percent'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Per-task review',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...List.generate(widget.assessment.tasks.length, (i) {
            return _ReviewCard(
              index: i,
              task: widget.assessment.tasks[i],
              answer: _answers[i],
              awarded: _marksFor(i),
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.list),
                  label: const Text('Back to assessments'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskTypeChip extends StatelessWidget {
  final SynopticTaskType type;
  const _TaskTypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      SynopticTaskType.multipleChoice => 'Multiple choice',
      SynopticTaskType.calculation => 'Calculation',
      SynopticTaskType.freeText => 'Free text',
    };
    final color = switch (type) {
      SynopticTaskType.multipleChoice => AppColors.coldWater,
      SynopticTaskType.calculation => AppColors.accent,
      SynopticTaskType.freeText => AppColors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int index;
  final SynopticTask task;
  final dynamic answer;
  final int awarded;
  const _ReviewCard({
    required this.index,
    required this.task,
    required this.answer,
    required this.awarded,
  });

  @override
  Widget build(BuildContext context) {
    final fullMarks = awarded == task.marks && task.marks > 0;
    final partial = awarded > 0 && awarded < task.marks;
    final iconColor = fullMarks
        ? Colors.green
        : (partial ? AppColors.gas : Colors.redAccent);
    final iconData = fullMarks
        ? Icons.check_circle
        : (partial ? Icons.adjust : Icons.cancel);

    String chosenText;
    String correctText;
    switch (task.type) {
      case SynopticTaskType.multipleChoice:
        final choices = task.choices ?? const <String>[];
        if (answer is int && answer >= 0 && answer < choices.length) {
          chosenText = choices[answer];
        } else {
          chosenText = 'No answer given';
        }
        if (task.correctIndex != null &&
            task.correctIndex! >= 0 &&
            task.correctIndex! < choices.length) {
          correctText = choices[task.correctIndex!];
        } else {
          correctText = '';
        }
        break;
      case SynopticTaskType.calculation:
        chosenText = answer is double
            ? '${(answer as double)} ${task.unit ?? ''}'
            : 'No answer given';
        correctText =
            '${task.expectedValue} ${task.unit ?? ''} (±${task.tolerance})';
        break;
      case SynopticTaskType.freeText:
        chosenText = (answer is String && (answer as String).trim().isNotEmpty)
            ? answer as String
            : 'No answer given';
        correctText = 'See explanation below';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Task ${index + 1}. ${task.prompt}',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text('$awarded/${task.marks}',
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            _LabelledLine(
              label: 'Your answer',
              value: chosenText,
              color: fullMarks ? Colors.green : AppColors.text,
            ),
            const SizedBox(height: 4),
            if (task.type != SynopticTaskType.freeText)
              _LabelledLine(
                label: 'Correct',
                value: correctText,
                color: Colors.green.shade800,
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb,
                      color: AppColors.gas, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(task.explanation,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelledLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _LabelledLine({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: value,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}
