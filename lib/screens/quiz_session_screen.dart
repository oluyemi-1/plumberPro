import 'package:flutter/material.dart';

import '../data/quiz_data.dart';
import '../services/quiz_stats_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';

enum QuizMode { practice, exam }

class QuizSessionScreen extends StatefulWidget {
  final QuizTopic topic;
  final QuizMode mode;
  const QuizSessionScreen({
    super.key,
    required this.topic,
    required this.mode,
  });

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  int _index = 0;
  // Per-question selected answer index, or null if unanswered.
  late final List<int?> _answers;
  // Whether the user has confirmed each answer in practice mode.
  late final List<bool> _revealed;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.topic.questions.length, null);
    _revealed = List<bool>.filled(widget.topic.questions.length, false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrent();
    });
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  void _speakCurrent() {
    final q = widget.topic.questions[_index];
    TtsService.instance.speak('Question ${_index + 1}. ${q.prompt}');
  }

  bool get _isPractice => widget.mode == QuizMode.practice;

  int get _correctSoFar {
    int n = 0;
    for (int i = 0; i < _answers.length; i++) {
      if (_answers[i] == widget.topic.questions[i].correctIndex) n++;
    }
    return n;
  }

  void _selectAnswer(int choice) {
    if (_isPractice && _revealed[_index]) return;
    setState(() {
      _answers[_index] = choice;
    });
  }

  void _confirmPractice() {
    if (_answers[_index] == null) return;
    setState(() {
      _revealed[_index] = true;
    });
    final q = widget.topic.questions[_index];
    final isRight = _answers[_index] == q.correctIndex;
    final intro = isRight ? 'Correct.' : 'Not quite.';
    TtsService.instance.speak('$intro ${q.explanation}');
  }

  Future<void> _next() async {
    if (_index < widget.topic.questions.length - 1) {
      setState(() => _index++);
      _speakCurrent();
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    setState(() => _completed = true);
    final correct = _correctSoFar;
    await QuizStatsService.instance.recordResult(
      widget.topic.id,
      QuizResult(
        correct: correct,
        total: widget.topic.questions.length,
        when: DateTime.now(),
      ),
    );
    final pct = (correct / widget.topic.questions.length * 100).round();
    final summary =
        'You scored $correct out of ${widget.topic.questions.length}, that is $pct percent.';
    await TtsService.instance.speak(summary);
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return _ResultsView(
        topic: widget.topic,
        answers: _answers,
        onRetry: () {
          setState(() {
            _index = 0;
            for (int i = 0; i < _answers.length; i++) {
              _answers[i] = null;
              _revealed[i] = false;
            }
            _completed = false;
          });
          _speakCurrent();
        },
      );
    }

    final q = widget.topic.questions[_index];
    final selected = _answers[_index];
    final revealed = _isPractice && _revealed[_index];
    final canConfirm = _isPractice && selected != null && !revealed;
    final canNext = !_isPractice
        ? selected != null
        : revealed || (!_isPractice && selected != null);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
        actions: [
          IconButton(
            tooltip: 'Read question aloud',
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
            value: (_index + 1) / widget.topic.questions.length,
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                Text(
                  'Question ${_index + 1} of ${widget.topic.questions.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (_isPractice ? AppColors.primary : AppColors.accent)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _isPractice ? 'Practice mode' : 'Exam mode',
                    style: TextStyle(
                      color: _isPractice ? AppColors.primary : AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        q.prompt,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(q.choices.length, (i) {
                    final isSelected = selected == i;
                    final isCorrect = i == q.correctIndex;
                    Color? bg;
                    Color border = Colors.black12;
                    IconData? trailing;
                    Color trailingColor = AppColors.muted;
                    if (revealed) {
                      if (isCorrect) {
                        bg = Colors.green.withValues(alpha: 0.10);
                        border = Colors.green;
                        trailing = Icons.check_circle;
                        trailingColor = Colors.green;
                      } else if (isSelected) {
                        bg = Colors.red.withValues(alpha: 0.08);
                        border = Colors.redAccent;
                        trailing = Icons.cancel;
                        trailingColor = Colors.redAccent;
                      }
                    } else if (isSelected) {
                      bg = AppColors.primary.withValues(alpha: 0.07);
                      border = AppColors.primary;
                      trailing = Icons.radio_button_checked;
                      trailingColor = AppColors.primary;
                    } else {
                      trailing = Icons.radio_button_unchecked;
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _selectAnswer(i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: bg ?? AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border, width: 1.4),
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
                                child: Text(
                                  q.choices[i],
                                  style:
                                      Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              if (trailing != null)
                                Icon(trailing, color: trailingColor),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  if (revealed) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(
                              selected == q.correctIndex
                                  ? Icons.check_circle
                                  : Icons.lightbulb,
                              color: selected == q.correctIndex
                                  ? Colors.green
                                  : AppColors.gas,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              selected == q.correctIndex
                                  ? 'Correct'
                                  : 'Explanation',
                              style:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                          ]),
                          const SizedBox(height: 6),
                          Text(q.explanation,
                              style:
                                  Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (_isPractice && !revealed)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canConfirm ? _confirmPractice : null,
                        icon: const Icon(Icons.check),
                        label: const Text('Check answer'),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canNext ? _next : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          _index == widget.topic.questions.length - 1
                              ? 'Finish'
                              : 'Next question',
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
}

class _ResultsView extends StatelessWidget {
  final QuizTopic topic;
  final List<int?> answers;
  final VoidCallback onRetry;
  const _ResultsView({
    required this.topic,
    required this.answers,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    int correct = 0;
    for (int i = 0; i < topic.questions.length; i++) {
      if (answers[i] == topic.questions[i].correctIndex) correct++;
    }
    final percent = (correct / topic.questions.length * 100).round();
    final medal = percent >= 90
        ? Icons.workspace_premium
        : percent >= 70
            ? Icons.military_tech
            : Icons.flag;
    final medalColor = percent >= 90
        ? Colors.amber
        : percent >= 70
            ? Colors.blueGrey
            : AppColors.muted;
    final verdict = percent == 100
        ? 'Outstanding'
        : percent >= 90
            ? 'Excellent'
            : percent >= 70
                ? 'Good — review the misses below'
                : percent >= 50
                    ? 'Getting there — keep going'
                    : 'Time to revise this topic';

    return Scaffold(
      appBar: AppBar(title: Text('${topic.title} — Results')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: AppColors.primary.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Icon(medal, color: medalColor, size: 56),
                  const SizedBox(height: 10),
                  Text('$correct / ${topic.questions.length}',
                      style:
                          Theme.of(context).textTheme.headlineSmall),
                  Text('$percent%',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(verdict,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Review',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          ...List.generate(topic.questions.length, (i) {
            final q = topic.questions[i];
            final ans = answers[i];
            final right = ans == q.correctIndex;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          right ? Icons.check_circle : Icons.cancel,
                          color: right ? Colors.green : Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Q${i + 1}. ${q.prompt}',
                            style:
                                Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (ans != null && !right)
                      Text(
                        'Your answer: ${q.choices[ans]}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    if (ans == null)
                      const Text('No answer given',
                          style: TextStyle(color: AppColors.muted)),
                    Text(
                      'Correct: ${q.correctAnswer}',
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(q.explanation,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.list),
                  label: const Text('Back to topics'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
