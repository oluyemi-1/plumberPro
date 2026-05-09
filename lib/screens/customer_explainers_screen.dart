import 'package:flutter/material.dart';

import '../data/explainers_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class CustomerExplainersScreen extends StatefulWidget {
  const CustomerExplainersScreen({super.key});

  @override
  State<CustomerExplainersScreen> createState() =>
      _CustomerExplainersScreenState();
}

class _CustomerExplainersScreenState extends State<CustomerExplainersScreen> {
  String _selectedCategory = 'All';

  List<String> get _categories {
    final set = <String>{for (final e in customerExplainers) e.category};
    return ['All', ...set.toList()..sort()];
  }

  List<CustomerExplainer> get _filtered {
    if (_selectedCategory == 'All') return customerExplainers;
    return customerExplainers
        .where((e) => e.category == _selectedCategory)
        .toList();
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Heating':
        return AppColors.hotWater;
      case 'Hot water':
        return AppColors.accent;
      case 'Drainage':
        return AppColors.waste;
      case 'Boiler':
        return AppColors.primary;
      case 'Tap':
        return AppColors.coldWater;
      case 'Survey':
        return AppColors.brass;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer explainers')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in _categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: _selectedCategory == c,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = c),
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.18),
                        labelStyle: TextStyle(
                          color: _selectedCategory == c
                              ? AppColors.primaryDark
                              : AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final e = _filtered[i];
                final color = _categoryColor(e.category);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _ExplainerDetailScreen(explainer: e),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    e.category,
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  e.oneLine,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _PlayBigButton(
                            onTap: () =>
                                TtsService.instance.speak(e.script),
                          ),
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

class _PlayBigButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PlayBigButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.play_arrow_rounded,
              color: Colors.white, size: 34),
        ),
      ),
    );
  }
}

class _ExplainerDetailScreen extends StatefulWidget {
  final CustomerExplainer explainer;
  const _ExplainerDetailScreen({required this.explainer});

  @override
  State<_ExplainerDetailScreen> createState() => _ExplainerDetailScreenState();
}

class _ExplainerDetailScreenState extends State<_ExplainerDetailScreen> {
  bool _slowMode = false;
  double _previousRate = 0.48;

  @override
  void initState() {
    super.initState();
    _previousRate = TtsService.instance.rate;
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    if (_slowMode) {
      TtsService.instance.setRate(_previousRate);
    }
    super.dispose();
  }

  Future<void> _toggleSlow(bool value) async {
    setState(() => _slowMode = value);
    if (value) {
      _previousRate = TtsService.instance.rate;
      await TtsService.instance.setRate(0.35);
    } else {
      await TtsService.instance.setRate(_previousRate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.explainer;
    return Scaffold(
      appBar: AppBar(title: const Text('Explainer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                e.category,
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () =>
                              TtsService.instance.speak(e.script),
                          icon: const Icon(Icons.volume_up_rounded),
                          label: const Text('Speak'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => TtsService.instance.stop(),
                          icon: const Icon(Icons.stop_rounded),
                          label: const Text('Stop'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Slow mode'),
                      subtitle: const Text(
                          'Reads more slowly so the customer can follow.'),
                      value: _slowMode,
                      activeThumbColor: AppColors.primary,
                      onChanged: _toggleSlow,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  e.script,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
