import 'package:flutter/material.dart';

import '../data/glossary_data.dart';
import '../services/srs_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';

/// Spaced-repetition practice for the glossary. Shows a card with the term,
/// user taps to reveal the definition, then rates Hard / Got it / Easy.
/// SM-2 schedules the next due date.
class GlossaryPracticeScreen extends StatefulWidget {
  const GlossaryPracticeScreen({super.key});

  @override
  State<GlossaryPracticeScreen> createState() =>
      _GlossaryPracticeScreenState();
}

class _GlossaryPracticeScreenState extends State<GlossaryPracticeScreen> {
  late List<GlossaryTerm> _queue;
  int _index = 0;
  bool _revealed = false;
  // Tally for the session summary.
  int _hard = 0;
  int _got = 0;
  int _easy = 0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _buildQueue();
  }

  void _buildQueue() {
    final allTerms = glossary.map((g) => g.term);
    final order = SrsService.instance.dueAndNew(allTerms, newAllowance: 6);
    final byTerm = {for (final g in glossary) g.term: g};
    _queue = [
      for (final t in order)
        if (byTerm.containsKey(t)) byTerm[t]!,
    ];
  }

  GlossaryTerm? get _current =>
      (_index < _queue.length) ? _queue[_index] : null;

  Future<void> _rate(SrsRating rating) async {
    final t = _current;
    if (t == null) return;
    setState(() {
      switch (rating) {
        case SrsRating.hard:
          _hard++;
          break;
        case SrsRating.got:
          _got++;
          break;
        case SrsRating.easy:
          _easy++;
          break;
      }
    });
    await SrsService.instance.record(t.term, rating);
    if (!mounted) return;
    if (_index < _queue.length - 1) {
      setState(() {
        _index++;
        _revealed = false;
      });
    } else {
      setState(() => _completed = true);
    }
  }

  void _restart() {
    setState(() {
      _hard = 0;
      _got = 0;
      _easy = 0;
      _completed = false;
      _index = 0;
      _revealed = false;
      _buildQueue();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Glossary practice')),
        body: const _AllCaughtUp(),
      );
    }
    if (_completed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Session complete')),
        body: _Summary(
          hard: _hard,
          got: _got,
          easy: _easy,
          totalSeen: _hard + _got + _easy,
          onAgain: _restart,
        ),
      );
    }
    final t = _current!;
    final state = SrsService.instance.stateFor(t.term);
    final progress = (_index) / _queue.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glossary practice'),
        actions: [
          IconButton(
            tooltip: 'Stop narration',
            icon: const Icon(Icons.stop_circle),
            onPressed: () => TtsService.instance.stop(),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress, minHeight: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                Text('Card ${_index + 1} of ${_queue.length}',
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                if (state.isNew)
                  const _Tag(label: 'NEW', color: AppColors.primary)
                else if (state.reps >= 3)
                  const _Tag(label: 'MASTERED', color: Colors.green)
                else
                  _Tag(
                    label: 'REV ${state.reps}',
                    color: AppColors.accent,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: _Card(
                term: t,
                revealed: _revealed,
                onFlip: () {
                  setState(() => _revealed = true);
                  TtsService.instance
                      .speak('${t.term}. ${t.definition}');
                },
              ),
            ),
          ),
          _Actions(
            revealed: _revealed,
            onReveal: () {
              setState(() => _revealed = true);
              TtsService.instance.speak('${t.term}. ${t.definition}');
            },
            onRate: _rate,
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final GlossaryTerm term;
  final bool revealed;
  final VoidCallback onFlip;
  const _Card(
      {required this.term, required this.revealed, required this.onFlip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: revealed ? null : onFlip,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: revealed
                  ? [
                      AppColors.cardBg,
                      AppColors.cardBg,
                    ]
                  : [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                revealed ? 'DEFINITION' : 'TERM',
                style: TextStyle(
                  color: revealed
                      ? AppColors.muted
                      : Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                term.term,
                style: TextStyle(
                  color: revealed ? AppColors.text : Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              if (revealed)
                SelectableText(
                  term.definition,
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              else
                Text(
                  'Tap to reveal the definition.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final bool revealed;
  final VoidCallback onReveal;
  final void Function(SrsRating) onRate;
  const _Actions({
    required this.revealed,
    required this.onReveal,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    if (!revealed) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: ElevatedButton.icon(
            onPressed: onReveal,
            icon: const Icon(Icons.flip),
            label: const Text('Reveal definition'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      );
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: _RateButton(
                color: Colors.redAccent,
                icon: Icons.thumb_down_alt_outlined,
                label: 'Hard',
                hint: 'Tomorrow',
                onTap: () => onRate(SrsRating.hard),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RateButton(
                color: AppColors.primary,
                icon: Icons.thumb_up_alt_outlined,
                label: 'Got it',
                hint: 'In a few days',
                onTap: () => onRate(SrsRating.got),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RateButton(
                color: Colors.green,
                icon: Icons.bolt,
                label: 'Easy',
                hint: 'Much later',
                onTap: () => onRate(SrsRating.easy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;
  const _RateButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
            Text(hint,
                style: TextStyle(
                    color: color.withValues(alpha: 0.8), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

class _AllCaughtUp extends StatelessWidget {
  const _AllCaughtUp();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.green, size: 64),
            const SizedBox(height: 8),
            Text('All caught up',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'No cards are due today and no new terms remain. Come back tomorrow.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final int hard;
  final int got;
  final int easy;
  final int totalSeen;
  final VoidCallback onAgain;
  const _Summary({
    required this.hard,
    required this.got,
    required this.easy,
    required this.totalSeen,
    required this.onAgain,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Card(
          color: Colors.green.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const Icon(Icons.task_alt,
                    color: Colors.green, size: 56),
                const SizedBox(height: 8),
                Text('$totalSeen cards reviewed',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                const Text('Great session — your schedule has been updated.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _row(context, 'Hard', hard, Colors.redAccent),
                _row(context, 'Got it', got, AppColors.primary),
                _row(context, 'Easy', easy, Colors.green),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onAgain,
                icon: const Icon(Icons.refresh),
                label: const Text('Practise more'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.menu_book),
                label: const Text('Back to glossary'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String label, int n, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(
          width: 14,
          height: 14,
          decoration:
              BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
        Text('$n',
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
