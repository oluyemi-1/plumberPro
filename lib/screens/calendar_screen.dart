import 'package:flutter/material.dart';

import '../data/job_log_data.dart';
import '../data/quote_data.dart';
import '../data/reminder_data.dart';
import '../services/job_log_service.dart';
import '../services/quote_service.dart';
import '../services/reminder_service.dart';
import '../theme.dart';
import 'edit_quote_screen.dart';
import 'edit_reminder_screen.dart';
import 'job_detail_screen.dart';

/// A simple month-grid view of everything time-anchored in the app:
/// service-reminder due dates, completed jobs, and quote expiry dates. Pure
/// UI on top of the existing services — no new persistence.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  /// First day of the month currently in view.
  late DateTime _focusedMonth;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selected = DateTime(now.year, now.month, now.day);
    JobLogService.instance.ensureLoaded();
    QuoteService.instance.ensureLoaded();
    ReminderService.instance.ensureLoaded();
  }

  void _prevMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth =
            DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      });

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _focusedMonth = DateTime(now.year, now.month, 1);
      _selected = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            tooltip: 'Today',
            icon: const Icon(Icons.today),
            onPressed: _jumpToToday,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          JobLogService.instance,
          QuoteService.instance,
          ReminderService.instance,
        ]),
        builder: (context, _) {
          // Build a per-day index of what's on for the focused month, plus
          // the leading/trailing days from neighbouring months that fill the
          // 6-week grid. This makes the cell builder a quick map lookup.
          final cells = _buildMonthCells(_focusedMonth);
          final byDate = _indexEvents(cells);

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
            children: [
              _MonthHeader(
                month: _focusedMonth,
                onPrev: _prevMonth,
                onNext: _nextMonth,
              ),
              const SizedBox(height: 8),
              const _WeekdayStrip(),
              const SizedBox(height: 4),
              _MonthGrid(
                cells: cells,
                focusedMonth: _focusedMonth,
                selected: _selected,
                eventsByDate: byDate,
                onTap: (day) => setState(() => _selected = day),
              ),
              const SizedBox(height: 16),
              _Legend(),
              const SizedBox(height: 16),
              _DayDetail(
                day: _selected,
                events: byDate[_dateKey(_selected)] ?? const _DayEvents(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Returns 42 contiguous days (6 weeks × 7 days) that fully contain the
  /// focused month, starting on Monday of the week containing the 1st.
  List<DateTime> _buildMonthCells(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // Monday = 1, Sunday = 7 in Dart's weekday.
    final leadingDays = firstOfMonth.weekday - DateTime.monday;
    final start = firstOfMonth.subtract(Duration(days: leadingDays));
    return List.generate(42, (i) => start.add(Duration(days: i)));
  }

  Map<int, _DayEvents> _indexEvents(List<DateTime> cells) {
    if (cells.isEmpty) return const {};
    final index = <int, _DayEvents>{
      for (final d in cells) _dateKey(d): const _DayEvents(),
    };

    void put(int key, _DayEvents Function(_DayEvents) update) {
      final cur = index[key];
      if (cur != null) index[key] = update(cur);
    }

    // Reminders — by due date, plus today gets the "overdue" rollup.
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    for (final r in ReminderService.instance.items) {
      if (r.completed) continue;
      final key = _dateKey(r.dueDate);
      if (index.containsKey(key)) {
        put(key,
            (e) => e.copyWith(reminders: [...e.reminders, r]));
      } else if (r.isOverdue(now: now) && index.containsKey(todayKey)) {
        // Anchor overdue items to today so the user sees them on the
        // current month even if they're months in the past.
        put(
          todayKey,
          (e) => e.copyWith(overdueReminders: [...e.overdueReminders, r]),
        );
      }
    }

    // Completed jobs — by completedAt date.
    for (final j in JobLogService.instance.jobs) {
      if (j.status != JobStatus.completed) continue;
      final when = j.completedAt;
      if (when == null) continue;
      final key = _dateKey(when);
      if (index.containsKey(key)) {
        put(key, (e) => e.copyWith(completedJobs: [...e.completedJobs, j]));
      }
    }

    // Quote expiries — sent quotes that haven't been responded to yet.
    for (final q in QuoteService.instance.items) {
      if (!q.status.isOpen) continue;
      final exp = q.expiresAt;
      if (exp == null) continue;
      final key = _dateKey(exp);
      if (index.containsKey(key)) {
        put(key, (e) => e.copyWith(expiringQuotes: [...e.expiringQuotes, q]));
      }
    }

    return index;
  }
}

int _dateKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

/// Bundle of everything happening on a single day, in the calendar's view.
class _DayEvents {
  final List<ServiceReminder> reminders;
  final List<ServiceReminder> overdueReminders;
  final List<Job> completedJobs;
  final List<Quote> expiringQuotes;

  const _DayEvents({
    this.reminders = const [],
    this.overdueReminders = const [],
    this.completedJobs = const [],
    this.expiringQuotes = const [],
  });

  bool get isEmpty =>
      reminders.isEmpty &&
      overdueReminders.isEmpty &&
      completedJobs.isEmpty &&
      expiringQuotes.isEmpty;

  _DayEvents copyWith({
    List<ServiceReminder>? reminders,
    List<ServiceReminder>? overdueReminders,
    List<Job>? completedJobs,
    List<Quote>? expiringQuotes,
  }) =>
      _DayEvents(
        reminders: reminders ?? this.reminders,
        overdueReminders: overdueReminders ?? this.overdueReminders,
        completedJobs: completedJobs ?? this.completedJobs,
        expiringQuotes: expiringQuotes ?? this.expiringQuotes,
      );
}

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  static const _names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(
        tooltip: 'Previous month',
        icon: const Icon(Icons.chevron_left),
        onPressed: onPrev,
      ),
      Expanded(
        child: Text(
          '${_names[month.month - 1]} ${month.year}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      IconButton(
        tooltip: 'Next month',
        icon: const Icon(Icons.chevron_right),
        onPressed: onNext,
      ),
    ]);
  }
}

class _WeekdayStrip extends StatelessWidget {
  const _WeekdayStrip();

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final l in _labels)
          Expanded(
            child: Text(
              l,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final List<DateTime> cells;
  final DateTime focusedMonth;
  final DateTime selected;
  final Map<int, _DayEvents> eventsByDate;
  final void Function(DateTime day) onTap;
  const _MonthGrid({
    required this.cells,
    required this.focusedMonth,
    required this.selected,
    required this.eventsByDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    final selectedKey = _dateKey(selected);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cells.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) {
        final day = cells[i];
        final inMonth = day.month == focusedMonth.month;
        final isToday = _dateKey(day) == todayKey;
        final isSelected = _dateKey(day) == selectedKey;
        final ev = eventsByDate[_dateKey(day)] ?? const _DayEvents();
        return _DayCell(
          day: day,
          inMonth: inMonth,
          isToday: isToday,
          isSelected: isSelected,
          events: ev,
          onTap: () => onTap(day),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final _DayEvents events;
  final VoidCallback onTap;
  const _DayCell({
    required this.day,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.events,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dotSpecs = <(Color, int)>[
      if (events.overdueReminders.isNotEmpty)
        (Colors.redAccent, events.overdueReminders.length),
      if (events.reminders.isNotEmpty)
        (AppColors.accent, events.reminders.length),
      if (events.completedJobs.isNotEmpty)
        (Colors.green, events.completedJobs.length),
      if (events.expiringQuotes.isNotEmpty)
        (AppColors.primary, events.expiringQuotes.length),
    ];
    final fillColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.18)
        : Colors.transparent;
    final borderColor = isToday
        ? AppColors.accent
        : (isSelected ? AppColors.primary : Colors.transparent);
    final numberColor = !inMonth
        ? AppColors.muted.withValues(alpha: 0.6)
        : (isToday ? AppColors.accent : null);
    return Padding(
      padding: const EdgeInsets.all(2),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: isToday ? 2 : 1),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 12,
                    color: numberColor,
                    fontWeight: isToday || isSelected
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
              if (dotSpecs.isNotEmpty)
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 2,
                  children: [
                    for (final spec in dotSpecs.take(4))
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: spec.$1,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: const [
        _LegendDot(color: Colors.redAccent, label: 'Overdue follow-up'),
        _LegendDot(color: AppColors.accent, label: 'Follow-up due'),
        _LegendDot(color: Colors.green, label: 'Completed job'),
        _LegendDot(color: AppColors.primary, label: 'Quote expiring'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted)),
    ]);
  }
}

class _DayDetail extends StatelessWidget {
  final DateTime day;
  final _DayEvents events;
  const _DayDetail({required this.day, required this.events});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final dayLabel =
        '${_weekdays[day.weekday - 1]} ${day.day} ${_months[day.month - 1]}';
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.event_note, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(dayLabel,
                  style: Theme.of(context).textTheme.titleLarge),
            ]),
            const SizedBox(height: 8),
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                    'Nothing scheduled. Pick another day or add a service reminder.'),
              )
            else ...[
              if (events.overdueReminders.isNotEmpty) ...[
                _SectionLabel('Overdue follow-ups',
                    color: Colors.redAccent),
                for (final r in events.overdueReminders)
                  _ReminderTile(reminder: r),
              ],
              if (events.reminders.isNotEmpty) ...[
                _SectionLabel('Follow-ups due', color: AppColors.accent),
                for (final r in events.reminders)
                  _ReminderTile(reminder: r),
              ],
              if (events.completedJobs.isNotEmpty) ...[
                _SectionLabel('Jobs completed', color: Colors.green),
                for (final j in events.completedJobs) _JobTile(job: j),
              ],
              if (events.expiringQuotes.isNotEmpty) ...[
                _SectionLabel('Quotes expiring',
                    color: AppColors.primary),
                for (final q in events.expiringQuotes)
                  _QuoteTile(quote: q),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, {required this.color});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 4),
        child: Row(children: [
          Container(width: 4, height: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ]),
      );
}

class _ReminderTile extends StatelessWidget {
  final ServiceReminder reminder;
  const _ReminderTile({required this.reminder});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        reminder.isOverdue() ? Icons.error : Icons.schedule,
        color: reminder.isOverdue() ? Colors.redAccent : AppColors.accent,
      ),
      title: Text(reminder.customerName.isEmpty
          ? 'Untitled'
          : reminder.customerName),
      subtitle: Text(
        reminder.description.isEmpty
            ? 'Service follow-up'
            : reminder.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditReminderScreen(existing: reminder),
        ),
      ),
    );
  }
}

class _JobTile extends StatelessWidget {
  final Job job;
  const _JobTile({required this.job});
  @override
  Widget build(BuildContext context) {
    final total = job.totalCostAt(DateTime.now());
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(job.customer.isEmpty ? 'Untitled' : job.customer),
      subtitle: Text(
        job.description.isEmpty
            ? '£${total.toStringAsFixed(2)}'
            : '${job.description} · £${total.toStringAsFixed(2)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job.id)),
      ),
    );
  }
}

class _QuoteTile extends StatelessWidget {
  final Quote quote;
  const _QuoteTile({required this.quote});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.receipt_long, color: AppColors.primary),
      title: Text(
          '${quote.quoteRef} · ${quote.customer.isEmpty ? "Untitled" : quote.customer}'),
      subtitle: Text(
        '${quote.status.label} · £${quote.subtotalGbp.toStringAsFixed(2)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditQuoteScreen(existing: quote),
        ),
      ),
    );
  }
}
