import 'package:flutter/material.dart';

import '../data/glossary_data.dart';
import '../services/srs_service.dart';
import '../services/tts_service.dart';
import '../theme.dart';
import 'glossary_practice_screen.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final Map<String, GlobalKey> _letterKeys = {};

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<GlossaryTerm> get _filtered {
    final q = _search.text.trim().toLowerCase();
    final list = [...glossary]
      ..sort((a, b) =>
          a.term.toLowerCase().compareTo(b.term.toLowerCase()));
    if (q.isEmpty) return list;
    return list
        .where((g) => g.term.toLowerCase().contains(q))
        .toList();
  }

  Map<String, List<GlossaryTerm>> _group(List<GlossaryTerm> list) {
    final map = <String, List<GlossaryTerm>>{};
    for (final g in list) {
      final letter = g.term.substring(0, 1).toUpperCase();
      map.putIfAbsent(letter, () => []).add(g);
    }
    return map;
  }

  void _jumpTo(String letter) {
    final key = _letterKeys[letter];
    if (key == null) return;
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  @override
  void initState() {
    super.initState();
    SrsService.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final grouped = _group(filtered);
    final lettersPresent = grouped.keys.toList()..sort();
    _letterKeys
      ..clear()
      ..addEntries(lettersPresent.map((l) => MapEntry(l, GlobalKey())));

    final alphabet = List.generate(26, (i) => String.fromCharCode(65 + i));
    final allTerms = glossary.map((g) => g.term).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glossary'),
        actions: [
          AnimatedBuilder(
            animation: SrsService.instance,
            builder: (context, _) {
              final n = SrsService.instance.dueCount(allTerms);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: 'Practice (spaced repetition)',
                    icon: const Icon(Icons.school),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GlossaryPracticeScreen()),
                    ),
                  ),
                  if (n > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$n',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
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
          AnimatedBuilder(
            animation: SrsService.instance,
            builder: (context, _) => _PracticeBanner(allTerms: allTerms),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search terms...',
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
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              itemCount: alphabet.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final letter = alphabet[i];
                final present = grouped.containsKey(letter);
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: present ? () => _jumpTo(letter) : null,
                  child: Container(
                    width: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: present
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: present
                            ? AppColors.primary
                            : AppColors.muted.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No terms match your search',
                        style: Theme.of(context).textTheme.bodyMedium),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
                    itemCount: lettersPresent.length,
                    itemBuilder: (_, i) {
                      final letter = lettersPresent[i];
                      final entries = grouped[letter]!;
                      return Column(
                        key: _letterKeys[letter],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    letter,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${entries.length} term${entries.length == 1 ? '' : 's'}',
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          ...entries.map((g) => _GlossaryCard(term: g)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PracticeBanner extends StatelessWidget {
  final List<String> allTerms;
  const _PracticeBanner({required this.allTerms});

  @override
  Widget build(BuildContext context) {
    final due = SrsService.instance.dueCount(allTerms);
    final snap = SrsService.instance.snapshot(allTerms);
    final total = allTerms.length;
    final progress =
        total == 0 ? 0.0 : snap.mastered / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const GlossaryPracticeScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school,
                      color: AppColors.accent, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        due > 0
                            ? '$due card${due == 1 ? '' : 's'} due today'
                            : 'No cards due — start a fresh batch',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${snap.mastered} mastered · ${snap.learned} learning · ${snap.neverSeen} new',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 5,
                          backgroundColor: Colors.black12,
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlossaryCard extends StatelessWidget {
  final GlossaryTerm term;
  const _GlossaryCard({required this.term});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(term.term,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(term.definition,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Read aloud',
              icon: const Icon(Icons.volume_up),
              color: AppColors.primary,
              onPressed: () => TtsService.instance.speak(term.speakable),
            ),
          ],
        ),
      ),
    );
  }
}
