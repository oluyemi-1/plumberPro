import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/customer_data.dart';
import '../data/job_log_data.dart';
import '../data/job_template_data.dart';
import '../services/customer_service.dart';
import '../services/job_log_service.dart';
import '../theme.dart';
import 'customers_screen.dart';
import 'templates_screen.dart' show iconForCode;

class NewJobScreen extends StatefulWidget {
  /// When supplied, the customer fields are pre-filled and the customer link
  /// is established automatically.
  final Customer? prefillCustomer;

  /// When supplied, the description, hourly rate, notes and suggested
  /// materials are pre-filled from the template.
  final JobTemplate? prefillTemplate;

  const NewJobScreen({
    super.key,
    this.prefillCustomer,
    this.prefillTemplate,
  });

  @override
  State<NewJobScreen> createState() => _NewJobScreenState();
}

class _NewJobScreenState extends State<NewJobScreen> {
  final _customer = TextEditingController();
  final _address = TextEditingController();
  final _description = TextEditingController();
  late final TextEditingController _rate;
  late final TextEditingController _notes;

  Customer? _linkedCustomer;
  bool _saveAsCustomer = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.prefillTemplate;
    _rate = TextEditingController(
      text: (t?.defaultHourlyRateGbp ??
              JobLogService.instance.defaultHourlyRate)
          .toStringAsFixed(0),
    );
    if (t != null) {
      _description.text = t.description;
    }
    _notes = TextEditingController(text: t?.defaultNotes ?? '');
    if (widget.prefillCustomer != null) {
      _linkedCustomer = widget.prefillCustomer;
      _customer.text = widget.prefillCustomer!.name;
      _address.text = widget.prefillCustomer!.address;
      _saveAsCustomer = false; // already saved
    }
    CustomerService.instance.ensureLoaded();
  }

  @override
  void dispose() {
    _customer.dispose();
    _address.dispose();
    _description.dispose();
    _rate.dispose();
    _notes.dispose();
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
        _linkedCustomer = picked;
        _customer.text = picked.name;
        _address.text = picked.address;
        _saveAsCustomer = false;
      });
    }
  }

  void _clearLink() {
    setState(() {
      _linkedCustomer = null;
      _saveAsCustomer = true;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final rate = double.tryParse(_rate.text.trim()) ??
        JobLogService.instance.defaultHourlyRate;
    await JobLogService.instance.setDefaultHourlyRate(rate);

    // Determine the customer link.
    Customer? linked = _linkedCustomer;
    if (linked == null && _saveAsCustomer && _customer.text.trim().isNotEmpty) {
      linked = await CustomerService.instance.create(
        name: _customer.text,
        address: _address.text,
      );
    }

    final job = await JobLogService.instance.createJob(
      customer: _customer.text,
      address: _address.text,
      description: _description.text,
      hourlyRateGbp: rate,
      customerId: linked?.id ?? '',
    );

    // Seed notes and suggested materials from the template.
    if (_notes.text.trim().isNotEmpty) {
      await JobLogService.instance.updateNotes(job.id, _notes.text);
    }
    final tpl = widget.prefillTemplate;
    if (tpl != null) {
      for (var i = 0; i < tpl.suggestedMaterials.length; i++) {
        final m = tpl.suggestedMaterials[i];
        await JobLogService.instance.addMaterial(
          job.id,
          MaterialLine(
            id: 'm-${DateTime.now().millisecondsSinceEpoch}-$i',
            description: m.description,
            quantity: m.quantity,
            unitPriceGbp: m.unitPriceGbp,
          ),
        );
      }
    }

    if (!mounted) return;
    Navigator.pop<Job>(context, job);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New job'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          if (widget.prefillTemplate != null) ...[
            Card(
              color: AppColors.accent.withValues(alpha: 0.10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      iconForCode(widget.prefillTemplate!.iconCode),
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From template',
                            style: Theme.of(context).textTheme.bodySmall),
                        Text(widget.prefillTemplate!.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800)),
                        if (widget
                            .prefillTemplate!.suggestedMaterials.isNotEmpty)
                          Text(
                            '${widget.prefillTemplate!.suggestedMaterials.length} suggested part${widget.prefillTemplate!.suggestedMaterials.length == 1 ? '' : 's'} will be added automatically',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_linkedCustomer != null)
            Card(
              color: AppColors.primary.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.18),
                    child: Text(
                      _linkedCustomer!.firstLetter,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_linkedCustomer!.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800)),
                        Text('Linked customer record',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Unlink',
                    icon: const Icon(Icons.link_off),
                    onPressed: _clearLink,
                  ),
                ]),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: _pickCustomer,
              icon: const Icon(Icons.person_search),
              label: const Text('Pick from existing customers'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _customer,
            autofocus: widget.prefillCustomer == null &&
                _linkedCustomer == null,
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
          if (_linkedCustomer == null) ...[
            const SizedBox(height: 4),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _saveAsCustomer,
              onChanged: (v) =>
                  setState(() => _saveAsCustomer = v ?? true),
              title: const Text('Save as a customer'),
              subtitle: const Text(
                  'Quickly pick the same customer next time'),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            ),
          ],
          const SizedBox(height: 6),
          TextField(
            controller: _description,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Job description',
              hintText: 'e.g. Leaking radiator, replace lockshield',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _rate,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: const InputDecoration(
              labelText: 'Hourly rate (£)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText:
                  'Pressures, readings, conditions on arrival, customer requests…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check),
            label: const Text('Create job'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
