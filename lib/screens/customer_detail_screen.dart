import 'package:flutter/material.dart';

import '../data/customer_data.dart';
import '../data/job_log_data.dart';
import '../data/quote_data.dart';
import '../data/reminder_data.dart';
import '../services/customer_service.dart';
import '../services/expense_service.dart';
import '../services/job_log_service.dart';
import '../services/quote_service.dart';
import '../services/reminder_service.dart';
import '../theme.dart';
import 'edit_customer_screen.dart';
import 'edit_quote_screen.dart';
import 'edit_reminder_screen.dart';
import 'job_detail_screen.dart';
import 'new_job_screen.dart';

/// Hub for everything tied to a customer: lifetime stats, open quotes,
/// upcoming service reminders, every job they've ever had, and the total
/// the user has spent on parts/mileage for them.
class CustomerDetailScreen extends StatelessWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        CustomerService.instance,
        JobLogService.instance,
        QuoteService.instance,
        ReminderService.instance,
        ExpenseService.instance,
      ]),
      builder: (context, _) {
        final c = CustomerService.instance.findById(customerId);
        if (c == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Customer')),
            body: const Center(
                child: Text('This customer no longer exists.')),
          );
        }
        final jobs = JobLogService.instance.jobs
            .where((j) => j.customerId == c.id)
            .toList();
        final active =
            jobs.where((j) => j.status == JobStatus.active).toList();
        final completed = jobs
            .where((j) => j.status == JobStatus.completed)
            .toList();

        // Cross-service aggregations.
        final reminders = ReminderService.instance.items
            .where((r) => r.customerId == c.id)
            .toList();
        final openReminders =
            reminders.where((r) => !r.completed).toList();
        final openQuotes = QuoteService.instance.items
            .where((q) =>
                q.customerId == c.id && q.status.isOpen)
            .toList();
        final acceptedQuotes = QuoteService.instance.items
            .where((q) =>
                q.customerId == c.id && q.status == QuoteStatus.accepted)
            .toList();
        final linkedExpensesTotal = ExpenseService.instance
            .totalForJobs(jobs.map((j) => j.id));

        return Scaffold(
          appBar: AppBar(
            title: Text(c.name.isEmpty ? 'Customer' : c.name),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditCustomerScreen(existing: c)),
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
                MaterialPageRoute(
                  builder: (_) => NewJobScreen(prefillCustomer: c),
                ),
              );
              if (job != null) {
                nav.push(
                  MaterialPageRoute(
                      builder: (_) =>
                          JobDetailScreen(jobId: job.id)),
                );
              }
            },
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            children: [
              _ContactCard(customer: c),
              const SizedBox(height: 12),
              _LifetimeStats(
                customer: c,
                jobs: jobs,
                completed: completed,
                linkedExpensesTotal: linkedExpensesTotal,
              ),
              const SizedBox(height: 12),
              _QuickActions(customer: c),
              if (c.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                _NotesCard(notes: c.notes),
              ],
              if (openReminders.isNotEmpty) ...[
                const SizedBox(height: 12),
                _RemindersCard(reminders: openReminders),
              ],
              if (openQuotes.isNotEmpty) ...[
                const SizedBox(height: 12),
                _QuotesCard(
                  title: 'Open quotes',
                  quotes: openQuotes,
                  emptyMessage: '',
                ),
              ],
              if (acceptedQuotes.isNotEmpty) ...[
                const SizedBox(height: 12),
                _QuotesCard(
                  title: 'Accepted quotes',
                  quotes: acceptedQuotes,
                  emptyMessage: '',
                ),
              ],
              const SizedBox(height: 12),
              _JobsHistory(
                customer: c,
                active: active,
                completed: completed,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContactCard extends StatelessWidget {
  final Customer customer;
  const _ContactCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final c = customer;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  c.firstLetter,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        style:
                            Theme.of(context).textTheme.headlineSmall),
                    if (c.address.isNotEmpty)
                      Text(c.address,
                          style:
                              Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ]),
            if (c.phone.isNotEmpty || c.email.isNotEmpty) ...[
              const SizedBox(height: 12),
              if (c.phone.isNotEmpty)
                _row(Icons.phone, c.phone),
              if (c.email.isNotEmpty)
                _row(Icons.email, c.email),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Icon(icon, color: AppColors.muted, size: 18),
          const SizedBox(width: 8),
          Expanded(child: SelectableText(text)),
        ]),
      );
}

class _LifetimeStats extends StatelessWidget {
  final Customer customer;
  final List<Job> jobs;
  final List<Job> completed;
  final double linkedExpensesTotal;
  const _LifetimeStats({
    required this.customer,
    required this.jobs,
    required this.completed,
    required this.linkedExpensesTotal,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final billed = completed.fold<double>(
        0, (a, j) => a + j.totalCostAt(now));
    final hoursSeconds = jobs.fold<int>(
        0, (a, j) => a + j.totalTime(now).inSeconds);
    final hours = hoursSeconds / 3600.0;
    final avgPerVisit =
        completed.isEmpty ? 0.0 : billed / completed.length;
    final lastVisit = completed.isEmpty
        ? null
        : completed
            .map((j) => j.completedAt ?? j.createdAt)
            .reduce((a, b) => a.isAfter(b) ? a : b);
    final since = customer.createdAt;
    final daysAsCustomer =
        DateTime(now.year, now.month, now.day).difference(
                DateTime(since.year, since.month, since.day)).inDays;

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
            const Text(
              'LIFETIME WITH YOU',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '£${billed.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              completed.isEmpty
                  ? 'No completed jobs yet — billed total will fill in once jobs are marked complete.'
                  : '${completed.length} completed job${completed.length == 1 ? '' : 's'} · avg £${avgPerVisit.toStringAsFixed(2)}/visit',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _MiniStat(
                  label: 'Hours',
                  value: hours == hours.roundToDouble()
                      ? hours.toStringAsFixed(0)
                      : hours.toStringAsFixed(1)),
              _MiniStat(
                label: 'Spent on parts',
                value: '£${linkedExpensesTotal.toStringAsFixed(2)}',
              ),
              _MiniStat(
                label: 'Last visit',
                value: lastVisit == null
                    ? '—'
                    : _ago(lastVisit, now),
              ),
              _MiniStat(
                label: 'Customer for',
                value: _customerSince(daysAsCustomer),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  static String _ago(DateTime when, DateTime now) {
    final diff = now.difference(when);
    if (diff.inDays < 1) return 'today';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 60) return '${(diff.inDays / 7).round()}w ago';
    return '${(diff.inDays / 30).round()}mo ago';
  }

  static String _customerSince(int days) {
    if (days <= 0) return 'today';
    if (days < 30) return '${days}d';
    if (days < 365) return '${(days / 30).round()}mo';
    final years = (days / 365).floor();
    final extraMonths = ((days - years * 365) / 30).round();
    if (extraMonths == 0) return '${years}y';
    return '${years}y ${extraMonths}mo';
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

class _QuickActions extends StatelessWidget {
  final Customer customer;
  const _QuickActions({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditQuoteScreen(prefillCustomer: customer),
                  ),
                ),
                icon: const Icon(Icons.note_add),
                label: const Text('Quote'),
              ),
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditReminderScreen(
                      prefillCustomerId: customer.id,
                      prefillCustomerName: customer.name,
                      prefillAddress: customer.address,
                    ),
                  ),
                ),
                icon: const Icon(Icons.event_available),
                label: const Text('Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notes',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            SelectableText(notes,
                style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _RemindersCard extends StatelessWidget {
  final List<ServiceReminder> reminders;
  const _RemindersCard({required this.reminders});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.event_available,
                  color: AppColors.accent),
              const SizedBox(width: 6),
              Text('Service follow-ups',
                  style: Theme.of(context).textTheme.titleLarge),
            ]),
            const SizedBox(height: 4),
            for (final r in reminders)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  r.isOverdue() ? Icons.error : Icons.schedule,
                  color: r.isOverdue()
                      ? Colors.redAccent
                      : AppColors.accent,
                ),
                title: Text(r.description.isEmpty
                    ? 'Follow-up'
                    : r.description),
                subtitle: Text(_dueLabel(r)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditReminderScreen(existing: r),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _dueLabel(ServiceReminder r) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(r.dueDate.year, r.dueDate.month, r.dueDate.day);
    final days = due.difference(today).inDays;
    if (days == 0) return 'Due today';
    if (days < 0) return '${-days} days overdue';
    if (days < 60) return 'Due in $days days';
    return 'Due in ${(days / 30).round()} months';
  }
}

class _QuotesCard extends StatelessWidget {
  final String title;
  final List<Quote> quotes;
  final String emptyMessage;
  const _QuotesCard({
    required this.title,
    required this.quotes,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.note_add, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(title,
                  style: Theme.of(context).textTheme.titleLarge),
            ]),
            const SizedBox(height: 4),
            for (final q in quotes)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.receipt_long),
                title: Text(
                    '${q.quoteRef} · £${q.subtotalGbp.toStringAsFixed(2)}'),
                subtitle: Text(
                  q.description.isEmpty
                      ? q.status.label
                      : '${q.status.label} · ${q.description}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditQuoteScreen(existing: q),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _JobsHistory extends StatelessWidget {
  final Customer customer;
  final List<Job> active;
  final List<Job> completed;
  const _JobsHistory({
    required this.customer,
    required this.active,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job history',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            if (active.isEmpty && completed.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                    'No jobs yet for this customer. Tap New job to create one.'),
              )
            else ...[
              if (active.isNotEmpty) ...[
                const _SectionLabel('Active'),
                for (final j in active) _JobRow(job: j),
              ],
              if (completed.isNotEmpty) ...[
                const _SectionLabel('Completed'),
                for (final j in completed) _JobRow(job: j),
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
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
        child: Text(text.toUpperCase(),
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            )),
      );
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isCompleted ? Icons.check_circle : Icons.work,
        color: isCompleted ? Colors.green : AppColors.primary,
      ),
      title: Text(
        job.description.isEmpty
            ? 'Job ${_short(job.id)}'
            : job.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_fmt(job.createdAt)}  ·  ${formatHours(dur)} h  ·  ${formatGbp(total)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => JobDetailScreen(jobId: job.id)),
      ),
    );
  }

  String _short(String id) =>
      id.length > 10 ? id.substring(0, 10) : id;
  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
