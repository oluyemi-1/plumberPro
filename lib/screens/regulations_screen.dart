import 'package:flutter/material.dart';

import '../data/regulations_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class RegulationsScreen extends StatefulWidget {
  const RegulationsScreen({super.key});

  @override
  State<RegulationsScreen> createState() => _RegulationsScreenState();
}

class _RegulationsScreenState extends State<RegulationsScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String _category = 'All';

  static const _categories = [
    'All',
    'Building',
    'Water',
    'Gas',
    'Electrical',
    'Standards',
  ];

  @override
  void dispose() {
    _search.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  List<RegulationEntry> get _filtered {
    final q = _query.trim().toLowerCase();
    return regulationEntries.where((r) {
      final matchesCat = _category == 'All' || r.category == _category;
      final matchesQ = q.isEmpty ||
          r.code.toLowerCase().contains(q) ||
          r.topic.toLowerCase().contains(q);
      return matchesCat && matchesQ;
    }).toList();
  }

  Color _categoryColor(String c) {
    switch (c) {
      case 'Water':
        return AppColors.coldWater;
      case 'Gas':
        return AppColors.gas;
      case 'Electrical':
        return AppColors.accent;
      case 'Standards':
        return AppColors.brass;
      case 'Building':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regulations & standards'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by code or topic',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final c = _categories[i];
                final selected = c == _category;
                return ChoiceChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = c),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected ? AppColors.primaryDark : AppColors.text,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      'No regulations match your search.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final r = list[i];
                      final cc = _categoryColor(r.category);
                      return Card(
                        color: AppColors.cardBg,
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _RegulationDetail(entry: r),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cc.withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        r.category,
                                        style: TextStyle(
                                          color: cc,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.chevron_right,
                                      color: AppColors.muted,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  r.code,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r.topic,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  r.summary,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.muted,
                                  ),
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

class _RegulationDetail extends StatelessWidget {
  final RegulationEntry entry;
  const _RegulationDetail({required this.entry});

  Future<void> _speak(String text) => TtsService.instance.speak(text);

  Widget _section(
    String heading, {
    required Widget child,
    required VoidCallback onSpeak,
  }) {
    return Card(
      color: AppColors.cardBg,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  heading,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                IconButton(
                  tooltip: 'Speak',
                  icon: Icon(Icons.volume_up, color: AppColors.accent),
                  onPressed: onSpeak,
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.code),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Speak all',
            icon: const Icon(Icons.record_voice_over),
            onPressed: () => _speak(entry.speakable),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            entry.topic,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 16),
          _section(
            'Summary',
            onSpeak: () => _speak('Summary. ${entry.summary}'),
            child: Text(
              entry.summary,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.text,
              ),
            ),
          ),
          _section(
            'Key points',
            onSpeak: () => _speak(
              'Key points. ${entry.keyPoints.join(". ")}.',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(entry.keyPoints.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.keyPoints[i],
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          _section(
            'Who enforces',
            onSpeak: () => _speak('Who enforces it. ${entry.whoEnforces}'),
            child: Text(
              entry.whoEnforces,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
