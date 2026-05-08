import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/job_template_data.dart';
import '../services/job_template_service.dart';
import '../theme.dart';
import 'templates_screen.dart';

class EditTemplateScreen extends StatefulWidget {
  final JobTemplate? existing;
  const EditTemplateScreen({super.key, this.existing});

  @override
  State<EditTemplateScreen> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState extends State<EditTemplateScreen> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _rate;
  late final TextEditingController _notes;
  late String _iconCode;
  late List<TemplateMaterialLine> _materials;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _name = TextEditingController(text: t?.name ?? '');
    _description = TextEditingController(text: t?.description ?? '');
    _rate = TextEditingController(
      text: t?.defaultHourlyRateGbp == null
          ? ''
          : t!.defaultHourlyRateGbp!.toStringAsFixed(0),
    );
    _notes = TextEditingController(text: t?.defaultNotes ?? '');
    _iconCode = t?.iconCode ?? 'wrench';
    _materials = [...?t?.suggestedMaterials];
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _rate.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the template a name.')),
      );
      return;
    }
    setState(() => _saving = true);
    final svc = JobTemplateService.instance;
    final rate = _rate.text.trim().isEmpty
        ? null
        : double.tryParse(_rate.text.trim());
    final result = widget.existing == null
        ? JobTemplate.create(
            name: name,
            description: _description.text,
            defaultHourlyRateGbp: rate,
            suggestedMaterials: _materials,
            defaultNotes: _notes.text,
            iconCode: _iconCode,
          )
        : widget.existing!.copyWith(
            name: name,
            description: _description.text,
            defaultHourlyRateGbp: rate,
            clearRate: rate == null,
            suggestedMaterials: _materials,
            defaultNotes: _notes.text,
            iconCode: _iconCode,
          );
    if (widget.existing == null) {
      await svc.create(result);
    } else {
      await svc.update(result);
    }
    if (!mounted) return;
    Navigator.pop<JobTemplate>(context, result);
  }

  Future<void> _delete() async {
    final t = widget.existing;
    if (t == null) return;
    final nav = Navigator.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this template?'),
        content: Text(t.builtIn
            ? 'This is a built-in template. You can restore it from the templates list menu later.'
            : 'This is one of your custom templates. Existing jobs created from it are not affected.'),
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
    await JobTemplateService.instance.delete(t.id);
    if (!mounted) return;
    nav.pop();
  }

  Future<void> _addMaterial() async {
    final desc = TextEditingController();
    final qty = TextEditingController(text: '1');
    final price = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Suggested material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: desc,
              autofocus: true,
              decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. Inhibitor, magnetic filter'),
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
                  decoration:
                      const InputDecoration(labelText: 'Default qty'),
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
                  decoration: const InputDecoration(
                      labelText: 'Default price (£)'),
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
      setState(() => _materials.add(TemplateMaterialLine(
            description: desc.text.trim(),
            quantity: double.tryParse(qty.text.trim()) ?? 1,
            unitPriceGbp: double.tryParse(price.text.trim()) ?? 0,
          )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null
            ? 'New template'
            : 'Edit template'),
        actions: [
          if (widget.existing != null)
            IconButton(
              tooltip: 'Delete template',
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
          TextField(
            controller: _name,
            autofocus: widget.existing == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Template name',
              hintText: 'e.g. Annual boiler service',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _description,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Default description',
              hintText: 'Pre-fills the new job\'s description.',
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
              labelText: 'Default hourly rate (£)',
              hintText: 'Leave blank to use your global default',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Text('Icon', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: templateIconOptions.map((opt) {
              final code = opt.$1;
              final icon = opt.$2;
              final selected = code == _iconCode;
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _iconCode = code),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.18)
                        : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : Colors.black12,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Icon(icon,
                      color: selected ? AppColors.primary : AppColors.muted),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Text('Suggested materials',
                style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: _addMaterial,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ]),
          if (_materials.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                  'None yet. Add the parts you typically use for this job.'),
            )
          else
            ..._materials.asMap().entries.map((e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.value.description),
                  subtitle: Text(
                      '${e.value.quantity} × £${e.value.unitPriceGbp.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.muted),
                    onPressed: () =>
                        setState(() => _materials.removeAt(e.key)),
                  ),
                )),
          const SizedBox(height: 14),
          TextField(
            controller: _notes,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Default notes / prompts',
              hintText:
                  'Pre-fills the job notes — useful for things you always record (gas pressures, readings, etc.)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.check),
            label: Text(widget.existing == null
                ? 'Create template'
                : 'Save changes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
