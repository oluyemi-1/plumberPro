import 'package:flutter/material.dart';

import '../data/content_index.dart';
import '../data/customer_data.dart';
import '../data/data_search.dart';
import '../data/expense_data.dart';
import '../data/job_log_data.dart';
import '../data/quote_data.dart';
import '../data/reminder_data.dart';
import '../services/bookmarks_service.dart';
import '../services/customer_service.dart';
import '../services/expense_service.dart';
import '../services/job_log_service.dart';
import '../services/progress_service.dart';
import '../services/quote_service.dart';
import '../services/reminder_service.dart';
import '../theme.dart';
import 'customer_detail_screen.dart';
import 'edit_expense_screen.dart';
import 'edit_quote_screen.dart';
import 'edit_reminder_screen.dart';
import 'job_detail_screen.dart';

/// Global search across every lesson, simulation, quiz, scenario, checklist,
/// glossary entry, regulation, customer explainer, tool and hub in the app.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  String _typeFilter = 'All';
  late final List<SearchEntry> _all;

  @override
  void initState() {
    super.initState();
    _all = buildContentIndex();
    BookmarksService.instance.ensureLoaded();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<String> get _types {
    final s = <String>{'All'};
    for (final e in _all) {
      s.add(e.type);
    }
    return s.toList();
  }

  List<SearchEntry> get _filtered {
    return _all.where((e) {
      if (_typeFilter != 'All' && e.type != _typeFilter) return false;
      return e.matches(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final contentResults = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search everything'),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          BookmarksService.instance,
          CustomerService.instance,
          JobLogService.instance,
          QuoteService.instance,
          ReminderService.instance,
          ExpenseService.instance,
        ]),
        builder: (context, _) {
          final dataResults = searchUserData(
            _query,
            customers: CustomerService.instance.customers,
            jobs: JobLogService.instance.jobs,
            quotes: QuoteService.instance.items,
            reminders: ReminderService.instance.items,
            expenses: ExpenseService.instance.items,
          );
          // Items list for the lazy ListView. Each entry is one of: a
          // section header (String), a `DataMatch`, or a `SearchEntry`.
          final items = <Object>[];
          if (dataResults.isNotEmpty) {
            items.add('Your work');
            items.addAll(dataResults);
          }
          if (contentResults.isNotEmpty) {
            items.add('Learning content');
            items.addAll(contentResults);
          }
          final total = dataResults.length + contentResults.length;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText:
                        'Customers, jobs, quotes, reminders, lessons, regs…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _ctrl.clear();
                              setState(() => _query = '');
                            },
                          ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  scrollDirection: Axis.horizontal,
                  itemCount: _types.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final c = _types[i];
                    return ChoiceChip(
                      label: Text(c),
                      selected: _typeFilter == c,
                      onSelected: (_) => setState(() => _typeFilter = c),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(children: [
                  Text('$total match${total == 1 ? '' : 'es'}',
                      style: Theme.of(context).textTheme.bodySmall),
                  if (dataResults.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      '· ${dataResults.length} in your work',
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                  const Spacer(),
                ]),
              ),
              Expanded(
                child: items.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final item = items[i];
                          if (item is String) {
                            return _SectionHeader(label: item);
                          }
                          if (item is DataMatch) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _DataMatchTile(match: item),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child:
                                SearchResultTile(entry: item as SearchEntry),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DataMatchTile extends StatelessWidget {
  final DataMatch match;
  const _DataMatchTile({required this.match});

  IconData get _icon {
    switch (match.type) {
      case DataMatchType.customer:
        return Icons.person;
      case DataMatchType.job:
        return Icons.work;
      case DataMatchType.quote:
        return Icons.note_add;
      case DataMatchType.reminder:
        return Icons.event_available;
      case DataMatchType.expense:
        return Icons.receipt_long;
    }
  }

  Color get _color {
    switch (match.type) {
      case DataMatchType.customer:
        return const Color(0xFF6F4E7C);
      case DataMatchType.job:
        return AppColors.primary;
      case DataMatchType.quote:
        return const Color(0xFF8E44AD);
      case DataMatchType.reminder:
        return const Color(0xFFC1121F);
      case DataMatchType.expense:
        return const Color(0xFF2E8B57);
    }
  }

  void _open(BuildContext context) {
    final src = match.source;
    Widget? target;
    if (src is Customer) {
      target = CustomerDetailScreen(customerId: src.id);
    } else if (src is Job) {
      target = JobDetailScreen(jobId: src.id);
    } else if (src is Quote) {
      target = EditQuoteScreen(existing: src);
    } else if (src is ServiceReminder) {
      target = EditReminderScreen(existing: src);
    } else if (src is Expense) {
      target = EditExpenseScreen(kind: src.kind, existing: src);
    }
    if (target == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => target!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(match.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        match.type.label,
                        style: TextStyle(
                            color: _color,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ]),
                  if (match.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      match.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ]),
        ),
      ),
    );
  }
}

class SearchResultTile extends StatelessWidget {
  final SearchEntry entry;
  const SearchResultTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final saved = BookmarksService.instance.contains(entry.id);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          ProgressService.instance.markVisited(entry.id);
          Navigator.push(
            context,
            MaterialPageRoute(builder: entry.builder),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: entry.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(entry.icon, color: entry.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(entry.title,
                            style:
                                Theme.of(context).textTheme.titleMedium),
                      ),
                      _Tag(label: entry.type, color: entry.color),
                    ]),
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: saved ? 'Remove bookmark' : 'Bookmark',
                icon: Icon(
                  saved ? Icons.bookmark : Icons.bookmark_border,
                  color: saved ? AppColors.accent : AppColors.muted,
                ),
                onPressed: () =>
                    BookmarksService.instance.toggle(entry.id),
              ),
            ],
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700)),
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
            const Icon(Icons.search_off,
                size: 56, color: AppColors.muted),
            const SizedBox(height: 8),
            Text('No matches',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'Try a different word, or remove the type filter.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
