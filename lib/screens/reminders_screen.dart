import 'package:flutter/material.dart';

import '../data/job_log_data.dart';
import '../data/job_template_data.dart';
import '../data/reminder_data.dart';
import '../services/job_template_service.dart';
import '../services/reminder_service.dart';
import '../theme.dart';
import 'edit_reminder_screen.dart';
import 'job_detail_screen.dart';
import 'new_job_screen.dart';
import '../data/customer_data.dart';
import '../services/customer_service.dart';

/// Lists every service follow-up grouped by urgency. Tapping any item lets
/// the user edit, mark-done, snooze, or "do it now" — which jumps into the
/// new-job flow with the customer + description prefilled.
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    ReminderService.instance.ensureLoaded();
    JobTemplateService.instance.ensureLoaded();
    CustomerService.instance.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service reminders')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_alert),
        label: const Text('New reminder'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditReminderScreen()),
        ),
      ),
      body: AnimatedBuilder(
        animation: ReminderService.instance,
        builder: (context, _) {
          final svc = ReminderService.instance;
          final overdue = svc.overdue();
          final dueSoon = svc.dueSoon();
          final later = svc.later();
          final completed = svc.items.where((r) => r.completed).toList();

          if (svc.items.isEmpty) return const _EmptyState();

          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            children: [
              const _IntroCard(),
              const SizedBox(height: 12),
              if (overdue.isNotEmpty) ...[
                _SectionHeader('Overdue', accent: Colors.redAccent),
                for (final r in overdue) _ReminderRow(reminder: r),
                const SizedBox(height: 8),
              ],
              if (dueSoon.isNotEmpty) ...[
                _SectionHeader('Due soon', accent: AppColors.accent),
                for (final r in dueSoon) _ReminderRow(reminder: r),
                const SizedBox(height: 8),
              ],
              if (later.isNotEmpty) ...[
                _SectionHeader('Later', accent: AppColors.primary),
                for (final r in later) _ReminderRow(reminder: r),
                const SizedBox(height: 8),
              ],
              if (completed.isNotEmpty) ...[
                _SectionHeader('Done', accent: AppColors.muted),
                for (final r in completed)
                  _ReminderRow(reminder: r, dimmed: true),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.event_repeat, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Follow-ups bring customers back',
                  style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 6),
            const Text(
                'Schedule annual boiler services, gas safety renewals, magnetic-filter checks. You get a phone notification on the due date and the reminder appears here. Tap "Do now" to start the job in one tap.'),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  final Color accent;
  const _SectionHeader(this.text, {required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Row(children: [
        Container(width: 4, height: 16, color: accent),
        const SizedBox(width: 8),
        Text(text.toUpperCase(),
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            )),
      ]),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  final ServiceReminder reminder;
  final bool dimmed;
  const _ReminderRow({required this.reminder, this.dimmed = false});

  Color _accent(BuildContext context) {
    if (reminder.completed) return AppColors.muted;
    if (reminder.isOverdue()) return Colors.redAccent;
    if (reminder.isDueWithin(const Duration(days: 30))) {
      return AppColors.accent;
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: dimmed ? 0.7 : 1,
        child: Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditReminderScreen(existing: reminder),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        reminder.completed
                            ? Icons.check_circle
                            : Icons.event_available,
                        color: accent,
                      ),
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
                            Text(
                              reminder.description,
                              style:
                                  Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    _DueChip(reminder: reminder, color: accent),
                  ]),
                  if (!reminder.completed) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _doNow(context),
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Do now'),
                          style: ElevatedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              ReminderService.instance.markDone(reminder.id),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Mark done'),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _snooze(context),
                          icon:
                              const Icon(Icons.snooze, size: 18),
                          label: const Text('Snooze'),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: TextButton.icon(
                        onPressed: () =>
                            ReminderService.instance.reopen(reminder.id),
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Reopen'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _doNow(BuildContext context) async {
    final nav = Navigator.of(context);
    JobTemplate? template;
    if (reminder.templateId != null) {
      template =
          JobTemplateService.instance.findById(reminder.templateId!);
    }
    Customer? prefillCustomer;
    if (reminder.customerId.isNotEmpty) {
      final c = CustomerService.instance.findById(reminder.customerId);
      prefillCustomer = c;
    }
    final job = await nav.push<Job?>(
      MaterialPageRoute(
        builder: (_) => NewJobScreen(
          prefillCustomer: prefillCustomer,
          prefillTemplate: template,
        ),
      ),
    );
    if (job == null) return;
    // Mark the reminder done now that the follow-up job exists.
    await ReminderService.instance.markDone(reminder.id);
    if (!nav.mounted) return;
    nav.push(
      MaterialPageRoute(
          builder: (_) => JobDetailScreen(jobId: job.id)),
    );
  }

  Future<void> _snooze(BuildContext context) async {
    final picked = await showModalBottomSheet<int?>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              dense: true,
              title: Text('Snooze this reminder'),
              subtitle: Text('Push the due date out.'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('+ 1 week'),
              onTap: () => Navigator.pop(context, 7),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('+ 1 month'),
              onTap: () => Navigator.pop(context, 30),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('+ 3 months'),
              onTap: () => Navigator.pop(context, 90),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('+ 6 months'),
              onTap: () => Navigator.pop(context, 180),
            ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await ReminderService.instance
        .snooze(reminder.id, Duration(days: picked));
  }
}

class _DueChip extends StatelessWidget {
  final ServiceReminder reminder;
  final Color color;
  const _DueChip({required this.reminder, required this.color});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due =
        DateTime(reminder.dueDate.year, reminder.dueDate.month, reminder.dueDate.day);
    final days = due.difference(today).inDays;
    String label;
    if (reminder.completed) {
      label = 'Done';
    } else if (days == 0) {
      label = 'Today';
    } else if (days < 0) {
      label = '${-days}d late';
    } else if (days < 60) {
      label = 'in ${days}d';
    } else if (days < 365) {
      label = 'in ${(days / 30).round()}mo';
    } else {
      label = 'in ${(days / 365).round()}y';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5)),
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
            const Icon(Icons.event_available,
                size: 64, color: AppColors.muted),
            const SizedBox(height: 8),
            Text('No follow-ups scheduled',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'When you mark a job complete, you can schedule a return visit (e.g. annual boiler service). They appear here grouped by urgency, with a phone notification on the due date.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_alert),
              label: const Text('Add a reminder'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EditReminderScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
