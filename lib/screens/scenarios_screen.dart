import 'package:flutter/material.dart';

import '../data/scenarios_data.dart';
import '../services/pro_entitlement.dart';
import '../theme.dart';
import '../widgets/pro_lock_overlay.dart';
import 'scenario_session_screen.dart';

class ScenariosScreen extends StatefulWidget {
  const ScenariosScreen({super.key});

  @override
  State<ScenariosScreen> createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen> {
  String _filter = 'All';

  List<String> get _categories {
    final s = <String>{'All'};
    for (final t in jobScenarios) {
      s.add(t.category);
    }
    return s.toList();
  }

  List<JobScenario> get _filtered {
    if (_filter == 'All') return jobScenarios;
    return jobScenarios.where((s) => s.category == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scenarios = _filtered;
    final freeScenarios =
        jobScenarios.take(ProEntitlement.freeLimit).toSet();
    return Scaffold(
      appBar: AppBar(title: const Text('Job scenarios')),
      body: AnimatedBuilder(
        animation: ProEntitlement.instance,
        builder: (context, _) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Card(
              color: AppColors.accent.withValues(alpha: 0.07),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.work_history,
                        color: AppColors.accent, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pretend you have just arrived at the job',
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Each scenario plays out as a real call-out: customer brief, on-arrival findings, decisions to make. Pick the best action at every step. Wrong choices cost points; dangerous choices fail the job.',
                            style:
                                Theme.of(context).textTheme.bodyMedium,
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
              itemCount: scenarios.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final s = scenarios[i];
                final locked = !ProEntitlement.instance.isPro &&
                    !freeScenarios.contains(s);
                return ProLockOverlay(
                  locked: locked,
                  child: _ScenarioCard(
                    scenario: s,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScenarioSessionScreen(scenario: s),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final JobScenario scenario;
  final VoidCallback onTap;
  const _ScenarioCard({required this.scenario, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        const Icon(Icons.assignment, color: AppColors.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(scenario.title,
                            style:
                                Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 6,
                          children: [
                            _Chip(scenario.category, AppColors.accent),
                            _Chip('${scenario.steps.length} steps',
                                AppColors.primary),
                            if (scenario.timeLimitSeconds > 0)
                              _Chip(
                                  '${(scenario.timeLimitSeconds / 60).round()} min clock',
                                  AppColors.gas),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                scenario.customerBrief,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
