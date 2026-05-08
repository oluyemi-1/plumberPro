import 'package:flutter/material.dart';

import '../data/g99_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

/// A three-tab reference screen that walks the user through the DNO
/// notification process: a decision tree to choose G98 vs G99 and detailed
/// stage cards for each route.
class G99ProcessScreen extends StatefulWidget {
  const G99ProcessScreen({super.key});

  @override
  State<G99ProcessScreen> createState() => _G99ProcessScreenState();
}

class _G99ProcessScreenState extends State<G99ProcessScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('G98 / G99 DNO process'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Decision'),
            Tab(text: 'G98 path'),
            Tab(text: 'G99 path'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _DecisionTab(),
          _StagesTab(stages: g98Stages, accent: AppColors.coldWater),
          _StagesTab(stages: g99Stages, accent: AppColors.accent),
        ],
      ),
    );
  }
}

/// Walks the user through the decision-tree questions one at a time and
/// records their answers. The trace at the end summarises the path and gives
/// a final recommendation of G98 or G99.
class _DecisionTab extends StatefulWidget {
  const _DecisionTab();

  @override
  State<_DecisionTab> createState() => _DecisionTabState();
}

class _DecisionTabState extends State<_DecisionTab> {
  int _index = 0;
  final List<bool> _answers = [];
  final List<String> _trace = [];

  void _answer(bool yes) {
    final q = decisionTree[_index];
    setState(() {
      _answers.add(yes);
      _trace.add(yes ? q.yesPath : q.noPath);
      _index++;
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _answers.clear();
      _trace.clear();
    });
  }

  String _recommendation() {
    // Heuristic: any "yes" that pushes towards G99 wording in the canonical
    // tree means the answer is G99. We look for keywords in the trace.
    final lower = _trace.map((s) => s.toLowerCase()).join(' ');
    if (lower.contains('g99') || lower.contains('always g99')) {
      return 'G99 application required';
    }
    if (lower.contains('no dno notification')) {
      return 'No DNO notification required';
    }
    return 'G98 connect-and-notify route';
  }

  Color _recColour(String rec) {
    if (rec.startsWith('G99')) return AppColors.accent;
    if (rec.startsWith('G98')) return AppColors.coldWater;
    return AppColors.muted;
  }

  @override
  Widget build(BuildContext context) {
    final done = _index >= decisionTree.length;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_tree,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Decision tree',
                          style: theme.textTheme.titleMedium),
                      const Spacer(),
                      Text('Q${_index.clamp(0, decisionTree.length)} '
                          'of ${decisionTree.length}',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Answer the questions below to find out whether your '
                    'project needs the G98 fast-track route or the full G99 '
                    'application.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!done)
            Card(
              color: AppColors.cardBg,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Question ${_index + 1}',
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(decisionTree[_index].question,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: () => _answer(true),
                          icon: const Icon(Icons.check),
                          label: const Text('Yes'),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          onPressed: () => _answer(false),
                          icon: const Icon(Icons.close),
                          label: const Text('No'),
                        ),
                        TextButton.icon(
                          onPressed: () => TtsService.instance
                              .speak(decisionTree[_index].question),
                          icon: const Icon(Icons.record_voice_over),
                          label: const Text('Speak'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              color: _recColour(_recommendation()).withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recommendation',
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(_recommendation(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: _recColour(_recommendation()),
                        )),
                    const SizedBox(height: 8),
                    Text(
                      'Based on your answers, follow the steps in the '
                      'matching tab above.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _restart,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Start over'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () => TtsService.instance.speak(
                              'Recommendation. ${_recommendation()}.'),
                          icon: const Icon(Icons.record_voice_over),
                          label: const Text('Speak result'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (_trace.isNotEmpty) ...[
            Text('Your path so far',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            ...List.generate(_trace.length, (i) {
              final yes = _answers[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: yes
                        ? AppColors.primary
                        : AppColors.muted,
                    child: Icon(
                      yes ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: Text(decisionTree[i].question,
                      style: theme.textTheme.bodyMedium),
                  subtitle: Text(_trace[i]),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

/// Lists each stage in the chosen route as a card with a documents bullet
/// list and a Speak button that reads the stage out using the TTS service.
class _StagesTab extends StatelessWidget {
  final List<GxxStage> stages;
  final Color accent;
  const _StagesTab({required this.stages, required this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stages.length,
      itemBuilder: (_, i) {
        final s = stages[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text('${i + 1}',
                          style: TextStyle(
                              color: accent, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(s.title,
                          style: theme.textTheme.titleMedium),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(s.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Documents needed',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          )),
                      const SizedBox(height: 4),
                      ...s.documents.map(
                        (d) => Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 6, right: 6),
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(d,
                                    style: theme.textTheme.bodyMedium),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          TtsService.instance.speak(s.speakable),
                      icon: const Icon(Icons.record_voice_over),
                      label: const Text('Speak'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => TtsService.instance.stop(),
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
