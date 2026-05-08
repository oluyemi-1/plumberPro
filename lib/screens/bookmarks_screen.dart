import 'package:flutter/material.dart';

import '../data/content_index.dart';
import '../services/bookmarks_service.dart';
import '../theme.dart';
import 'search_screen.dart';

/// Lists every bookmarked content item, grouped by type. Powered by the same
/// [SearchEntry] index as the search screen.
class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  late final List<SearchEntry> _all;

  @override
  void initState() {
    super.initState();
    _all = buildContentIndex();
    BookmarksService.instance.ensureLoaded();
  }

  Future<void> _confirmClearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove every bookmark?'),
        content: const Text(
            'This clears your saved-items list. The original content stays in the app.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear all')),
        ],
      ),
    );
    if (ok == true) {
      await BookmarksService.instance.clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          IconButton(
            tooltip: 'Open search',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'clear') _confirmClearAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'clear',
                  child: Text('Clear all bookmarks')),
            ],
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: BookmarksService.instance,
        builder: (context, _) {
          final ids = BookmarksService.instance.ids;
          final saved = _all.where((e) => ids.contains(e.id)).toList();

          if (saved.isEmpty) {
            return const _EmptyState();
          }

          // Group by type.
          final groups = <String, List<SearchEntry>>{};
          for (final e in saved) {
            groups.putIfAbsent(e.type, () => []).add(e);
          }
          final keys = groups.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                child: Text(
                  '${saved.length} saved item${saved.length == 1 ? '' : 's'} across ${keys.length} type${keys.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              for (final key in keys) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
                  child: Text(key,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                ...groups[key]!.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: SearchResultTile(entry: e),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_outline,
                size: 64, color: AppColors.muted),
            const SizedBox(height: 8),
            Text('No bookmarks yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Open search and tap the bookmark icon next to anything you want to come back to.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
              icon: const Icon(Icons.search),
              label: const Text('Open search'),
            ),
          ],
        ),
      ),
    );
  }
}
