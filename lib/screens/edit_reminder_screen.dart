import 'package:flutter/material.dart';

import '../data/customer_data.dart';
import '../data/reminder_data.dart';
import '../services/customer_service.dart';
import '../services/reminder_service.dart';
import '../theme.dart';
import 'customers_screen.dart';

class EditReminderScreen extends StatefulWidget {
  final ServiceReminder? existing;

  /// Optional pre-fill — used when the user taps "Schedule follow-up" from a
  /// completed job and we want the customer + description ready to go.
  final String? prefillCustomerId;
  final String? prefillCustomerName;
  final String? prefillAddress;
  final String? prefillDescription;
  final DateTime? prefillDueDate;
  final String? sourceJobId;
  final String? templateId;

  const EditReminderScreen({
    super.key,
    this.existing,
    this.prefillCustomerId,
    this.prefillCustomerName,
    this.prefillAddress,
    this.prefillDescription,
    this.prefillDueDate,
    this.sourceJobId,
    this.templateId,
  });

  @override
  State<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  late final TextEditingController _customer;
  late final TextEditingController _address;
  late final TextEditingController _description;
  late DateTime _due;
  String _customerId = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _customer = TextEditingController(
        text: e?.customerName ?? widget.prefillCustomerName ?? '');
    _address = TextEditingController(
        text: e?.address ?? widget.prefillAddress ?? '');
    _description = TextEditingController(
        text: e?.description ?? widget.prefillDescription ?? '');
    _customerId =
        e?.customerId ?? widget.prefillCustomerId ?? '';
    _due = e?.dueDate ??
        widget.prefillDueDate ??
        DateTime.now().add(const Duration(days: 365));
    CustomerService.instance.ensureLoaded();
  }

  @override
  void dispose() {
    _customer.dispose();
    _address.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final picked = await Navigator.push<Customer?>(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomersScreen(pickMode: true),
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _customerId = picked.id;
        _customer.text = picked.name;
        if (picked.address.isNotEmpty) _address.text = picked.address;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _due = picked);
  }

  void _quickSet(int months) {
    setState(() {
      final now = DateTime.now();
      _due = DateTime(now.year, now.month + months, now.day);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_customer.text.trim().isEmpty) {
      _toast('Add a customer name.');
      return;
    }
    if (_description.text.trim().isEmpty) {
      _toast('Add a short description, e.g. Annual boiler service.');
      return;
    }
    setState(() => _saving = true);
    final svc = ReminderService.instance;
    if (widget.existing == null) {
      await svc.add(ServiceReminder.create(
        customerId: _customerId,
        customerName: _customer.text,
        address: _address.text,
        description: _description.text,
        dueDate: _due,
        sourceJobId: widget.sourceJobId,
        templateId: widget.templateId,
      ));
    } else {
      await svc.update(widget.existing!.copyWith(
        customerId: _customerId,
        customerName: _customer.text.trim(),
        address: _address.text.trim(),
        description: _description.text.trim(),
        dueDate: _due,
      ));
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final r = widget.existing;
    if (r == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this reminder?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ReminderService.instance.delete(r.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null
            ? 'New service reminder'
            : 'Edit reminder'),
        actions: [
          if (widget.existing != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          TextButton(
              onPressed: _saving ? null : _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          OutlinedButton.icon(
            onPressed: _pickCustomer,
            icon: const Icon(Icons.person_search),
            label: Text(_customerId.isEmpty
                ? 'Pick from customers'
                : 'Linked to a customer record'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customer,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Customer name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _address,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Address (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _description,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'What to do',
              hintText: 'e.g. Annual boiler service',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Due date', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Card(
            color: AppColors.primary.withValues(alpha: 0.06),
            child: ListTile(
              leading: const Icon(Icons.event, color: AppColors.primary),
              title: Text(_formatDate(_due)),
              subtitle: Text('In ${_relativeFromNow(_due)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _quickChip('6 months', () => _quickSet(6)),
              _quickChip('12 months', () => _quickSet(12)),
              _quickChip('18 months', () => _quickSet(18)),
              _quickChip('2 years', () => _quickSet(24)),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check),
            label: Text(widget.existing == null
                ? 'Create reminder'
                : 'Save changes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Reminders fire at 9am on the due date as a phone notification, and surface in the Reminders screen. You can snooze or mark done at any time.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap) =>
      ActionChip(label: Text(label), onPressed: onTap);
}

String _formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String _relativeFromNow(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(d.year, d.month, d.day);
  final days = target.difference(today).inDays;
  if (days == 0) return 'today';
  if (days < 0) return '${-days} day${days == -1 ? '' : 's'} ago';
  if (days < 60) return '$days days';
  final months = (days / 30).round();
  if (months < 24) return '$months months';
  final years = (months / 12).round();
  return '$years years';
}
