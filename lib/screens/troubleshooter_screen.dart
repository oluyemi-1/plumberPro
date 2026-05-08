import 'package:flutter/material.dart';

import '../data/troubleshooting_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class TroubleshooterScreen extends StatefulWidget {
  const TroubleshooterScreen({super.key});

  @override
  State<TroubleshooterScreen> createState() => _TroubleshooterScreenState();
}

class _TroubleshooterScreenState extends State<TroubleshooterScreen> {
  final TextEditingController _search = TextEditingController();
  String _selectedSystem = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> get _systems {
    final set = <String>{};
    for (final c in troubleCases) {
      set.add(c.system);
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  List<TroubleCase> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return troubleCases.where((c) {
      final matchesSystem =
          _selectedSystem == 'All' || c.system == _selectedSystem;
      final matchesQuery = q.isEmpty || c.symptom.toLowerCase().contains(q);
      return matchesSystem && matchesQuery;
    }).toList();
  }

  Color _systemColor(String system) {
    switch (system) {
      case 'Hot water':
        return AppColors.hotWater;
      case 'Heating':
        return AppColors.accent;
      case 'Taps':
        return AppColors.coldWater;
      case 'Drainage':
        return AppColors.waste;
      case 'Boiler':
        return AppColors.gas;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cases = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Troubleshooter'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by symptom...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              itemCount: _systems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = _systems[i];
                return ChoiceChip(
                  label: Text(s),
                  selected: _selectedSystem == s,
                  onSelected: (_) => setState(() => _selectedSystem = s),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: _selectedSystem == s
                        ? AppColors.primary
                        : AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: cases.isEmpty
                ? Center(
                    child: Text(
                      'No matching cases',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                    itemCount: cases.length,
                    itemBuilder: (_, i) {
                      final c = cases[i];
                      final color = _systemColor(c.system);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    _TroubleCaseDetailScreen(caseItem: c),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.build_circle, color: color),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.symptom,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          c.system,
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.muted),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TroubleCaseDetailScreen extends StatelessWidget {
  final TroubleCase caseItem;
  const _TroubleCaseDetailScreen({required this.caseItem});

  @override
  Widget build(BuildContext context) {
    final t = caseItem;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.system),
        actions: [
          IconButton(
            tooltip: 'Read full case',
            icon: const Icon(Icons.record_voice_over),
            onPressed: () => TtsService.instance.speak(t.narration),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Symptom',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(t.symptom,
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _Section(
            title: 'Likely causes',
            icon: Icons.help_outline,
            color: AppColors.primary,
            numbered: false,
            items: t.likelyCauses,
            speakText:
                'Likely causes. ${t.likelyCauses.join(". ")}',
          ),
          const SizedBox(height: 10),
          _Section(
            title: 'Diagnostic steps',
            icon: Icons.search,
            color: AppColors.coldWater,
            numbered: true,
            items: t.diagnosticSteps,
            speakText:
                'Diagnostic steps. ${t.diagnosticSteps.join(". ")}',
          ),
          const SizedBox(height: 10),
          _Section(
            title: 'Fix steps',
            icon: Icons.build,
            color: AppColors.accent,
            numbered: true,
            items: t.fixSteps,
            speakText: 'Fix. ${t.fixSteps.join(". ")}',
          ),
          const SizedBox(height: 10),
          _SafetyBanner(note: t.safetyNote),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool numbered;
  final List<String> items;
  final String speakText;
  const _Section({
    required this.title,
    required this.icon,
    required this.color,
    required this.numbered,
    required this.items,
    required this.speakText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                TextButton.icon(
                  onPressed: () => TtsService.instance.speak(speakText),
                  icon: const Icon(Icons.volume_up, size: 18),
                  label: const Text('Read aloud'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...List.generate(items.length, (i) {
              final marker = numbered ? '${i + 1}. ' : '• ';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        marker,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(items[i],
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SafetyBanner extends StatelessWidget {
  final String note;
  const _SafetyBanner({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gas.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gas, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.gas, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Safety note',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.text)),
                const SizedBox(height: 4),
                Text(note,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Read aloud',
            icon: const Icon(Icons.volume_up),
            color: AppColors.primaryDark,
            onPressed: () =>
                TtsService.instance.speak('Safety note. $note'),
          ),
        ],
      ),
    );
  }
}
