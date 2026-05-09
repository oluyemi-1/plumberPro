import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/l8_risk_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class L8RiskScreen extends StatefulWidget {
  const L8RiskScreen({super.key});

  @override
  State<L8RiskScreen> createState() => _L8RiskScreenState();
}

class _L8RiskScreenState extends State<L8RiskScreen> {
  static const _prefsKey = 'l8_answers_v1';

  // key 'cat_q' -> selected option index
  final Map<String, int> _answers = {};
  final Set<int> _expanded = {0};
  bool _loaded = false;

  int get _totalQuestions =>
      l8Categories.fold(0, (sum, c) => sum + c.questions.length);

  int get _answeredCount => _answers.length;

  int get _totalScore {
    var score = 0;
    for (var ci = 0; ci < l8Categories.length; ci++) {
      final cat = l8Categories[ci];
      for (var qi = 0; qi < cat.questions.length; qi++) {
        final key = '${ci}_$qi';
        final idx = _answers[key];
        if (idx != null && idx < cat.questions[qi].options.length) {
          score += cat.questions[qi].options[idx].score;
        }
      }
    }
    return score;
  }

  String get _band {
    final s = _totalScore;
    if (s <= 20) return 'LOW';
    if (s <= 45) return 'MEDIUM';
    return 'HIGH';
  }

  Color get _bandColor {
    switch (_band) {
      case 'LOW':
        return const Color(0xFF2E7D32);
      case 'MEDIUM':
        return const Color(0xFFE6A700);
      default:
        return const Color(0xFFC62828);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as Map<String, dynamic>;
        _answers
          ..clear()
          ..addEntries(decoded.entries.map((e) => MapEntry(e.key, e.value as int)));
      } catch (_) {
        // ignore corrupt prefs
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, json.encode(_answers));
  }

  void _select(int catIdx, int qIdx, int optIdx) {
    setState(() {
      _answers['${catIdx}_$qIdx'] = optIdx;
    });
    _save();
  }

  Future<void> _restart() async {
    setState(() => _answers.clear());
    await _save();
  }

  Future<void> _speakHighRisk() async {
    final tts = TtsService.instance;
    final lines = <String>['L8 high risk findings.'];
    for (var ci = 0; ci < l8Categories.length; ci++) {
      final cat = l8Categories[ci];
      for (var qi = 0; qi < cat.questions.length; qi++) {
        final idx = _answers['${ci}_$qi'];
        if (idx == null) continue;
        final opt = cat.questions[qi].options[idx];
        if (opt.score >= 3) {
          lines.add('${cat.name}. ${cat.questions[qi].question}. ${opt.speakable}');
        }
      }
    }
    if (lines.length == 1) {
      lines.add('No high risk answers recorded.');
    }
    await tts.stop();
    await tts.speak(lines.join(' '));
  }

  void _showReport() {
    final findings = <_Finding>[];
    for (var ci = 0; ci < l8Categories.length; ci++) {
      final cat = l8Categories[ci];
      for (var qi = 0; qi < cat.questions.length; qi++) {
        final idx = _answers['${ci}_$qi'];
        if (idx == null) continue;
        final opt = cat.questions[qi].options[idx];
        if (opt.score >= 3) {
          findings.add(_Finding(
            category: cat.name,
            question: cat.questions[qi].question,
            option: opt,
          ));
        }
      }
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('L8 risk report'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _bandColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _bandColor),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$_totalScore',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _bandColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Band: $_band',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _bandColor,
                                )),
                            Text('$_answeredCount of $_totalQuestions answered'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'High risk findings (${findings.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (findings.isEmpty)
                  const Text('No findings scored 3 or 4. Continue routine monitoring.'),
                for (final f in findings) ...[
                  const Divider(),
                  Text(f.category,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: AppColors.accent)),
                  Text(f.question),
                  const SizedBox(height: 4),
                  Text('Answer: ${f.option.label} (score ${f.option.score})',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(f.option.guidance,
                      style: const TextStyle(color: AppColors.muted)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('L8 water hygiene risk assessment'),
        actions: [
          IconButton(
            tooltip: 'Speak high risk findings',
            icon: const Icon(Icons.record_voice_over),
            onPressed: _speakHighRisk,
          ),
          IconButton(
            tooltip: 'Restart assessment',
            icon: const Icon(Icons.restart_alt),
            onPressed: _restart,
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _ScoreBanner(
                  score: _totalScore,
                  band: _band,
                  bandColor: _bandColor,
                  answered: _answeredCount,
                  total: _totalQuestions,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: l8Categories.length,
                    itemBuilder: (context, ci) {
                      final cat = l8Categories[ci];
                      final isExpanded = _expanded.contains(ci);
                      return Card(
                        color: AppColors.cardBg,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(cat.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.text)),
                              subtitle: Text(
                                _categorySummary(ci),
                                style: const TextStyle(color: AppColors.muted),
                              ),
                              trailing: Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppColors.text,
                              ),
                              onTap: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expanded.remove(ci);
                                  } else {
                                    _expanded.add(ci);
                                  }
                                });
                              },
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                child: Column(
                                  children: [
                                    for (var qi = 0;
                                        qi < cat.questions.length;
                                        qi++)
                                      _QuestionTile(
                                        question: cat.questions[qi],
                                        selectedIndex:
                                            _answers['${ci}_$qi'],
                                        onSelect: (i) => _select(ci, qi, i),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _showReport,
                        icon: const Icon(Icons.assignment_outlined),
                        label: const Text('Generate report'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _categorySummary(int ci) {
    final cat = l8Categories[ci];
    var answered = 0;
    var score = 0;
    for (var qi = 0; qi < cat.questions.length; qi++) {
      final idx = _answers['${ci}_$qi'];
      if (idx != null) {
        answered++;
        score += cat.questions[qi].options[idx].score;
      }
    }
    return '$answered / ${cat.questions.length} answered, score $score';
  }
}

class _Finding {
  final String category;
  final String question;
  final L8RiskOption option;
  _Finding(
      {required this.category, required this.question, required this.option});
}

class _ScoreBanner extends StatelessWidget {
  final int score;
  final String band;
  final Color bandColor;
  final int answered;
  final int total;

  const _ScoreBanner({
    required this.score,
    required this.band,
    required this.bandColor,
    required this.answered,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bandColor.withValues(alpha: 0.18),
        border: Border(bottom: BorderSide(color: bandColor, width: 2)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bandColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$score',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$band risk',
                    style: TextStyle(
                        color: bandColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('$answered of $total questions answered',
                    style: const TextStyle(color: AppColors.text)),
                const SizedBox(height: 2),
                const Text('Bands: 0-20 LOW, 21-45 MEDIUM, 46-80 HIGH',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final L8RiskQuestion question;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _QuestionTile({
    required this.question,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Text(question.question,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.text)),
          ),
          RadioGroup<int>(
            groupValue: selectedIndex,
            onChanged: (v) {
              if (v != null) onSelect(v);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < question.options.length; i++)
                  RadioListTile<int>(
                    dense: true,
                    value: i,
                    title: Text(question.options[i].label,
                        style: const TextStyle(color: AppColors.text)),
                    subtitle: Text(
                      'Score ${question.options[i].score} - ${question.options[i].guidance}',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12),
                    ),
                    activeColor: AppColors.accent,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
