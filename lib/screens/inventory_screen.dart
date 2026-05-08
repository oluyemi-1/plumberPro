import 'package:flutter/material.dart';

import '../data/inventory_data.dart';
import '../services/inventory_service.dart';
import '../theme.dart';
import 'edit_inventory_item_screen.dart';

/// Lists every part the user is tracking in their van. Low-stock items
/// surface at the top in red so the next supplier run is obvious.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    InventoryService.instance.ensureLoaded();
  }

  Future<void> _restoreBuiltIns() async {
    final messenger = ScaffoldMessenger.of(context);
    await InventoryService.instance.restoreBuiltIns();
    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Built-in items restored.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Van inventory'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'restore') await _restoreBuiltIns();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'restore',
                child: Text('Restore built-in items'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const EditInventoryItemScreen()),
        ),
      ),
      body: AnimatedBuilder(
        animation: InventoryService.instance,
        builder: (context, _) {
          final svc = InventoryService.instance;
          final all = svc.items;
          if (all.isEmpty) return const _EmptyState();
          final low = all.where((i) => i.isLowStock).toList();
          final ok = all.where((i) => !i.isLowStock).toList();

          // Heterogeneous flat list for ListView.builder (cheap at any size).
          final cells = <Object>[
            const _HeroSlot(),
          ];
          if (low.isNotEmpty) {
            cells.add(const _SectionSlot('Low stock', Colors.redAccent));
            cells.addAll(low);
          }
          if (ok.isNotEmpty) {
            cells.add(const _SectionSlot('In stock', AppColors.primary));
            cells.addAll(ok);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
            itemCount: cells.length,
            itemBuilder: (_, i) {
              final c = cells[i];
              if (c is _HeroSlot) return const _HeroCard();
              if (c is _SectionSlot) {
                return _SectionHeader(label: c.label, color: c.color);
              }
              return _ItemRow(item: c as InventoryItem);
            },
          );
        },
      ),
    );
  }
}

class _HeroSlot {
  const _HeroSlot();
}

class _SectionSlot {
  final String label;
  final Color color;
  const _SectionSlot(this.label, this.color);
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final svc = InventoryService.instance;
    final lowCount = svc.lowStockCount;
    final total = svc.items.length;
    final value = svc.totalValueGbp;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lowCount > 0
                    ? '$lowCount item${lowCount == 1 ? '' : 's'} low — restock before next visit'
                    : 'All stock levels healthy',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Wrap(spacing: 10, runSpacing: 6, children: [
                _Pill(label: '$total parts'),
                _Pill(label: '£${value.toStringAsFixed(2)} value'),
                if (lowCount > 0)
                  _Pill(
                      label: '$lowCount low',
                      pillColor: Colors.redAccent),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color? pillColor;
  const _Pill({required this.label, this.pillColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (pillColor ?? Colors.white).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(
            color: pillColor == null ? Colors.white : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          )),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Row(children: [
        Container(width: 4, height: 16, color: color),
        const SizedBox(width: 8),
        Text(label.toUpperCase(),
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2)),
      ]),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final InventoryItem item;
  const _ItemRow({required this.item});

  String _formatQty(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Future<void> _adjust(BuildContext context, double delta) async {
    final reason = delta < 0
        ? AdjustmentReason.used
        : AdjustmentReason.restock;
    await InventoryService.instance.adjust(
      id: item.id,
      delta: delta,
      reason: reason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final low = item.isLowStock;
    final out = item.isOutOfStock;
    final accent = out
        ? Colors.redAccent
        : low
            ? AppColors.accent
            : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditInventoryItemScreen(existing: item),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  out
                      ? Icons.error
                      : low
                          ? Icons.warning_amber
                          : Icons.inventory_2,
                  color: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      '${_formatQty(item.currentQty)} ${item.unit}'
                      '${item.reorderLevel > 0 ? ' · reorder at ${_formatQty(item.reorderLevel)}' : ''}',
                      style: TextStyle(
                        color: low ? accent : AppColors.muted,
                        fontSize: 12,
                        fontWeight:
                            low ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Used one',
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => _adjust(context, -1),
              ),
              IconButton(
                tooltip: 'Restocked one',
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _adjust(context, 1),
              ),
            ]),
          ),
        ),
      ),
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
            const Icon(Icons.inventory_2_outlined,
                size: 64, color: AppColors.muted),
            const SizedBox(height: 8),
            Text('No inventory yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            const Text(
              'Tap Add item to track a part you keep in the van. Or open the menu in the AppBar to seed a default UK domestic-plumbing set.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
