import 'package:flutter/material.dart';

import '../data/expense_data.dart';
import '../data/job_log_data.dart';
import '../services/csv_export.dart';
import '../services/expense_service.dart';
import '../services/job_log_service.dart';
import '../theme.dart';

/// Aggregates the user's job log and expenses into a one-screen view of how
/// the business is doing — revenue, hours, profit, mileage and a 6-month
/// chart. Read-only: this screen never writes anything to disk.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

enum _Range { thisWeek, thisMonth, thisYear, all }

class _DashboardScreenState extends State<DashboardScreen> {
  _Range _range = _Range.thisMonth;

  @override
  void initState() {
    super.initState();
    JobLogService.instance.ensureLoaded();
    ExpenseService.instance.ensureLoaded();
  }

  /// `[from, to)` bounds for the selected range, or nulls for all-time.
  (DateTime?, DateTime?) get _bounds {
    final now = DateTime.now();
    switch (_range) {
      case _Range.thisWeek:
        // Treat Monday as the start of the week (UK norm).
        final today = DateTime(now.year, now.month, now.day);
        final from = today.subtract(Duration(days: today.weekday - 1));
        return (from, from.add(const Duration(days: 7)));
      case _Range.thisMonth:
        return (DateTime(now.year, now.month, 1),
            DateTime(now.year, now.month + 1, 1));
      case _Range.thisYear:
        return (DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 1));
      case _Range.all:
        return (null, null);
    }
  }

  String get _rangeLabel {
    switch (_range) {
      case _Range.thisWeek:
        return 'this week';
      case _Range.thisMonth:
        return 'this month';
      case _Range.thisYear:
        return 'this year';
      case _Range.all:
        return 'all time';
    }
  }

  String get _rangeSlug {
    final (from, to) = _bounds;
    String f(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (from == null && to == null) return 'all-time';
    final start = from == null ? 'all-time' : f(from);
    final endExclusive = to == null ? 'today' : f(to.subtract(const Duration(days: 1)));
    return '$start-to-$endExclusive';
  }

  Future<void> _exportCsv() async {
    final messenger = ScaffoldMessenger.of(context);
    final (from, to) = _bounds;
    try {
      await CsvExport.shareForRange(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Export CSV — $_rangeLabel',
            icon: const Icon(Icons.ios_share),
            onPressed: _exportCsv,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge(
            [JobLogService.instance, ExpenseService.instance]),
        builder: (context, _) {
          final (from, to) = _bounds;
          final now = DateTime.now();

          final allJobs = JobLogService.instance.jobs;
          final jobsInRange = allJobs.where((j) {
            final d = j.completedAt ?? j.createdAt;
            if (from != null && d.isBefore(from)) return false;
            if (to != null && !d.isBefore(to)) return false;
            return true;
          }).toList();

          var revenue = 0.0;
          var labour = 0.0;
          var parts = 0.0;
          var seconds = 0;
          for (final j in jobsInRange) {
            revenue += j.totalCostAt(now);
            labour += j.labourCostAt(now);
            parts += j.materialsCost;
            seconds += j.totalTime(now).inSeconds;
          }
          final hours = seconds / 3600.0;
          final avgRate = hours > 0 ? labour / hours : 0.0;

          final expensesTotal = ExpenseService.instance
              .totalIn(from: from, to: to);
          final mileageCost = ExpenseService.instance
              .totalIn(from: from, to: to, kind: ExpenseKind.mileage);
          final miles = ExpenseService.instance.milesIn(from: from, to: to);
          final profit = revenue - expensesTotal;

          if (allJobs.isEmpty && ExpenseService.instance.items.isEmpty) {
            return const _EmptyState();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
            children: [
              _RangeChips(
                value: _range,
                onChanged: (v) => setState(() => _range = v),
              ),
              const SizedBox(height: 14),
              _RevenueHero(
                rangeLabel: _rangeLabel,
                revenue: revenue,
                jobsCount: jobsInRange.length,
                hours: hours,
              ),
              const SizedBox(height: 12),
              _StatGrid(
                profit: profit,
                expenses: expensesTotal,
                hours: hours,
                avgRate: avgRate,
                miles: miles,
                mileageCost: mileageCost,
              ),
              if (revenue > 0) ...[
                const SizedBox(height: 16),
                _SplitCard(labour: labour, parts: parts),
              ],
              const SizedBox(height: 16),
              _MonthlyChartCard(jobs: allJobs, now: now),
              if (jobsInRange.isNotEmpty) ...[
                const SizedBox(height: 16),
                _TopCustomersCard(
                  jobs: jobsInRange,
                  now: now,
                  rangeLabel: _rangeLabel,
                ),
              ],
              if (expensesTotal > 0) ...[
                const SizedBox(height: 16),
                _ExpenseBreakdownCard(
                  from: from,
                  to: to,
                  rangeLabel: _rangeLabel,
                ),
              ],
            ],
          );
        },
      ),
    );
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
        chip(_Range.thisWeek, 'This week'),
        chip(_Range.thisMonth, 'This month'),
        chip(_Range.thisYear, 'This year'),
        chip(_Range.all, 'All time'),
      ],
    );
  }
}

class _RevenueHero extends StatelessWidget {
  final String rangeLabel;
  final double revenue;
  final int jobsCount;
  final double hours;
  const _RevenueHero({
    required this.rangeLabel,
    required this.revenue,
    required this.jobsCount,
    required this.hours,
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('REVENUE · ${rangeLabel.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                )),
            const SizedBox(height: 4),
            Text(_money(revenue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                )),
            const SizedBox(height: 6),
            Text(
              '$jobsCount job${jobsCount == 1 ? '' : 's'} · ${_hours(hours)} on the clock',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final double profit;
  final double expenses;
  final double hours;
  final double avgRate;
  final double miles;
  final double mileageCost;
  const _StatGrid({
    required this.profit,
    required this.expenses,
    required this.hours,
    required this.avgRate,
    required this.miles,
    required this.mileageCost,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _StatTile(
          icon: Icons.savings,
          color: profit >= 0 ? Colors.green : Colors.redAccent,
          label: 'Profit',
          value: _money(profit),
          detail: 'Revenue − expenses',
        ),
        _StatTile(
          icon: Icons.receipt_long,
          color: AppColors.accent,
          label: 'Expenses',
          value: _money(expenses),
          detail: 'Logged outgoings',
        ),
        _StatTile(
          icon: Icons.timer,
          color: AppColors.primary,
          label: 'Hours worked',
          value: _hours(hours),
          detail: hours > 0
              ? '£${avgRate.toStringAsFixed(0)}/h average'
              : 'No time logged',
        ),
        _StatTile(
          icon: Icons.directions_car,
          color: const Color(0xFF6F4E7C),
          label: 'Miles driven',
          value: miles == miles.roundToDouble()
              ? miles.toStringAsFixed(0)
              : miles.toStringAsFixed(1),
          detail: '£${mileageCost.toStringAsFixed(2)} mileage cost',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String detail;
  const _StatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ]),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              detail,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitCard extends StatelessWidget {
  final double labour;
  final double parts;
  const _SplitCard({required this.labour, required this.parts});

  @override
  Widget build(BuildContext context) {
    final total = labour + parts;
    final labourPct = total == 0 ? 0.0 : labour / total;
    final partsPct = total == 0 ? 0.0 : parts / total;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue split',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 18,
                child: Row(
                  children: [
                    if (labour > 0)
                      Expanded(
                        flex: (labourPct * 1000).round().clamp(1, 1000),
                        child: Container(color: AppColors.primary),
                      ),
                    if (parts > 0)
                      Expanded(
                        flex: (partsPct * 1000).round().clamp(1, 1000),
                        child: Container(color: AppColors.accent),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              _Legend(
                color: AppColors.primary,
                label:
                    'Labour ${(labourPct * 100).toStringAsFixed(0)}% · ${_money(labour)}',
              ),
              const Spacer(),
              _Legend(
                color: AppColors.accent,
                label:
                    'Parts ${(partsPct * 100).toStringAsFixed(0)}% · ${_money(parts)}',
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}

class _MonthlyChartCard extends StatelessWidget {
  final List<Job> jobs;
  final DateTime now;
  const _MonthlyChartCard({required this.jobs, required this.now});

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    // Aggregate revenue per month for the trailing 6 months including the
    // current one. Bars left-to-right are oldest → newest.
    final months = <DateTime>[
      for (var i = 5; i >= 0; i--)
        DateTime(now.year, now.month - i, 1),
    ];
    final totals = List<double>.filled(months.length, 0);
    for (final j in jobs) {
      final d = j.completedAt ?? j.createdAt;
      for (var i = 0; i < months.length; i++) {
        final start = months[i];
        final end = DateTime(start.year, start.month + 1, 1);
        if (!d.isBefore(start) && d.isBefore(end)) {
          totals[i] += j.totalCostAt(now);
          break;
        }
      }
    }
    final maxTotal = totals.fold<double>(0, (a, b) => b > a ? b : a);
    final hasData = maxTotal > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 6 months',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'Revenue per month — bars are scaled to your highest month.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 160,
              child: hasData
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < months.length; i++)
                          Expanded(
                            child: _MonthBar(
                              month: months[i],
                              value: totals[i],
                              maxValue: maxTotal,
                              monthLabel: _monthNames[months[i].month - 1],
                            ),
                          ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'No revenue logged in the last 6 months yet.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  final DateTime month;
  final double value;
  final double maxValue;
  final String monthLabel;
  const _MonthBar({
    required this.month,
    required this.value,
    required this.maxValue,
    required this.monthLabel,
  });

  @override
  Widget build(BuildContext context) {
    final pct = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, c) {
        // Reserve ~32 px for the label band beneath the bar.
        final barAreaHeight = c.maxHeight - 32;
        final barHeight = (barAreaHeight * pct).clamp(2.0, barAreaHeight);
        final isCurrent = DateTime.now().year == month.year &&
            DateTime.now().month == month.month;
        final color =
            isCurrent ? AppColors.accent : AppColors.primary;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (value > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    _shortMoney(value),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Container(
                height: barHeight,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.85),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                monthLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                  color: isCurrent ? AppColors.accent : AppColors.muted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopCustomersCard extends StatelessWidget {
  final List<Job> jobs;
  final DateTime now;
  final String rangeLabel;
  const _TopCustomersCard({
    required this.jobs,
    required this.now,
    required this.rangeLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Group by customerId when present, otherwise fall back to the customer
    // name so free-text entries still aggregate together.
    final groups = <String, _CustomerStat>{};
    for (final j in jobs) {
      final key =
          j.customerId.isNotEmpty ? 'id:${j.customerId}' : 'name:${j.customer.toLowerCase().trim()}';
      final existing = groups[key];
      if (existing == null) {
        groups[key] = _CustomerStat(
          name: j.customer.isEmpty ? 'Untitled' : j.customer,
          revenue: j.totalCostAt(now),
          jobs: 1,
        );
      } else {
        groups[key] = _CustomerStat(
          name: existing.name,
          revenue: existing.revenue + j.totalCostAt(now),
          jobs: existing.jobs + 1,
        );
      }
    }
    final top = groups.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
    final shown = top.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top customers · $rangeLabel',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'Ranked by total billed in this period.',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < shown.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.16),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shown[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        Text(
                            '${shown[i].jobs} job${shown[i].jobs == 1 ? '' : 's'}',
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(_money(shown[i].revenue),
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomerStat {
  final String name;
  final double revenue;
  final int jobs;
  _CustomerStat({
    required this.name,
    required this.revenue,
    required this.jobs,
  });
}

class _ExpenseBreakdownCard extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final String rangeLabel;
  const _ExpenseBreakdownCard({
    required this.from,
    required this.to,
    required this.rangeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final items = ExpenseService.instance.items.where((e) {
      if (from != null && e.date.isBefore(from!)) return false;
      if (to != null && !e.date.isBefore(to!)) return false;
      return true;
    });
    final byCategory = <String, double>{};
    for (final e in items) {
      final key = e.kind == ExpenseKind.mileage ? 'Mileage' : e.category;
      byCategory[key] = (byCategory[key] ?? 0) + e.computedAmountGbp;
    }
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = entries.isEmpty
        ? 0.0
        : entries.first.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expenses by category · $rangeLabel',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(e.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                      ),
                      Text(_money(e.value),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxValue == 0 ? 0 : e.value / maxValue,
                        minHeight: 6,
                        backgroundColor:
                            AppColors.muted.withValues(alpha: 0.15),
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
            const Icon(Icons.insert_chart_outlined,
                size: 64, color: AppColors.muted),
            const SizedBox(height: 8),
            Text('No data yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Once you log a couple of jobs and any expenses or business mileage, this dashboard fills up automatically.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

String _money(double v) {
  final neg = v < 0;
  final abs = v.abs();
  final whole = abs.floor();
  final pence = ((abs - whole) * 100).round();
  final wholeStr = whole.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => ',',
      );
  return '${neg ? '-' : ''}£$wholeStr.${pence.toString().padLeft(2, '0')}';
}

String _shortMoney(double v) {
  if (v.abs() >= 1000) {
    return '£${(v / 1000).toStringAsFixed(v.abs() >= 10000 ? 0 : 1)}k';
  }
  return '£${v.toStringAsFixed(0)}';
}

String _hours(double h) {
  if (h <= 0) return '0 h';
  final whole = h.floor();
  final mins = ((h - whole) * 60).round();
  if (mins == 0) return '${whole}h';
  return '${whole}h ${mins}m';
}
