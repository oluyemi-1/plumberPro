import 'package:flutter/material.dart';

import '../data/tools_data.dart';
import '../services/tts_service.dart';
import '../theme.dart';

class ToolsEncyclopediaScreen extends StatefulWidget {
  const ToolsEncyclopediaScreen({super.key});

  @override
  State<ToolsEncyclopediaScreen> createState() =>
      _ToolsEncyclopediaScreenState();
}

class _ToolsEncyclopediaScreenState extends State<ToolsEncyclopediaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  List<String> get _categories {
    final set = <String>{for (final t in toolEntries) t.category};
    return ['All', ...set.toList()..sort()];
  }

  List<ToolEntry> get _filtered {
    return toolEntries.where((t) {
      final matchesCat =
          _selectedCategory == 'All' || t.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          t.name.toLowerCase().contains(_query.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Cutting':
        return AppColors.accent;
      case 'Joining':
        return AppColors.copper;
      case 'Bending':
        return AppColors.brass;
      case 'Measuring':
        return AppColors.coldWater;
      case 'Clearing':
        return AppColors.waste;
      case 'Testing':
        return AppColors.primary;
      case 'Power':
        return AppColors.hotWater;
      case 'Hand':
        return AppColors.pipeMetal;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tool encyclopedia')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search tools',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.muted.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.muted.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
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
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No tools match.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final t = _filtered[i];
                      final color = _categoryColor(t.category);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _ToolDetailScreen(tool: t),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(t.icon, color: color, size: 26),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color:
                                              color.withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          t.category,
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        t.purpose,
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 13,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
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

class _ToolDetailScreen extends StatelessWidget {
  final ToolEntry tool;
  const _ToolDetailScreen({required this.tool});

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Cutting':
        return AppColors.accent;
      case 'Joining':
        return AppColors.copper;
      case 'Bending':
        return AppColors.brass;
      case 'Measuring':
        return AppColors.coldWater;
      case 'Clearing':
        return AppColors.waste;
      case 'Testing':
        return AppColors.primary;
      case 'Power':
        return AppColors.hotWater;
      case 'Hand':
        return AppColors.pipeMetal;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(tool.category);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tool detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.stop_rounded),
            tooltip: 'Stop speech',
            onPressed: () => TtsService.instance.stop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(tool.icon, color: color, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tool.name,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tool.category,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  onPressed: () =>
                      TtsService.instance.speak(tool.speakable),
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('Speak full entry'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Purpose',
              body: tool.purpose,
              icon: Icons.flag_rounded,
              accent: AppColors.primary,
              speakText: '${tool.name}. Purpose. ${tool.purpose}',
            ),
            _Section(
              title: 'How to use',
              body: tool.howTo,
              icon: Icons.menu_book_rounded,
              accent: AppColors.copper,
              speakText: 'How to use. ${tool.howTo}',
            ),
            _Section(
              title: 'Common errors',
              body: tool.commonErrors,
              icon: Icons.error_outline_rounded,
              accent: AppColors.accent,
              speakText: 'Common errors. ${tool.commonErrors}',
            ),
            _Section(
              title: 'Safety',
              body: tool.safety,
              icon: Icons.shield_rounded,
              accent: AppColors.hotWater,
              speakText: 'Safety. ${tool.safety}',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color accent;
  final String speakText;

  const _Section({
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
    required this.speakText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Speak',
                  icon: Icon(Icons.volume_up_rounded, color: accent),
                  onPressed: () => TtsService.instance.speak(speakText),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
