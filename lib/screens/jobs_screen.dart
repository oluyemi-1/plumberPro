import 'dart:async';

import 'package:flutter/material.dart';

import '../data/job_log_data.dart';
import '../data/reminder_data.dart';
import '../services/job_log_service.dart';
import '../services/reminder_service.dart';
import '../theme.dart';
import 'calendar_screen.dart';
import 'customers_screen.dart';
import 'dashboard_screen.dart';
import 'expenses_screen.dart';
import 'job_detail_screen.dart';
import 'new_job_screen.dart';
import 'quotes_screen.dart';
import 'reminders_screen.dart';
import 'templates_screen.dart';

/// List of jobs with the active timer prominently at the top.
class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    JobLogService.instance.ensureLoaded();
    ReminderService.instance.ensureLoaded();
    // Tick once a second so the running-timer card stays live.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job log'),
        actions: [
          AnimatedBuilder(
            animation: ReminderService.instance,
            builder: (context, _) {
              final n = ReminderService.instance.attentionCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: 'Service reminders',
                    icon: const Icon(Icons.notifications),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RemindersScreen()),
                    ),
                  ),
                  if (n > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          n > 9 ? '9+' : '$n',
                          textAlign: TextAlign.center,
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
            tooltip: 'Calendar',
            icon: const Icon(Icons.calendar_month),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Quotes & estimates',
            icon: const Icon(Icons.note_add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuotesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Income dashboard',
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Expenses & mileage',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExpensesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Job templates',
            icon: const Icon(Icons.layers_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TemplatesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Customers',
            icon: const Icon(Icons.people_alt),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomersScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New job'),
        onPressed: () async {
          final nav = Navigator.of(context);
          final job = await nav.push<Job?>(
            MaterialPageRoute(builder: (_) => const NewJobScreen()),
          );
          if (job != null && mounted) {
            nav.push(
              MaterialPageRoute(
                  builder: (_) => JobDetailScreen(jobId: job.id)),
            );
          }
        },
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge(
            [JobLogService.instance, ReminderService.instance]),
        builder: (context, _) {
          final svc = JobLogService.instance;
          final jobs = svc.jobs;
          final running = svc.runningJob;
          final active = jobs
              .where((j) =>
                  j.status == JobStatus.active && j.id != running?.id)
              .toList();
          final completed = jobs
              .where((j) => j.status == JobStatus.completed)
              .toList();
          final remSvc = ReminderService.instance;
          final overdue = remSvc.overdue();
          final dueSoon = remSvc.dueSoon();

          if (jobs.isEmpty && overdue.isEmpty && dueSoon.isEmpty) {
            return const _EmptyState();
          }

          // Flatten the heterogeneous list — only the visible rows get built
          // via ListView.builder. Important once a long-running plumber has
          // hundreds of completed jobs.
          final items = <Object>[];
          if (running != null) items.add(_RunningSlot(running));
          if (overdue.isNotEmpty || dueSoon.isNotEmpty) {
            items.add('Service follow-ups');
            items.addAll(overdue);
            items.addAll(dueSoon);
          }
          if (active.isNotEmpty) {
            items.add('Active');
            items.addAll(active);
          }
          if (completed.isNotEmpty) {
            items.add('Completed');
            items.addAll(completed);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              if (item is _RunningSlot) {
                return _RunningJobCard(job: item.job, now: DateTime.now());
              }
              if (item is String) return _SectionHeader(item);
              if (item is ServiceReminder) {
                return _ReminderRow(reminder: item);
              }
              if (item is Job) return _JobRow(job: item);
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

/// Sentinel wrapper that flags the currently-running job in the heterogeneous
/// items list — distinct from a regular `Job` so the builder picks the
/// dedicated running-job card.
class _RunningSlot {
  final Job job;
  const _RunningSlot(this.job);
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
        child: Text(text,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            )),
      );
}

class _RunningJobCard extends StatelessWidget {
  final Job job;
  final DateTime now;
  const _RunningJobCard({required this.job, required this.now});

  @override
  Widget build(BuildContext context) {
    final elapsed = job.totalTime(now);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => JobDetailScreen(jobId: job.id)),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, Color(0xFFB73210)],
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 8,
                          height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text('TIMER RUNNING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            )),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Stop timer',
                    icon: const Icon(Icons.stop_circle, color: Colors.white),
                    onPressed: () =>
                        JobLogService.instance.stopTimer(job.id),
                  ),
                ]),
                const SizedBox(height: 6),
                Text(
                  job.customer.isEmpty ? 'Untitled job' : job.customer,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (job.address.isNotEmpty)
                  Text(job.address,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  formatDuration(elapsed),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${formatHours(elapsed)} hours · ${formatGbp(job.labourCostAt(now))} labour so far',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JobRow extends StatelessWidget {
  final Job job;
  const _JobRow({required this.job});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dur = job.totalTime(now);
    final total = job.totalCostAt(now);
    final isCompleted = job.status == JobStatus.completed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => JobDetailScreen(jobId: job.id)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: (isCompleted ? Colors.green : AppColors.primary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.work,
                    color: isCompleted ? Colors.green : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.customer.isEmpty ? 'Untitled job' : job.customer,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (job.description.isNotEmpty)
                        Text(
                          job.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Wrap(spacing: 8, runSpacing: 4, children: [
                        _Pill(
                          label: '${formatHours(dur)} h',
                          color: AppColors.primary,
                        ),
                        _Pill(
                          label: formatGbp(total),
                          color: AppColors.accent,
                        ),
                        if (job.materials.isNotEmpty)
                          _Pill(
                            label:
                                '${job.materials.length} part${job.materials.length == 1 ? '' : 's'}',
                            color: AppColors.coldWater,
                          ),
                      ]),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
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
            const Icon(Icons.work_outline,
                size: 64, color: AppColors.muted),
            const SizedBox(height: 8),
            Text('No jobs yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Tap New job to log a customer call-out. Time, parts and notes are saved against the job.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create your first job'),
              onPressed: () async {
                final job = await Navigator.push<Job?>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NewJobScreen()),
                );
                if (job != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => JobDetailScreen(jobId: job.id)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final ServiceReminder reminder;
  const _ReminderRow({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final overdue = reminder.isOverdue();
    final accent = overdue ? Colors.redAccent : AppColors.accent;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(reminder.dueDate.year, reminder.dueDate.month,
        reminder.dueDate.day);
    final days = due.difference(today).inDays;
    final dueLabel = days == 0
        ? 'Today'
        : days < 0
            ? '${-days}d late'
            : days < 60
                ? 'in ${days}d'
                : 'in ${(days / 30).round()}mo';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        color: accent.withValues(alpha: 0.06),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RemindersScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.event_available, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.customerName.isEmpty
                          ? 'Untitled'
                          : reminder.customerName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (reminder.description.isNotEmpty)
                      Text(reminder.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  dueLabel,
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
