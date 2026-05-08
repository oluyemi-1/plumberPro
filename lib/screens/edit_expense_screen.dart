import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/expense_data.dart';
import '../data/job_log_data.dart';
import '../services/expense_service.dart';
import '../services/job_log_service.dart';
import '../theme.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseKind kind;
  final Expense? existing;

  /// Pre-link the new expense / mileage entry to the given job. The user can
  /// still unlink before saving.
  final String? prefillJobId;

  /// Optional pre-fills used when arriving from the receipt-OCR flow. Each
  /// is fed into its respective controller in `initState` *only* when
  /// creating a new entry (not editing). The user reviews everything before
  /// saving — these are hints, not commitments.
  final DateTime? prefillDate;
  final double? prefillAmount;
  final String? prefillDescription;
  final String? prefillCategory;

  const EditExpenseScreen({
    super.key,
    required this.kind,
    this.existing,
    this.prefillJobId,
    this.prefillDate,
    this.prefillAmount,
    this.prefillDescription,
    this.prefillCategory,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late final TextEditingController _description;
  late final TextEditingController _amount;
  late final TextEditingController _miles;
  late final TextEditingController _rate;
  late DateTime _date;
  late String _category;
  String? _linkedJobId;
  bool _saving = false;

  bool get _isMileage => widget.kind == ExpenseKind.mileage;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _description = TextEditingController(
      text: e?.description ?? widget.prefillDescription ?? '',
    );
    _amount = TextEditingController(
      text: e == null || e.kind != ExpenseKind.expense
          ? (widget.prefillAmount?.toStringAsFixed(2) ?? '')
          : e.amountGbp.toStringAsFixed(2),
    );
    _miles = TextEditingController(
      text: e == null || e.kind != ExpenseKind.mileage
          ? ''
          : _trimZero(e.miles),
    );
    _rate = TextEditingController(
      text: (e?.mileageRateGbpPerMile ?? ExpenseService.instance.mileageRate)
          .toStringAsFixed(2),
    );
    _date = e?.date ?? widget.prefillDate ?? DateTime.now();
    _category = e?.category ??
        (_isMileage
            ? 'Mileage'
            : (widget.prefillCategory != null &&
                    expenseCategories.contains(widget.prefillCategory))
                ? widget.prefillCategory!
                : expenseCategories.first);
    _linkedJobId = e?.jobId ?? widget.prefillJobId;
    JobLogService.instance.ensureLoaded();
  }

  String _trimZero(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _miles.dispose();
    _rate.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickJob() async {
    await JobLogService.instance.ensureLoaded();
    if (!mounted) return;
    final jobs = JobLogService.instance.jobs;
    final picked = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (_) => _JobPickerSheet(jobs: jobs, selectedId: _linkedJobId),
    );
    // Bottom sheet returns null if dismissed; the special sentinel '' means
    // the user picked "No link".
    if (picked != null) {
      setState(() => _linkedJobId = picked.isEmpty ? null : picked);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final svc = ExpenseService.instance;

    if (_isMileage) {
      final miles = double.tryParse(_miles.text.trim()) ?? 0;
      if (miles <= 0) {
        _toast('Enter the miles driven.');
        return;
      }
      final rate = double.tryParse(_rate.text.trim()) ?? svc.mileageRate;
      setState(() => _saving = true);
      // Also update the user's default rate so next trip remembers.
      if ((rate - svc.mileageRate).abs() > 0.0001) {
        await svc.setMileageRate(rate);
      }
      final entry = Expense(
        id: widget.existing?.id ?? generateExpenseId(),
        kind: ExpenseKind.mileage,
        date: _date,
        category: 'Mileage',
        description: _description.text.trim(),
        amountGbp: 0,
        miles: miles,
        mileageRateGbpPerMile: rate,
        jobId: _linkedJobId,
      );
      if (widget.existing == null) {
        await svc.add(entry);
      } else {
        await svc.update(entry);
      }
    } else {
      final amount = double.tryParse(_amount.text.trim()) ?? 0;
      if (amount <= 0) {
        _toast('Enter the amount.');
        return;
      }
      setState(() => _saving = true);
      final entry = Expense(
        id: widget.existing?.id ?? generateExpenseId(),
        kind: ExpenseKind.expense,
        date: _date,
        category: _category,
        description: _description.text.trim(),
        amountGbp: amount,
        miles: 0,
        mileageRateGbpPerMile: 0,
        jobId: _linkedJobId,
      );
      if (widget.existing == null) {
        await svc.add(entry);
      } else {
        await svc.update(entry);
      }
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _delete() async {
    final e = widget.existing;
    if (e == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete this ${_isMileage ? 'mileage entry' : 'expense'}?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ExpenseService.instance.delete(e.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existing == null
        ? (_isMileage ? 'New mileage' : 'New expense')
        : (_isMileage ? 'Edit mileage' : 'Edit expense');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (widget.existing != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // Date row
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            subtitle: Text(_formatDate(_date)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDate,
          ),
          const Divider(),
          if (_isMileage) ..._buildMileageFields() else ..._buildExpenseFields(),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: JobLogService.instance,
            builder: (context, _) {
              final job = _linkedJobId == null
                  ? null
                  : JobLogService.instance.findById(_linkedJobId!);
              return Card(
                color: AppColors.primary.withValues(alpha: 0.06),
                child: ListTile(
                  leading: const Icon(Icons.work_outline,
                      color: AppColors.primary),
                  title: Text(job == null
                      ? 'Link to a job (optional)'
                      : (job.customer.isEmpty
                          ? 'Untitled job'
                          : job.customer)),
                  subtitle: Text(job == null
                      ? 'Track parts you bought specifically for a customer.'
                      : (job.description.isEmpty
                          ? 'Linked to this job'
                          : job.description)),
                  trailing: job == null
                      ? const Icon(Icons.add)
                      : IconButton(
                          tooltip: 'Unlink',
                          icon: const Icon(Icons.link_off),
                          onPressed: () => setState(() => _linkedJobId = null),
                        ),
                  onTap: _pickJob,
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check),
            label: Text(widget.existing == null ? 'Add' : 'Save changes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpenseFields() => [
        DropdownButtonFormField<String>(
          value: _category,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final c in expenseCategories)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) => setState(() => _category = v ?? _category),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _description,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'e.g. Plumb Center — copper fittings',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          decoration: const InputDecoration(
            labelText: 'Amount (£)',
            border: OutlineInputBorder(),
          ),
        ),
      ];

  List<Widget> _buildMileageFields() => [
        TextField(
          controller: _description,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'e.g. To customer in Surbiton and back',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _miles,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                labelText: 'Miles',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _rate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                labelText: 'Rate (£ / mile)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Builder(builder: (_) {
          final miles = double.tryParse(_miles.text.trim()) ?? 0;
          final rate = double.tryParse(_rate.text.trim()) ?? 0;
          final cost = miles * rate;
          return Card(
            color: AppColors.accent.withValues(alpha: 0.08),
            child: ListTile(
              leading:
                  const Icon(Icons.attach_money, color: AppColors.accent),
              title: const Text('Computed cost'),
              subtitle: Text(
                  '${miles.toStringAsFixed(miles == miles.roundToDouble() ? 0 : 1)} mi × £${rate.toStringAsFixed(2)} = £${cost.toStringAsFixed(2)}'),
            ),
          );
        }),
        const SizedBox(height: 6),
        const Text(
          'Tip: HMRC simplified expenses for sole traders allow 45p / mile for the first 10,000 business miles each tax year, then 25p / mile after that.',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ];
}

String _formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class _JobPickerSheet extends StatelessWidget {
  final List<Job> jobs;
  final String? selectedId;
  const _JobPickerSheet({required this.jobs, required this.selectedId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text('Link to a job',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.link_off, color: AppColors.muted),
            title: const Text('No link'),
            selected: selectedId == null,
            onTap: () => Navigator.pop(context, ''),
          ),
          const Divider(height: 1),
          if (jobs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No jobs yet — create one in the job log first.'),
            )
          else
            for (final j in jobs)
              ListTile(
                leading: Icon(
                  j.status == JobStatus.completed
                      ? Icons.check_circle
                      : Icons.work,
                  color: j.status == JobStatus.completed
                      ? Colors.green
                      : AppColors.primary,
                ),
                title: Text(j.customer.isEmpty ? 'Untitled job' : j.customer),
                subtitle: Text(j.description.isEmpty
                    ? _formatDate(j.createdAt)
                    : j.description,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                selected: j.id == selectedId,
                onTap: () => Navigator.pop(context, j.id),
              ),
        ],
      ),
    );
  }
}
