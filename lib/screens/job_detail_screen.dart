import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../data/expense_data.dart';
import '../data/inventory_data.dart';
import '../data/job_log_data.dart';
import '../services/expense_service.dart';
import '../services/inventory_service.dart';
import '../services/job_log_service.dart';
import '../services/job_pdf_export.dart';
import '../theme.dart';
import '../widgets/voice_note_player.dart';
import '../widgets/voice_recorder_sheet.dart';
import 'edit_expense_screen.dart';
import 'edit_reminder_screen.dart';
import 'photo_annotate_screen.dart';
import 'signature_capture_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Timer? _ticker;
  late final TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController();
    final job = JobLogService.instance.findById(widget.jobId);
    if (job != null) _notesCtrl.text = job.notes;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final j = JobLogService.instance.findById(widget.jobId);
      if (j != null && j.hasRunningTimer) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: JobLogService.instance,
      builder: (context, _) {
        final job = JobLogService.instance.findById(widget.jobId);
        if (job == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Job')),
            body: const Center(child: Text('This job has been deleted.')),
          );
        }
        final now = DateTime.now();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              job.customer.isEmpty ? 'Untitled job' : job.customer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                tooltip: 'Share summary',
                icon: const Icon(Icons.share),
                onPressed: () => _shareSummary(context, job, now),
              ),
              PopupMenuButton<String>(
                onSelected: (v) => _onMenu(context, job, v),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'pdf',
                    child: Text('Export as PDF'),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit details'),
                  ),
                  PopupMenuItem(
                    value: job.status == JobStatus.completed
                        ? 'reopen'
                        : 'complete',
                    child: Text(job.status == JobStatus.completed
                        ? 'Reopen job'
                        : 'Mark complete'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete job',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              _Header(job: job),
              const SizedBox(height: 12),
              _TimerCard(job: job, now: now),
              const SizedBox(height: 12),
              _TimeEntriesCard(job: job, now: now),
              const SizedBox(height: 12),
              _MaterialsCard(job: job),
              const SizedBox(height: 12),
              _LinkedExpensesCard(jobId: job.id),
              const SizedBox(height: 12),
              _PhotosCard(job: job),
              const SizedBox(height: 12),
              _VoiceNotesCard(job: job),
              const SizedBox(height: 12),
              _NotesCard(controller: _notesCtrl, jobId: job.id),
              const SizedBox(height: 12),
              _TotalsCard(job: job, now: now),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onMenu(BuildContext context, Job job, String v) async {
    switch (v) {
      case 'pdf':
        await _exportPdf(context, job);
        break;
      case 'edit':
        await _editDetails(context, job);
        break;
      case 'complete':
        await JobLogService.instance.markComplete(job.id);
        if (!mounted) return;
        await _maybeOfferFollowUp(job);
        break;
      case 'reopen':
        await JobLogService.instance.reopen(job.id);
        break;
      case 'delete':
        final nav = Navigator.of(context);
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete this job?'),
            content: const Text(
                'All time entries, materials and notes will be removed.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (ok == true) {
          await JobLogService.instance.deleteJob(job.id);
          if (!mounted) return;
          nav.pop();
        }
        break;
    }
  }

  /// After a job is marked complete, offer the user a one-tap way to
  /// schedule the next visit (annual boiler service is the canonical case).
  Future<void> _maybeOfferFollowUp(Job job) async {
    final months = await showModalBottomSheet<int?>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(children: [
                const Icon(Icons.event_repeat, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Schedule a follow-up?',
                    style: Theme.of(sheetCtx).textTheme.titleMedium),
              ]),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                  'Lock in the next visit so it isn\'t forgotten. You\'ll get a phone notification on the due date.'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.local_fire_department),
              title: const Text('Annual boiler service (12 months)'),
              onTap: () => Navigator.pop(sheetCtx, 12),
            ),
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text('Landlord gas safety (12 months)'),
              onTap: () => Navigator.pop(sheetCtx, 12),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Mid-year check (6 months)'),
              onTap: () => Navigator.pop(sheetCtx, 6),
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Custom date…'),
              onTap: () => Navigator.pop(sheetCtx, -1),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Skip'),
              onTap: () => Navigator.pop(sheetCtx, 0),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
    if (months == null || months == 0) return;
    if (!mounted) return;
    final now = DateTime.now();
    final dueDate = months == -1
        ? null
        : DateTime(now.year, now.month + months, now.day);
    final description = job.description.isEmpty
        ? 'Service follow-up'
        : job.description;
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditReminderScreen(
          prefillCustomerId: job.customerId,
          prefillCustomerName: job.customer,
          prefillAddress: job.address,
          prefillDescription: description,
          prefillDueDate: dueDate,
          sourceJobId: job.id,
        ),
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, Job job) async {
    final svc = JobLogService.instance;
    final name = TextEditingController(text: svc.businessName);
    final contact = TextEditingController(text: svc.businessContact);
    final invoice = TextEditingController(
      text: 'JOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
    );
    bool includeVat = false;
    bool includePhotos = job.photos.isNotEmpty;
    SignatureCapture? signature;
    final messenger = ScaffoldMessenger.of(context);

    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Export as PDF'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Your business name',
                      hintText: 'e.g. A. Smith Plumbing & Heating',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: contact,
                    decoration: const InputDecoration(
                      labelText: 'Contact line',
                      hintText: '07xxx · email · Gas Safe 1234567',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: invoice,
                    decoration: const InputDecoration(
                      labelText: 'Invoice / job reference',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Include VAT at 20%'),
                    subtitle: const Text(
                        'Only if you are VAT-registered'),
                    value: includeVat,
                    onChanged: (v) => setState(() => includeVat = v),
                  ),
                  if (job.photos.isNotEmpty)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                          'Include ${job.photos.length} photo${job.photos.length == 1 ? '' : 's'}'),
                      value: includePhotos,
                      onChanged: (v) =>
                          setState(() => includePhotos = v),
                    ),
                  const SizedBox(height: 4),
                  Card(
                    margin: EdgeInsets.zero,
                    color: AppColors.primary.withValues(alpha: 0.06),
                    child: ListTile(
                      leading: Icon(
                        signature == null
                            ? Icons.draw
                            : Icons.check_circle,
                        color: signature == null
                            ? AppColors.primary
                            : Colors.green,
                      ),
                      title: Text(signature == null
                          ? 'Capture customer signature'
                          : 'Signed by ${signature!.name}'),
                      subtitle: Text(signature == null
                          ? 'Adds a signed sign-off block to the bottom of the PDF.'
                          : 'Tap to re-sign, or use the cross to clear.'),
                      trailing: signature == null
                          ? const Icon(Icons.chevron_right)
                          : IconButton(
                              tooltip: 'Clear signature',
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(() => signature = null),
                            ),
                      onTap: () async {
                        final result =
                            await Navigator.push<SignatureCapture?>(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => SignatureCaptureScreen(
                              prefillName: job.customer,
                            ),
                          ),
                        );
                        if (result != null) {
                          setState(() => signature = result);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate'),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );
    if (go != true) return;

    // Persist business profile so next export remembers it.
    await svc.setBusinessProfile(
      name: name.text,
      contact: contact.text,
    );

    final options = PdfExportOptions(
      businessName: name.text.trim(),
      businessContact: contact.text.trim(),
      invoiceNumber: invoice.text.trim(),
      includeVat: includeVat,
      vatRate: svc.vatRate,
      includePhotos: includePhotos,
      signatureBytes: signature?.bytes,
      signerName: signature?.name,
      signedAt: signature?.signedAt,
    );

    try {
      await JobPdfExport.exportAndShare(job: job, options: options);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not generate PDF: $e')),
      );
    }
  }

  Future<void> _editDetails(BuildContext context, Job job) async {
    final c = TextEditingController(text: job.customer);
    final a = TextEditingController(text: job.address);
    final d = TextEditingController(text: job.description);
    final r = TextEditingController(
        text: job.hourlyRateGbp.toStringAsFixed(0));
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit job details'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: c,
                  decoration:
                      const InputDecoration(labelText: 'Customer'),
                ),
                TextField(
                  controller: a,
                  decoration:
                      const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: d,
                  minLines: 1,
                  maxLines: 5,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: r,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                      labelText: 'Hourly rate (£)'),
                ),
              ],
            ),
          ),
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
    if (saved == true) {
      await JobLogService.instance.updateJob(job.copyWith(
        customer: c.text,
        address: a.text,
        description: d.text,
        hourlyRateGbp:
            double.tryParse(r.text.trim()) ?? job.hourlyRateGbp,
      ));
    }
  }

  void _shareSummary(BuildContext context, Job job, DateTime now) {
    final lines = <String>[];
    lines.add('Job summary');
    lines.add('Customer: ${job.customer.isEmpty ? "—" : job.customer}');
    if (job.address.isNotEmpty) lines.add('Address: ${job.address}');
    if (job.description.isNotEmpty) {
      lines.add('Description: ${job.description}');
    }
    lines.add('Status: ${job.status.label}');
    lines.add('Hourly rate: ${formatGbp(job.hourlyRateGbp)}');
    lines.add('');
    lines.add('Time on the job');
    final dur = job.totalTime(now);
    lines.add('  Total: ${formatHours(dur)} hours (${formatDuration(dur)})');
    if (job.entries.isNotEmpty) {
      for (final e in job.entries) {
        final s = e.durationAt(now);
        lines.add(
            '  ${_fmtDate(e.start)}  ${formatHours(s)} h${e.isRunning ? "  (running)" : ""}');
      }
    }
    if (job.materials.isNotEmpty) {
      lines.add('');
      lines.add('Materials');
      for (final m in job.materials) {
        lines.add(
            '  ${m.description}  ${m.quantity} × ${formatGbp(m.unitPriceGbp)} = ${formatGbp(m.totalGbp)}');
      }
    }
    if (job.photos.isNotEmpty) {
      lines.add('');
      lines.add('Photos');
      for (final p in job.photos) {
        final cap = p.caption.isEmpty ? '' : ' — ${p.caption}';
        lines.add('  ${_fmtDate(p.takenAt)}$cap');
      }
    }
    lines.add('');
    lines.add(
        'Labour: ${formatGbp(job.labourCostAt(now))}   Materials: ${formatGbp(job.materialsCost)}');
    lines.add('Total: ${formatGbp(job.totalCostAt(now))}');
    if (job.notes.trim().isNotEmpty) {
      lines.add('');
      lines.add('Notes');
      lines.add(job.notes);
    }
    final summary = lines.join('\n');
    Clipboard.setData(ClipboardData(text: summary));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Summary copied to clipboard. Paste it into an email, an invoice or a notes app.')),
    );
  }

  String _fmtDate(DateTime d) {
    final mo = d.month.toString().padLeft(2, '0');
    final da = d.day.toString().padLeft(2, '0');
    final h = d.hour.toString().padLeft(2, '0');
    final mi = d.minute.toString().padLeft(2, '0');
    return '${d.year}-$mo-$da $h:$mi';
  }
}

class _Header extends StatelessWidget {
  final Job job;
  const _Header({required this.job});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _StatusBadge(status: job.status),
              const SizedBox(width: 8),
              Text(_humanDate(job.createdAt),
                  style: Theme.of(context).textTheme.bodySmall),
              if (job.completedAt != null) ...[
                const SizedBox(width: 6),
                Text('• completed ${_humanDate(job.completedAt!)}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ]),
            if (job.address.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.place,
                    size: 16, color: AppColors.muted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(job.address,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
              ]),
            ],
            if (job.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(job.description,
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
          ],
        ),
      ),
    );
  }

  String _humanDate(DateTime d) {
    final mo = d.month.toString().padLeft(2, '0');
    final da = d.day.toString().padLeft(2, '0');
    return '$da/$mo/${d.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final JobStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final c = status == JobStatus.completed
        ? Colors.green
        : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(status.label,
          style: TextStyle(
              color: c, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

class _TimerCard extends StatelessWidget {
  final Job job;
  final DateTime now;
  const _TimerCard({required this.job, required this.now});

  @override
  Widget build(BuildContext context) {
    final running = job.hasRunningTimer;
    final dur = job.totalTime(now);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('On the clock',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Center(
              child: Text(
                formatDuration(dur),
                style: const TextStyle(
                  fontSize: 40,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            Center(
              child: Text(
                '${formatHours(dur)} hours · ${formatGbp(job.labourCostAt(now))} labour',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 14),
            if (running)
              ElevatedButton.icon(
                onPressed: () =>
                    JobLogService.instance.stopTimer(job.id),
                icon: const Icon(Icons.stop_circle),
                label: const Text('Stop timer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: job.status == JobStatus.completed
                    ? null
                    : () => JobLogService.instance.startTimer(job.id),
                icon: const Icon(Icons.play_circle),
                label: Text(job.status == JobStatus.completed
                    ? 'Job completed'
                    : 'Start timer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimeEntriesCard extends StatelessWidget {
  final Job job;
  final DateTime now;
  const _TimeEntriesCard({required this.job, required this.now});
  @override
  Widget build(BuildContext context) {
    if (job.entries.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time entries',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            for (final e in job.entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  e.isRunning
                      ? Icons.fiber_manual_record
                      : Icons.history,
                  color: e.isRunning ? AppColors.accent : AppColors.muted,
                ),
                title: Text(_fmtRange(e, now)),
                subtitle: Text(
                  '${formatHours(e.durationAt(now))} hours${e.isRunning ? ' · running' : ''}',
                ),
                trailing: e.isRunning
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.muted),
                        onPressed: () => JobLogService.instance
                            .deleteEntry(job.id, e.id),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  String _fmtRange(TimeEntry e, DateTime now) {
    final s = _fmt(e.start);
    if (e.isRunning) return '$s → now';
    return '$s → ${_fmtTimeOnly(e.end!)}';
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  String _fmtTimeOnly(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _MaterialsCard extends StatefulWidget {
  final Job job;
  const _MaterialsCard({required this.job});
  @override
  State<_MaterialsCard> createState() => _MaterialsCardState();
}

class _MaterialsCardState extends State<_MaterialsCard> {
  Future<void> _addLine() async {
    final desc = TextEditingController();
    final qty = TextEditingController(text: '1');
    final price = TextEditingController();
    InventoryItem? linkedInventory;
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Add material / part'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The pick-from-inventory shortcut. Tap → bottom-sheet picker.
              // Selecting an item pre-fills description + unit price; the
              // user can still edit either before saving. On save, stock
              // gets decremented automatically.
              AnimatedBuilder(
                animation: InventoryService.instance,
                builder: (_, __) => Card(
                  margin: EdgeInsets.zero,
                  color: AppColors.primary.withValues(alpha: 0.06),
                  child: ListTile(
                    leading: Icon(
                      linkedInventory == null
                          ? Icons.inventory_2_outlined
                          : Icons.check_circle,
                      color: linkedInventory == null
                          ? AppColors.primary
                          : Colors.green,
                    ),
                    title: Text(linkedInventory == null
                        ? 'Pick from inventory'
                        : linkedInventory!.name),
                    subtitle: Text(linkedInventory == null
                        ? 'Auto-fills description + price, decrements stock on save.'
                        : 'In stock: ${linkedInventory!.currentQty} ${linkedInventory!.unit} · £${linkedInventory!.unitCostGbp.toStringAsFixed(2)} each'),
                    trailing: linkedInventory == null
                        ? const Icon(Icons.chevron_right)
                        : IconButton(
                            tooltip: 'Unlink',
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setSt(() => linkedInventory = null),
                          ),
                    onTap: () async {
                      final picked = await _pickInventory(ctx);
                      if (picked != null) {
                        setSt(() {
                          linkedInventory = picked;
                          desc.text = picked.name;
                          price.text =
                              picked.unitCostGbp.toStringAsFixed(2);
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: desc,
                autofocus: linkedInventory == null,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. 15 mm copper, 2 m'),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: qty,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'))
                    ],
                    decoration:
                        const InputDecoration(labelText: 'Quantity'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: price,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'))
                    ],
                    decoration: const InputDecoration(
                        labelText: 'Unit price (£)'),
                  ),
                ),
              ]),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Add')),
          ],
        ),
      ),
    );
    if (saved != true || desc.text.trim().isEmpty) return;
    final quantity = double.tryParse(qty.text.trim()) ?? 1;
    await JobLogService.instance.addMaterial(
      widget.job.id,
      MaterialLine(
        id: 'm-${DateTime.now().millisecondsSinceEpoch}',
        description: desc.text.trim(),
        quantity: quantity,
        unitPriceGbp: double.tryParse(price.text.trim()) ?? 0,
      ),
    );
    // Auto-deduct: only if the user actually picked from inventory. Manual
    // entries don't touch stock — we don't want to second-guess the user.
    if (linkedInventory != null) {
      await InventoryService.instance.adjust(
        id: linkedInventory!.id,
        delta: -quantity,
        reason: AdjustmentReason.used,
        jobId: widget.job.id,
        note: desc.text.trim(),
      );
    }
  }

  /// Bottom-sheet picker over every inventory item. Returns the picked item,
  /// or null if dismissed.
  Future<InventoryItem?> _pickInventory(BuildContext ctx) async {
    await InventoryService.instance.ensureLoaded();
    if (!ctx.mounted) return null;
    return showModalBottomSheet<InventoryItem?>(
      context: ctx,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => AnimatedBuilder(
        animation: InventoryService.instance,
        builder: (sheetCtx, _) {
          final items = InventoryService.instance.items;
          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                  'No inventory items yet. Add some in Van inventory first.'),
            );
          }
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (_, scrollCtrl) => ListView.builder(
              controller: scrollCtrl,
              itemCount: items.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(
                      'Pick a part — its name + cost will fill the form, and stock will go down by the quantity you save.',
                    ),
                  );
                }
                final item = items[i - 1];
                final low = item.isLowStock;
                return ListTile(
                  leading: Icon(
                    Icons.inventory_2,
                    color: low ? AppColors.accent : AppColors.primary,
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.currentQty} ${item.unit} in stock · £${item.unitCostGbp.toStringAsFixed(2)} each',
                    style: TextStyle(
                      color: low ? AppColors.accent : null,
                      fontWeight: low ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  onTap: () => Navigator.pop(sheetCtx, item),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Materials',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              TextButton.icon(
                onPressed: _addLine,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ]),
            if (job.materials.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                    'No parts logged yet. Tap Add to record what you used.'),
              )
            else
              ...job.materials.map((m) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(m.description),
                    subtitle: Text(
                      '${m.quantity} × ${formatGbp(m.unitPriceGbp)} = ${formatGbp(m.totalGbp)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.muted),
                      onPressed: () => JobLogService.instance
                          .deleteMaterial(job.id, m.id),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

/// Bottom-sheet result type for the photo source picker — either "take a
/// photo" / "pick from gallery", optionally routed through the annotation
/// editor first.
class _PhotoAction {
  final ImageSource source;
  final bool annotate;
  const _PhotoAction(this.source, {required this.annotate});
}

class _PhotosCard extends StatefulWidget {
  final Job job;
  const _PhotosCard({required this.job});
  @override
  State<_PhotosCard> createState() => _PhotosCardState();
}

class _PhotosCardState extends State<_PhotosCard> {
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pick(ImageSource source, {bool annotate = false}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        imageQuality: 85,
      );
      if (picked == null) return;
      String sourcePath = picked.path;
      if (annotate) {
        if (!mounted) return;
        final result = await Navigator.push<PhotoAnnotateResult?>(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoAnnotateScreen(sourcePath: picked.path),
          ),
        );
        // Cancelled annotation ⇒ abandon (don't add the un-annotated
        // photo; the user explicitly chose the annotate path).
        if (result == null) return;
        sourcePath = result.path;
      }
      await JobLogService.instance.addPhoto(
        jobId: widget.job.id,
        sourcePath: sourcePath,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showSourceSheet() async {
    final picked = await showModalBottomSheet<_PhotoAction?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(
                context,
                const _PhotoAction(ImageSource.camera, annotate: false),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('From gallery'),
              onTap: () => Navigator.pop(
                context,
                const _PhotoAction(ImageSource.gallery, annotate: false),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.draw),
              title: const Text('Annotate before adding'),
              subtitle: const Text(
                  'Pick a photo, then mark it up — arrows on a leak, circle the install point.'),
              onTap: () => Navigator.pop(
                context,
                const _PhotoAction(ImageSource.gallery, annotate: true),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) await _pick(picked.source, annotate: picked.annotate);
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Photos',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 6),
              if (job.photos.isNotEmpty)
                Text('(${job.photos.length})',
                    style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              TextButton.icon(
                onPressed: _busy ? null : _showSourceSheet,
                icon: const Icon(Icons.add_a_photo, size: 18),
                label: const Text('Add'),
              ),
            ]),
            if (job.photos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No photos yet. Tap Add to capture before/after shots, fault evidence, parts in situ, or a customer signature on glass.',
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: job.photos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (_, i) => _PhotoTile(
                  jobId: job.id,
                  photo: job.photos[i],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatefulWidget {
  final String jobId;
  final JobPhoto photo;
  const _PhotoTile({required this.jobId, required this.photo});

  @override
  State<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<_PhotoTile> {
  String? _path;

  @override
  void initState() {
    super.initState();
    JobLogService.instance.photoPath(widget.photo).then((p) {
      if (mounted) setState(() => _path = p);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = _path;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: p == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _PhotoViewer(
                    jobId: widget.jobId,
                    photo: widget.photo,
                    path: p,
                  ),
                ),
              ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: p == null
            ? Container(color: Colors.black12)
            : Image.file(
                File(p),
                fit: BoxFit.cover,
                cacheWidth: 300,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.black12),
              ),
      ),
    );
  }
}

class _PhotoViewer extends StatefulWidget {
  final String jobId;
  final JobPhoto photo;
  final String path;
  const _PhotoViewer({
    required this.jobId,
    required this.photo,
    required this.path,
  });

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final TextEditingController _caption;

  @override
  void initState() {
    super.initState();
    _caption = TextEditingController(text: widget.photo.caption);
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    final nav = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this photo?'),
        content: const Text(
            'This removes it from the job and from device storage.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await JobLogService.instance
        .removePhoto(widget.jobId, widget.photo.id);
    if (!mounted) return;
    nav.pop();
  }

  Future<void> _saveCaption() async {
    final messenger = ScaffoldMessenger.of(context);
    await JobLogService.instance.updatePhotoCaption(
      widget.jobId,
      widget.photo.id,
      _caption.text,
    );
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Caption saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Delete photo',
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Center(
                child: Image.file(
                  File(widget.path),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caption,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Caption (optional)',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Save caption',
                  icon: const Icon(Icons.save, color: Colors.white),
                  onPressed: _saveCaption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatefulWidget {
  final TextEditingController controller;
  final String jobId;
  const _NotesCard({required this.controller, required this.jobId});
  @override
  State<_NotesCard> createState() => _NotesCardState();
}

class _NotesCardState extends State<_NotesCard> {
  bool _dirty = false;

  Future<void> _save() async {
    await JobLogService.instance
        .updateNotes(widget.jobId, widget.controller.text);
    if (!mounted) return;
    setState(() => _dirty = false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Notes',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              if (_dirty)
                TextButton.icon(
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save'),
                  onPressed: _save,
                ),
            ]),
            TextField(
              controller: widget.controller,
              minLines: 3,
              maxLines: 8,
              onChanged: (_) => setState(() => _dirty = true),
              onEditingComplete: _save,
              decoration: const InputDecoration(
                hintText:
                    'What did you find? What did you do? Customer requests for next time…',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final Job job;
  final DateTime now;
  const _TotalsCard({required this.job, required this.now});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Totals',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            _row('Labour', formatGbp(job.labourCostAt(now)),
                '${formatHours(job.totalTime(now))} h × ${formatGbp(job.hourlyRateGbp)}/h'),
            _row('Materials', formatGbp(job.materialsCost),
                '${job.materials.length} line${job.materials.length == 1 ? '' : 's'}'),
            const Divider(),
            Row(children: [
              const Expanded(
                  child: Text('TOTAL',
                      style:
                          TextStyle(fontWeight: FontWeight.w800))),
              Text(
                formatGbp(job.totalCostAt(now)),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(detail,
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _LinkedExpensesCard extends StatelessWidget {
  final String jobId;
  const _LinkedExpensesCard({required this.jobId});

  IconData _iconFor(Expense e) {
    if (e.kind == ExpenseKind.mileage) return Icons.directions_car;
    switch (e.category) {
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

  Future<void> _addLinked(BuildContext context, ExpenseKind kind) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditExpenseScreen(kind: kind, prefillJobId: jobId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ExpenseService.instance,
      builder: (context, _) {
        final items = ExpenseService.instance.forJob(jobId);
        final total = items.fold<double>(
            0, (sum, e) => sum + e.computedAmountGbp);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Job-linked expenses',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  PopupMenuButton<ExpenseKind>(
                    tooltip: 'Add',
                    icon: const Icon(Icons.add),
                    onSelected: (k) => _addLinked(context, k),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: ExpenseKind.expense,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.receipt_long),
                          title: Text('Expense'),
                        ),
                      ),
                      PopupMenuItem(
                        value: ExpenseKind.mileage,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.directions_car),
                          title: Text('Mileage'),
                        ),
                      ),
                    ],
                  ),
                ]),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                        'Track parts you bought specifically for this customer or miles driven for the call-out. These do not appear on the customer PDF.'),
                  )
                else ...[
                  ...items.map((e) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(_iconFor(e),
                            color: e.kind == ExpenseKind.mileage
                                ? AppColors.accent
                                : AppColors.primary),
                        title: Text(e.description.isEmpty
                            ? e.category
                            : e.description),
                        subtitle: Text(e.kind == ExpenseKind.mileage
                            ? '${e.miles == e.miles.roundToDouble() ? e.miles.toStringAsFixed(0) : e.miles.toStringAsFixed(1)} mi @ £${e.mileageRateGbpPerMile.toStringAsFixed(2)}'
                            : e.category),
                        trailing: Text(
                          '£${e.computedAmountGbp.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditExpenseScreen(
                                kind: e.kind, existing: e),
                          ),
                        ),
                      )),
                  const Divider(),
                  Row(children: [
                    const Text('Total cost to you',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('£${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ]),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VoiceNotesCard extends StatelessWidget {
  final Job job;
  const _VoiceNotesCard({required this.job});

  Future<void> _record(BuildContext context) async {
    final result = await showModalBottomSheet<VoiceRecordingResult?>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const VoiceRecorderSheet(),
    );
    if (result == null) return;
    await JobLogService.instance.addVoiceNote(
      jobId: job.id,
      sourcePath: result.path,
      duration: result.duration,
      caption: result.caption,
    );
  }

  String _totalDurationLabel() {
    if (job.voiceNotes.isEmpty) return '';
    final total = job.voiceNotes.fold<Duration>(
        Duration.zero, (a, n) => a + n.duration);
    final m = total.inMinutes;
    final s = total.inSeconds % 60;
    if (m == 0) return '${s}s total';
    return '${m}m ${s.toString().padLeft(2, '0')}s total';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('Voice notes',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 6),
              if (job.voiceNotes.isNotEmpty)
                Text(
                  '· ${_totalDurationLabel()}',
                  style: const TextStyle(
                      color: AppColors.muted, fontSize: 12),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _record(context),
                icon: const Icon(Icons.mic),
                label: const Text('Record'),
              ),
            ]),
            if (job.voiceNotes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                    'No voice notes yet. Tap Record to capture observations hands-free — useful when your hands are wet or full.'),
              )
            else
              ...job.voiceNotes.map(
                (n) => VoiceNotePlayer(
                  key: ValueKey(n.id),
                  note: n,
                  onDelete: () =>
                      JobLogService.instance.removeVoiceNote(job.id, n.id),
                  onCaptionChanged: (c) =>
                      JobLogService.instance.updateVoiceNoteCaption(
                          job.id, n.id, c),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
