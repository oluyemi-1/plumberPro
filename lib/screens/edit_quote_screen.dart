import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/customer_data.dart';
import '../data/job_template_data.dart';
import '../data/quote_data.dart';
import '../services/customer_service.dart';
import '../services/job_log_service.dart';
import '../services/job_template_service.dart';
import '../services/quote_pdf_export.dart';
import '../services/quote_service.dart';
import '../theme.dart';
import 'customers_screen.dart';
import 'job_detail_screen.dart';
import 'signature_capture_screen.dart';

/// Edits an existing quote OR creates a new one. Mirrors the Job + Template
/// edit flow so plumbers don't have to learn a third UI.
class EditQuoteScreen extends StatefulWidget {
  final Quote? existing;

  /// Optional pre-fills used when launching from a customer or template.
  final Customer? prefillCustomer;
  final JobTemplate? prefillTemplate;

  const EditQuoteScreen({
    super.key,
    this.existing,
    this.prefillCustomer,
    this.prefillTemplate,
  });

  @override
  State<EditQuoteScreen> createState() => _EditQuoteScreenState();
}

class _EditQuoteScreenState extends State<EditQuoteScreen> {
  late final TextEditingController _customer;
  late final TextEditingController _address;
  late final TextEditingController _description;
  late final TextEditingController _hours;
  late final TextEditingController _rate;
  late final TextEditingController _validFor;
  late final TextEditingController _notes;

  String _customerId = '';
  late List<QuoteLineItem> _lines;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final q = widget.existing;
    final tpl = widget.prefillTemplate;
    final cust = widget.prefillCustomer;

    _customer = TextEditingController(
      text: q?.customer ?? cust?.name ?? '',
    );
    _address = TextEditingController(
      text: q?.address ?? cust?.address ?? '',
    );
    _description = TextEditingController(
      text: q?.description ?? tpl?.description ?? '',
    );
    _hours = TextEditingController(
      text: q == null ? '' : _trimZero(q.estimatedHours),
    );
    _rate = TextEditingController(
      text: (q?.hourlyRateGbp ??
              tpl?.defaultHourlyRateGbp ??
              JobLogService.instance.defaultHourlyRate)
          .toStringAsFixed(0),
    );
    _validFor = TextEditingController(
      text: (q?.validForDays ?? 30).toString(),
    );
    _notes = TextEditingController(
      text: q?.notes ?? tpl?.defaultNotes ?? '',
    );
    _customerId = q?.customerId ?? cust?.id ?? '';

    _lines = [
      ...?q?.lines,
      if (q == null && tpl != null)
        for (var i = 0; i < tpl.suggestedMaterials.length; i++)
          QuoteLineItem(
            id: _newLineId(i),
            description: tpl.suggestedMaterials[i].description,
            quantity: tpl.suggestedMaterials[i].quantity,
            unitPriceGbp: tpl.suggestedMaterials[i].unitPriceGbp,
          ),
    ];

    CustomerService.instance.ensureLoaded();
    JobTemplateService.instance.ensureLoaded();
  }

  String _trimZero(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  String _newLineId(int salt) =>
      'ql-${DateTime.now().millisecondsSinceEpoch}-${math.Random().nextInt(1 << 16)}-$salt';

  @override
  void dispose() {
    _customer.dispose();
    _address.dispose();
    _description.dispose();
    _hours.dispose();
    _rate.dispose();
    _validFor.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final picked = await Navigator.push<Customer?>(
      context,
      MaterialPageRoute(builder: (_) => const CustomersScreen(pickMode: true)),
    );
    if (picked != null && mounted) {
      setState(() {
        _customerId = picked.id;
        _customer.text = picked.name;
        if (picked.address.isNotEmpty) _address.text = picked.address;
      });
    }
  }

  Future<void> _pickTemplate() async {
    await JobTemplateService.instance.ensureLoaded();
    if (!mounted) return;
    final templates = JobTemplateService.instance.templates;
    if (templates.isEmpty) {
      _toast('No templates yet — create one in Job templates first.');
      return;
    }
    final picked = await showModalBottomSheet<JobTemplate?>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              dense: true,
              title: Text('Pick a template'),
              subtitle: Text(
                  'Pre-fills description, hourly rate, suggested parts and notes.'),
            ),
            const Divider(height: 1),
            for (final t in templates)
              ListTile(
                leading: const Icon(Icons.layers),
                title: Text(t.name),
                subtitle: t.description.isEmpty
                    ? null
                    : Text(t.description,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.pop(context, t),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (_description.text.trim().isEmpty) {
        _description.text = picked.description;
      }
      if (picked.defaultHourlyRateGbp != null) {
        _rate.text = picked.defaultHourlyRateGbp!.toStringAsFixed(0);
      }
      if (_notes.text.trim().isEmpty) {
        _notes.text = picked.defaultNotes;
      }
      for (var i = 0; i < picked.suggestedMaterials.length; i++) {
        final m = picked.suggestedMaterials[i];
        _lines.add(QuoteLineItem(
          id: _newLineId(i),
          description: m.description,
          quantity: m.quantity,
          unitPriceGbp: m.unitPriceGbp,
        ));
      }
    });
  }

  Future<void> _addLine() async {
    final desc = TextEditingController();
    final qty = TextEditingController(text: '1');
    final price = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add line'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: desc,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g. 24 kW combi boiler, supply only',
              ),
            ),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: qty,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                  ],
                  decoration: const InputDecoration(labelText: 'Qty'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                  ],
                  decoration:
                      const InputDecoration(labelText: 'Unit price (£)'),
                ),
              ),
            ]),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add')),
        ],
      ),
    );
    if (ok == true && desc.text.trim().isNotEmpty) {
      setState(() {
        _lines.add(QuoteLineItem(
          id: _newLineId(_lines.length),
          description: desc.text.trim(),
          quantity: double.tryParse(qty.text.trim()) ?? 1,
          unitPriceGbp: double.tryParse(price.text.trim()) ?? 0,
        ));
      });
    }
  }

  void _removeLine(int index) =>
      setState(() => _lines.removeAt(index));

  Future<void> _save() async {
    if (_saving) return;
    if (_customer.text.trim().isEmpty) {
      _toast('Add a customer name.');
      return;
    }
    setState(() => _saving = true);
    final hours = double.tryParse(_hours.text.trim()) ?? 0;
    final rate = double.tryParse(_rate.text.trim()) ??
        JobLogService.instance.defaultHourlyRate;
    final validFor = int.tryParse(_validFor.text.trim());

    final svc = QuoteService.instance;
    Quote saved;
    if (widget.existing == null) {
      saved = await svc.create(Quote.create(
        customer: _customer.text,
        customerId: _customerId,
        address: _address.text,
        description: _description.text,
        estimatedHours: hours,
        hourlyRateGbp: rate,
        lines: _lines,
        notes: _notes.text,
        validForDays: validFor,
      ));
    } else {
      saved = widget.existing!.copyWith(
        customer: _customer.text.trim(),
        customerId: _customerId,
        address: _address.text.trim(),
        description: _description.text.trim(),
        estimatedHours: hours,
        hourlyRateGbp: rate,
        lines: _lines,
        notes: _notes.text,
        validForDays: validFor,
        clearValidFor: validFor == null,
      );
      await svc.update(saved);
    }
    if (!mounted) return;
    Navigator.pop(context, saved);
  }

  Future<void> _delete() async {
    final q = widget.existing;
    if (q == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this quote?'),
        content: Text(q.convertedJobId != null
            ? 'This quote was already converted to a job. Deleting it will not delete the job.'
            : 'This cannot be undone.'),
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
    await QuoteService.instance.delete(q.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _share() async {
    final q = widget.existing;
    if (q == null) {
      _toast('Save the quote first.');
      return;
    }
    final svc = JobLogService.instance;
    final nameCtrl = TextEditingController(text: svc.businessName);
    final contactCtrl = TextEditingController(text: svc.businessContact);
    bool includeVat = false;
    SignatureCapture? signature;
    final messenger = ScaffoldMessenger.of(context);

    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Share quote PDF'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Your business name',
                      hintText: 'e.g. A. Smith Plumbing & Heating',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: contactCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Contact line',
                      hintText: '07xxx · email · Gas Safe 1234567',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Include VAT at 20%'),
                    subtitle:
                        const Text('Only if you are VAT-registered'),
                    value: includeVat,
                    onChanged: (v) => setSt(() => includeVat = v),
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    color: AppColors.primary.withValues(alpha: 0.06),
                    child: ListTile(
                      leading: Icon(
                        signature == null ? Icons.draw : Icons.check_circle,
                        color: signature == null
                            ? AppColors.primary
                            : Colors.green,
                      ),
                      title: Text(signature == null
                          ? 'Capture customer acceptance'
                          : 'Accepted by ${signature!.name}'),
                      subtitle: Text(signature == null
                          ? 'Customer signs to accept the quoted price.'
                          : 'Tap to re-sign or use the cross to clear.'),
                      trailing: signature == null
                          ? const Icon(Icons.chevron_right)
                          : IconButton(
                              tooltip: 'Clear signature',
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setSt(() => signature = null),
                            ),
                      onTap: () async {
                        final result =
                            await Navigator.push<SignatureCapture?>(
                          ctx,
                          MaterialPageRoute(
                            builder: (_) => SignatureCaptureScreen(
                              prefillName: q.customer,
                            ),
                          ),
                        );
                        if (result != null) {
                          setSt(() => signature = result);
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
              label: const Text('Share PDF'),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );
    if (go != true) return;

    await svc.setBusinessProfile(
      name: nameCtrl.text,
      contact: contactCtrl.text,
    );

    final options = QuotePdfOptions(
      businessName: nameCtrl.text.trim(),
      businessContact: contactCtrl.text.trim(),
      includeVat: includeVat,
      vatRate: svc.vatRate,
      signatureBytes: signature?.bytes,
      signerName: signature?.name,
      signedAt: signature?.signedAt,
    );

    try {
      await QuotePdfExport.exportAndShare(quote: q, options: options);
      if (signature != null) {
        // Captured signature ⇒ acceptance.
        await QuoteService.instance.markAccepted(q.id);
      } else if (q.status == QuoteStatus.draft) {
        await QuoteService.instance.markSent(q.id);
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not generate PDF: $e')),
      );
    }
  }

  Future<void> _convertToJob() async {
    final q = widget.existing;
    if (q == null) return;
    final nav = Navigator.of(context);
    final job = await QuoteService.instance.convertToJob(q.id);
    if (job == null || !mounted) return;
    nav.pushReplacement(
      MaterialPageRoute(
          builder: (_) => JobDetailScreen(jobId: job.id)),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.existing;
    final hours = double.tryParse(_hours.text.trim()) ?? 0;
    final rate = double.tryParse(_rate.text.trim()) ?? 0;
    final labour = hours * rate;
    final materials =
        _lines.fold<double>(0, (a, l) => a + l.totalGbp);
    final subtotal = labour + materials;

    return Scaffold(
      appBar: AppBar(
        title: Text(q == null ? 'New quote' : 'Edit quote'),
        actions: [
          if (q != null)
            IconButton(
              tooltip: 'Share PDF',
              icon: const Icon(Icons.share),
              onPressed: _share,
            ),
          if (q != null)
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
          if (q != null) _StatusBanner(quote: q),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickCustomer,
                icon: const Icon(Icons.person_search),
                label: const Text('Customer'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickTemplate,
                icon: const Icon(Icons.layers),
                label: const Text('From template'),
              ),
            ),
          ]),
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
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Scope of work',
              hintText: 'e.g. Replace combi boiler like-for-like, flush system.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _hours,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                ],
                decoration: const InputDecoration(
                  labelText: 'Estimated hours',
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
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                ],
                decoration: const InputDecoration(
                  labelText: 'Hourly rate (£)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Text('Materials',
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: _addLine,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ]),
          if (_lines.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                  'No lines yet. Add the parts you expect to use.'),
            )
          else
            ..._lines.asMap().entries.map((entry) {
              final i = entry.key;
              final l = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.description),
                subtitle: Text(
                    '${l.quantity} × £${l.unitPriceGbp.toStringAsFixed(2)} = £${l.totalGbp.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.muted),
                  onPressed: () => _removeLine(i),
                ),
              );
            }),
          const SizedBox(height: 12),
          Card(
            color: AppColors.primary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _row('Labour',
                      '£${labour.toStringAsFixed(2)}'),
                  _row('Materials',
                      '£${materials.toStringAsFixed(2)}'),
                  const Divider(),
                  _row('Subtotal',
                      '£${subtotal.toStringAsFixed(2)}',
                      bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _validFor,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: 'Valid for (days)',
              hintText: '30',
              helperText: 'Leave blank for no expiry on the PDF.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Caveats, exclusions, access requirements…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          if (q != null && q.convertedJobId == null) ...[
            ElevatedButton.icon(
              onPressed: _convertToJob,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Convert to active job'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (q != null && q.convertedJobId != null)
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JobDetailScreen(jobId: q.convertedJobId!),
                ),
              ),
              icon: const Icon(Icons.work),
              label: const Text('Open the linked job'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                )),
            Text(value,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                )),
          ],
        ),
      );
}

class _StatusBanner extends StatelessWidget {
  final Quote quote;
  const _StatusBanner({required this.quote});

  Color get _color {
    switch (quote.status) {
      case QuoteStatus.draft:
        return AppColors.muted;
      case QuoteStatus.sent:
        return AppColors.primary;
      case QuoteStatus.accepted:
        return Colors.green;
      case QuoteStatus.rejected:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = <Widget>[];
    if (quote.sentAt != null) {
      lines.add(_kv('Sent', _fmtDate(quote.sentAt!)));
    }
    if (quote.respondedAt != null) {
      lines.add(_kv('Responded', _fmtDate(quote.respondedAt!)));
    }
    final exp = quote.expiresAt;
    if (exp != null) {
      lines.add(_kv(
        'Valid until',
        '${_fmtDate(exp)}${quote.isExpired() ? ' · expired' : ''}',
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        color: _color.withValues(alpha: 0.10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.receipt_long, color: _color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${quote.quoteRef}  ·  ${quote.status.label}',
                    style: TextStyle(
                      color: _color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ]),
              if (lines.isNotEmpty) ...[
                const SizedBox(height: 6),
                ...lines,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(children: [
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.muted, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12)),
        ]),
      );
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
