import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/checklists_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class ChecklistsScreen extends StatefulWidget {
  const ChecklistsScreen({super.key});

  @override
  State<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends State<ChecklistsScreen> {
  String _selectedCategory = 'All';

  List<String> get _categories {
    final set = <String>{for (final c in jobChecklists) c.category};
    return ['All', ...set];
  }

  List<JobChecklist> get _filtered {
    if (_selectedCategory == 'All') return jobChecklists;
    return jobChecklists
        .where((c) => c.category == _selectedCategory)
        .toList();
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Boiler':
        return AppColors.gas;
      case 'Hot water':
        return AppColors.hotWater;
      case 'Heating':
        return AppColors.primary;
      case 'Bathroom':
        return AppColors.coldWater;
      case 'Drainage':
        return AppColors.waste;
      case 'Survey':
        return AppColors.accent;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('Pre-job checklists')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
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
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final job = filtered[index];
                final color = _categoryColor(job.category);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChecklistDetailScreen(checklist: job),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  job.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  job.category,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.summary,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.checklist,
                                  size: 16, color: AppColors.muted),
                              const SizedBox(width: 6),
                              Text(
                                '${job.totalItems} items, ${job.sections.length} sections',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.muted),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.muted),
                            ],
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

class ChecklistDetailScreen extends StatefulWidget {
  final JobChecklist checklist;
  const ChecklistDetailScreen({super.key, required this.checklist});

  @override
  State<ChecklistDetailScreen> createState() => _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends State<ChecklistDetailScreen> {
  final Set<int> _completed = <int>{};
  bool _loaded = false;

  String get _storageKey => 'checklist_${widget.checklist.id}';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _completed
        ..clear()
        ..addAll(raw
            .split(',')
            .where((e) => e.isNotEmpty)
            .map((e) => int.tryParse(e))
            .whereType<int>());
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _completed.join(','));
  }

  List<ChecklistItem> get _flatItems {
    return [
      for (final s in widget.checklist.sections) ...s.items,
    ];
  }

  Future<void> _readUntickedItems() async {
    final items = _flatItems;
    final buffer = StringBuffer();
    for (var i = 0; i < items.length; i++) {
      if (!_completed.contains(i)) {
        buffer.writeln(items[i].speakable);
        buffer.writeln();
      }
    }
    final text = buffer.toString().trim();
    if (text.isEmpty) {
      await TtsService.instance
          .speak('All items are ticked. Job complete.');
    } else {
      await TtsService.instance.speak(text);
    }
  }

  Future<void> _confirmReset() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear progress?'),
        content: const Text(
            'This will untick every item in this checklist. The action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (result == true) {
      setState(_completed.clear);
      await _saveProgress();
    }
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checklist = widget.checklist;
    final total = checklist.totalItems;
    final done = _completed.length;
    final allDone = done == total && total > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(checklist.title),
        actions: [
          IconButton(
            tooltip: 'Read unticked items',
            icon: const Icon(Icons.record_voice_over),
            onPressed: _loaded ? _readUntickedItems : null,
          ),
          IconButton(
            tooltip: 'Reset progress',
            icon: const Icon(Icons.restore),
            onPressed: _loaded ? _confirmReset : null,
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context),
      bottomNavigationBar: !_loaded
          ? null
          : allDone
              ? _buildCompleteBanner()
              : _buildProgressBar(done, total),
    );
  }

  Widget _buildBody(BuildContext context) {
    final checklist = widget.checklist;
    final children = <Widget>[];
    var flatIndex = 0;

    children.add(Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        color: AppColors.cardBg,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.assignment_turned_in,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(checklist.category,
                        style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(checklist.summary,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));

    for (final section in checklist.sections) {
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 4),
        child: Text(
          section.heading,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
        ),
      ));

      for (final item in section.items) {
        final idx = flatIndex;
        flatIndex++;
        final ticked = _completed.contains(idx);
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onLongPress: () => TtsService.instance.speak(item.speakable),
              child: CheckboxListTile(
                value: ticked,
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      _completed.add(idx);
                    } else {
                      _completed.remove(idx);
                    }
                  });
                  _saveProgress();
                },
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  item.label,
                  style: TextStyle(
                    decoration:
                        ticked ? TextDecoration.lineThrough : TextDecoration.none,
                    color: ticked ? AppColors.muted : AppColors.text,
                  ),
                ),
                subtitle: item.hint == null
                    ? null
                    : Text(
                        item.hint!,
                        style: TextStyle(
                          color: AppColors.muted.withValues(alpha: 0.95),
                          fontSize: 12.5,
                        ),
                      ),
              ),
            ),
          ),
        ));
      }
    }

    children.add(const SizedBox(height: 24));
    return ListView(children: children);
  }

  Widget _buildProgressBar(int done, int total) {
    final progress = total == 0 ? 0.0 : done / total;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.muted.withValues(alpha: 0.2),
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.task_alt,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('$done of $total items complete',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteBanner() {
    const green = Color(0xFF1F9D55);
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: green.withValues(alpha: 0.12),
          border: Border(
            top: BorderSide(color: green.withValues(alpha: 0.4)),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified, color: green),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Job complete — all items ticked',
                style: TextStyle(
                  color: green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
