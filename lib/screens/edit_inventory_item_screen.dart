import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/inventory_data.dart';
import '../services/inventory_service.dart';
import '../theme.dart';

class EditInventoryItemScreen extends StatefulWidget {
  final InventoryItem? existing;
  const EditInventoryItemScreen({super.key, this.existing});

  @override
  State<EditInventoryItemScreen> createState() =>
      _EditInventoryItemScreenState();
}

class _EditInventoryItemScreenState extends State<EditInventoryItemScreen> {
  late final TextEditingController _name;
  late final TextEditingController _unit;
  late final TextEditingController _qty;
  late final TextEditingController _reorder;
  late final TextEditingController _restock;
  late final TextEditingController _cost;
  late final TextEditingController _supplier;
  late final TextEditingController _notes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.existing;
    _name = TextEditingController(text: i?.name ?? '');
    _unit = TextEditingController(text: i?.unit ?? 'each');
    _qty = TextEditingController(
        text: i == null ? '0' : _trim(i.currentQty));
    _reorder = TextEditingController(
        text: i == null ? '0' : _trim(i.reorderLevel));
    _restock = TextEditingController(
        text: i == null ? '' : _trim(i.restockQty));
    _cost = TextEditingController(
        text: i == null ? '' : i.unitCostGbp.toStringAsFixed(2));
    _supplier = TextEditingController(text: i?.supplier ?? '');
    _notes = TextEditingController(text: i?.notes ?? '');
  }

  String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _qty.dispose();
    _reorder.dispose();
    _restock.dispose();
    _cost.dispose();
    _supplier.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_name.text.trim().isEmpty) {
      _toast('Add a name for the part.');
      return;
    }
    setState(() => _saving = true);
    final svc = InventoryService.instance;
    double parse(String s, {double fallback = 0}) =>
        double.tryParse(s.trim()) ?? fallback;

    if (widget.existing == null) {
      await svc.create(InventoryItem.create(
        name: _name.text,
        unit: _unit.text,
        currentQty: parse(_qty.text),
        reorderLevel: parse(_reorder.text),
        restockQty: parse(_restock.text),
        unitCostGbp: parse(_cost.text),
        supplier: _supplier.text,
        notes: _notes.text,
      ));
    } else {
      // Editing — keep existing currentQty unless the user changed it
      // explicitly (we can't tell, so trust what's in the field).
      await svc.update(widget.existing!.copyWith(
        name: _name.text.trim(),
        unit: _unit.text.trim().isEmpty ? 'each' : _unit.text.trim(),
        currentQty: parse(_qty.text),
        reorderLevel: parse(_reorder.text),
        restockQty: parse(_restock.text),
        unitCostGbp: parse(_cost.text),
        supplier: _supplier.text.trim(),
        notes: _notes.text,
        updatedAt: DateTime.now(),
      ));
    }
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final i = widget.existing;
    if (i == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete this item?'),
        content: Text(i.builtIn
            ? 'This is one of the built-in items. You can restore it later from the inventory list menu.'
            : 'This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
    await InventoryService.instance.delete(i.id);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.existing;
    return Scaffold(
      appBar: AppBar(
        title: Text(i == null ? 'New inventory item' : 'Edit item'),
        actions: [
          if (i != null)
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
          TextField(
            controller: _name,
            autofocus: i == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Part name',
              hintText: 'e.g. 15 mm equal coupler',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _qty,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Current qty',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _unit,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  hintText: 'each',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _reorder,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Reorder at',
                  helperText: '0 = no alert',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _restock,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Restock qty',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          TextField(
            controller: _cost,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: const InputDecoration(
              labelText: 'Unit cost (£) — what you pay',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _supplier,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Usual supplier (optional)',
              hintText: 'e.g. Plumb Center, Screwfix',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          if (i != null) ...[
            const SizedBox(height: 18),
            _HistoryCard(item: i),
          ],
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final InventoryItem item;
  const _HistoryCard({required this.item});

  String _trim(double v) {
    final abs = v.abs();
    final s = abs == abs.roundToDouble()
        ? abs.toStringAsFixed(0)
        : abs.toString();
    return v < 0 ? '-$s' : '+$s';
  }

  String _formatWhen(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(0, 59)}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent adjustments',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            if (item.history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                    'No adjustments yet. Tap +/- on the inventory list to record stock changes.'),
              )
            else
              for (final a in item.history.take(20))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(
                    a.delta < 0 ? Icons.remove_circle : Icons.add_circle,
                    color: a.delta < 0
                        ? Colors.redAccent
                        : Colors.green,
                    size: 20,
                  ),
                  title: Text(
                    '${_trim(a.delta)} ${item.unit} · ${a.reason.label}',
                  ),
                  subtitle: Text(
                    [
                      _formatWhen(a.when),
                      if (a.note != null && a.note!.isNotEmpty) a.note,
                    ].join(' · '),
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 12),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
