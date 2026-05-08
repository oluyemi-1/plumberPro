import 'package:flutter/material.dart';

import '../data/expense_data.dart';
import '../services/csv_export.dart';
import '../services/expense_service.dart';
import '../services/job_log_service.dart';
import '../theme.dart';
import 'edit_expense_screen.dart';
import 'receipt_scan_screen.dart';

enum _Range { thisMonth, thisYear, all }

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  _Range _range = _Range.thisMonth;

  @override
  void initState() {
    super.initState();
    ExpenseService.instance.ensureLoaded();
    JobLogService.instance.ensureLoaded();
  }

  (DateTime?, DateTime?) get _rangeBounds {
    final now = DateTime.now();
    switch (_range) {
      case _Range.thisMonth:
        final from = DateTime(now.year, now.month, 1);
        final to = DateTime(now.year, now.month + 1, 1);
        return (from, to);
      case _Range.thisYear:
        return (DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 1));
      case _Range.all:
        return (null, null);
    }
  }

  Future<void> _addExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditExpenseScreen(kind: ExpenseKind.expense),
      ),
    );
  }

  Future<void> _addMileage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditExpenseScreen(kind: ExpenseKind.mileage),
      ),
    );
  }

  void _openAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.receipt_long, color: AppColors.primary),
              ),
              title: const Text('Expense'),
              subtitle: const Text(
                  'Fuel, parts, tools, insurance, training, phone…'),
              onTap: () {
                Navigator.pop(context);
                _addExpense();
              },
            ),
            ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_car,
                    color: AppColors.accent),
              ),
              title: const Text('Mileage'),
              subtitle: const Text(
                  'Business miles driven — auto-costed at your rate.'),
              onTap: () {
                Navigator.pop(context);
                _addMileage();
              },
            ),
            ListTile(
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF6F4E7C).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.document_scanner,
                    color: Color(0xFF6F4E7C)),
              ),
              title: const Text('Scan receipt'),
              subtitle: const Text(
                  'Snap a receipt — amount, date, supplier and category auto-filled.'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ReceiptScanScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses & mileage'),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.ios_share),
            onPressed: _exportCsv,
          ),
          IconButton(
            tooltip: 'Mileage rate',
            icon: const Icon(Icons.tune),
            onPressed: _editRate,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        onPressed: _openAddSheet,
      ),
      body: AnimatedBuilder(
        animation: ExpenseService.instance,
        builder: (context, _) {
          final (from, to) = _rangeBounds;
          final svc = ExpenseService.instance;
          final all = svc.items;
          final inRange = all.where((e) {
            if (from != null && e.date.isBefore(from)) return false;
            if (to != null && !e.date.isBefore(to)) return false;
            return true;
          }).toList();

          final totalAll = svc.totalIn(from: from, to: to);
          final totalMileage =
              svc.totalIn(from: from, to: to, kind: ExpenseKind.mileage);
          final totalExpense =
              svc.totalIn(from: from, to: to, kind: ExpenseKind.expense);
          final miles = svc.milesIn(from: from, to: to);

          // Flatten the screen into a single heterogeneous list so we can
          // use ListView.builder. The summary card is constant-cost; the
          // win is in the month-grouped expense rows, which can grow into
          // the hundreds for an active business.
          final items = <Object>[
            const _RangeChipsSlot(),
            const _SummarySlot(),
          ];
          if (all.isEmpty) {
            items.add(const _EmptyStateSlot());
          } else if (inRange.isEmpty) {
            items.add(const _NothingInRangeSlot());
          } else {
            String? currentMonthKey;
            for (final e in inRange) {
              final key =
                  '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
              if (key != currentMonthKey) {
                items.add(_MonthHeaderSlot(e.date));
                currentMonthKey = key;
              }
              items.add(e);
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              if (item is _RangeChipsSlot) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RangeChips(
                    value: _range,
                    onChanged: (v) => setState(() => _range = v),
                  ),
                );
              }
              if (item is _SummarySlot) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SummaryCard(
                    rangeLabel: _rangeLabel(_range),
                    totalAll: totalAll,
                    totalExpense: totalExpense,
                    totalMileage: totalMileage,
                    miles: miles,
                  ),
                );
              }
              if (item is _EmptyStateSlot) return const _EmptyState();
              if (item is _NothingInRangeSlot) {
                return _NothingInRangeState(rangeLabel: _rangeLabel(_range));
              }
              if (item is _MonthHeaderSlot) {
                return _MonthHeader(date: item.date);
              }
              if (item is Expense) return _ExpenseRow(expense: item);
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  String get _rangeSlug {
    final (from, to) = _rangeBounds;
    String f(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (from == null && to == null) return 'all-time';
    final start = from == null ? 'all-time' : f(from);
    final endExclusive =
        to == null ? 'today' : f(to.subtract(const Duration(days: 1)));
    return '$start-to-$endExclusive';
  }

  Future<void> _exportCsv() async {
    final messenger = ScaffoldMessenger.of(context);
    final (from, to) = _rangeBounds;
    try {
      await CsvExport.shareExpensesForRange(
        from: from,
        to: to,
        rangeSlug: _rangeSlug,
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('CSV export failed: $e')),
      );
    }
  }

  Future<void> _editRate() async {
    final ctrl = TextEditingController(
        text: ExpenseService.instance.mileageRate.toStringAsFixed(2));
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mileage rate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Default rate (£ / mile)',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'New mileage entries pre-fill with this rate. Existing entries keep the rate they were saved with.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) {
      final v = double.tryParse(ctrl.text.trim());
      if (v != null && v > 0) {
        await ExpenseService.instance.setMileageRate(v);
      }
    }
  }
}

/// Sentinel slot wrappers — these mark *what* should render at a given
/// position in the flattened ListView.builder feed, without forcing us to
/// construct the actual widgets up-front.
class _RangeChipsSlot {
  const _RangeChipsSlot();
}

class _SummarySlot {
  const _SummarySlot();
}

class _EmptyStateSlot {
  const _EmptyStateSlot();
}

class _NothingInRangeSlot {
  const _NothingInRangeSlot();
}

class _MonthHeaderSlot {
  final DateTime date;
  const _MonthHeaderSlot(this.date);
}

String _rangeLabel(_Range r) {
  switch (r) {
    case _Range.thisMonth:
      return 'this month';
    case _Range.thisYear:
      return 'this year';
    case _Range.all:
      return 'all time';
  }
}

class _RangeChips extends StatelessWidget {
  final _Range value;
  final ValueChanged<_Range> onChanged;
  const _RangeChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(_Range r, String label) => ChoiceChip(
          label: Text(label),
          selected: value == r,
          onSelected: (_) => onChanged(r),
        );
    return Wrap(
      spacing: 8,
      children: [
        chip(_Range.thisMonth, 'This month'),
        chip(_Range.thisYear, 'This year'),
        chip(_Range.all, 'All time'),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String rangeLabel;
  final double totalAll;
  final double totalExpense;
  final double totalMileage;
  final double miles;
  const _SummaryCard({
    required this.rangeLabel,
    required this.totalAll,
    required this.totalExpense,
    required this.totalMileage,
    required this.miles,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TOTAL · ${rangeLabel.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                )),
            const SizedBox(height: 4),
            Text('£${totalAll.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 6, children: [
              _MiniStat(
                label: 'Expenses',
                value: '£${totalExpense.toStringAsFixed(2)}',
              ),
              _MiniStat(
                label: 'Mileage cost',
                value: '£${totalMileage.toStringAsFixed(2)}',
              ),
              _MiniStat(
                label: 'Miles',
                value: miles == miles.roundToDouble()
                    ? miles.toStringAsFixed(0)
                    : miles.toStringAsFixed(1),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(width: 6),
          Text(value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              )),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime date;
  const _MonthHeader({required this.date});

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Text(
        '${_months[date.month - 1]} ${date.year}'.toUpperCase(),
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

class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  const _ExpenseRow({required this.expense});

  IconData get _icon {
    if (expense.kind == ExpenseKind.mileage) return Icons.directions_car;
    switch (expense.category) {
      case 'Fuel':
        return Icons.local_gas_station;
      case 'Parts & materials':
        return Icons.plumbing;
      case 'Tools & equipment':
        return Icons.handyman;
      case 'Vehicle (MOT, service, parking)':
        return Icons.car_repair;
      case 'Phone & data':
        return Icons.phone_iphone;
      case 'Insurance & subscriptions':
        return Icons.shield;
      case 'Training & qualifications':
        return Icons.school;
      default:
        return Icons.receipt_long;
    }
  }

  Color get _color =>
      expense.kind == ExpenseKind.mileage ? AppColors.accent : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final amount = expense.computedAmountGbp;
    final job = expense.jobId == null
        ? null
        : JobLogService.instance.findById(expense.jobId!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditExpenseScreen(
                kind: expense.kind,
                existing: expense,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
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
                    Text(
                      expense.description.isEmpty
                          ? expense.category
                          : expense.description,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitleFor(expense, job?.customer),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '£${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

String _subtitleFor(Expense e, String? jobCustomer) {
  final parts = <String>[];
  if (e.kind == ExpenseKind.mileage) {
    final m = e.miles == e.miles.roundToDouble()
        ? e.miles.toStringAsFixed(0)
        : e.miles.toStringAsFixed(1);
    parts.add('$m mi @ £${e.mileageRateGbpPerMile.toStringAsFixed(2)}');
  } else {
    parts.add(e.category);
  }
  parts.add('${e.date.day}/${e.date.month.toString().padLeft(2, '0')}');
  if (jobCustomer != null && jobCustomer.isNotEmpty) {
    parts.add('· ${jobCustomer.split(' ').first}');
  } else if (jobCustomer != null) {
    parts.add('· linked');
  }
  return parts.join(' · ');
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 64, color: AppColors.muted),
          const SizedBox(height: 8),
          Text('No expenses yet',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          const Text(
            'Tap Add to log a fuel receipt, parts purchase, tool buy or business mile.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NothingInRangeState extends StatelessWidget {
  final String rangeLabel;
  const _NothingInRangeState({required this.rangeLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy, size: 48, color: AppColors.muted),
          const SizedBox(height: 8),
          Text('Nothing $rangeLabel',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Switch the range above to see older items.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
