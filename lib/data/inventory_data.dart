import 'dart:convert';
import 'dart:math' as math;

import 'schema_safe.dart';

enum AdjustmentReason { used, restock, correction }

AdjustmentReason _decodeReason(String? raw) {
  for (final r in AdjustmentReason.values) {
    if (r.name == raw) return r;
  }
  return AdjustmentReason.correction;
}

extension AdjustmentReasonX on AdjustmentReason {
  String get label {
    switch (this) {
      case AdjustmentReason.used:
        return 'Used';
      case AdjustmentReason.restock:
        return 'Restocked';
      case AdjustmentReason.correction:
        return 'Manual correction';
    }
  }
}

/// One line in an inventory item's audit history. Positive [delta] = stock
/// added, negative = stock used. Optional [jobId] anchors a "used" entry to
/// the job it was used on.
class InventoryAdjustment {
  final String id;
  final DateTime when;
  final double delta;
  final AdjustmentReason reason;
  final String? jobId;
  final String? note;

  const InventoryAdjustment({
    required this.id,
    required this.when,
    required this.delta,
    required this.reason,
    required this.jobId,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'when': when.toIso8601String(),
        'delta': delta,
        'reason': reason.name,
        'jobId': jobId,
        'note': note,
      };

  factory InventoryAdjustment.fromJson(Map<String, dynamic> j) =>
      InventoryAdjustment(
        id: j['id'] as String,
        when: DateTime.tryParse(j['when'] as String? ?? '') ??
            DateTime.now(),
        delta: (j['delta'] as num?)?.toDouble() ?? 0,
        reason: _decodeReason(j['reason'] as String?),
        jobId: j['jobId'] as String?,
        note: j['note'] as String?,
      );
}

/// One stock-tracked part in the plumber's van. Quantities are doubles so
/// items like "12.5m of pipe" make sense — most items will use whole
/// numbers but we don't enforce it.
class InventoryItem {
  final String id;
  final String name;
  final String unit; // 'each', 'm', 'pack', 'box', 'kg' …
  final double currentQty;
  final double reorderLevel;
  final double restockQty;
  final double unitCostGbp;
  final String supplier;
  final String notes;
  final DateTime updatedAt;
  final List<InventoryAdjustment> history;
  final bool builtIn;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentQty,
    required this.reorderLevel,
    required this.restockQty,
    required this.unitCostGbp,
    required this.supplier,
    required this.notes,
    required this.updatedAt,
    required this.history,
    required this.builtIn,
  });

  factory InventoryItem.create({
    required String name,
    String unit = 'each',
    double currentQty = 0,
    double reorderLevel = 0,
    double restockQty = 0,
    double unitCostGbp = 0,
    String supplier = '',
    String notes = '',
  }) =>
      InventoryItem(
        id: _generateId(),
        name: name.trim(),
        unit: unit.trim().isEmpty ? 'each' : unit.trim(),
        currentQty: currentQty,
        reorderLevel: reorderLevel,
        restockQty: restockQty,
        unitCostGbp: unitCostGbp,
        supplier: supplier.trim(),
        notes: notes.trim(),
        updatedAt: DateTime.now(),
        history: const [],
        builtIn: false,
      );

  /// Stock value at cost (£). Useful for a "you've got £X of parts in your
  /// van" headline number on the inventory hero card.
  double get valueGbp => currentQty * unitCostGbp;

  /// Below or at the reorder level. Reorder level == 0 means no alert.
  bool get isLowStock => reorderLevel > 0 && currentQty <= reorderLevel;

  /// Below 1 stock unit AND has a reorder level set. Treated as a stronger
  /// "you'll run out next visit" warning.
  bool get isOutOfStock => reorderLevel > 0 && currentQty <= 0;

  InventoryItem copyWith({
    String? name,
    String? unit,
    double? currentQty,
    double? reorderLevel,
    double? restockQty,
    double? unitCostGbp,
    String? supplier,
    String? notes,
    DateTime? updatedAt,
    List<InventoryAdjustment>? history,
  }) =>
      InventoryItem(
        id: id,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        currentQty: currentQty ?? this.currentQty,
        reorderLevel: reorderLevel ?? this.reorderLevel,
        restockQty: restockQty ?? this.restockQty,
        unitCostGbp: unitCostGbp ?? this.unitCostGbp,
        supplier: supplier ?? this.supplier,
        notes: notes ?? this.notes,
        updatedAt: updatedAt ?? this.updatedAt,
        history: history ?? this.history,
        builtIn: builtIn,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'unit': unit,
        'currentQty': currentQty,
        'reorderLevel': reorderLevel,
        'restockQty': restockQty,
        'unitCost': unitCostGbp,
        'supplier': supplier,
        'notes': notes,
        'updatedAt': updatedAt.toIso8601String(),
        'history': history.map((h) => h.toJson()).toList(),
        'builtIn': builtIn,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        unit: j['unit'] as String? ?? 'each',
        currentQty: (j['currentQty'] as num?)?.toDouble() ?? 0,
        reorderLevel: (j['reorderLevel'] as num?)?.toDouble() ?? 0,
        restockQty: (j['restockQty'] as num?)?.toDouble() ?? 0,
        unitCostGbp: (j['unitCost'] as num?)?.toDouble() ?? 0,
        supplier: j['supplier'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ??
            DateTime.now(),
        history: ((j['history'] as List?) ?? const [])
            .map((e) => InventoryAdjustment.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ))
            .toList(),
        builtIn: j['builtIn'] as bool? ?? false,
      );
}

String _generateId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final r = math.Random().nextInt(1 << 32);
  return 'inv-$ts-${r.toRadixString(36)}';
}

/// Common UK domestic-plumbing van stock. Seeded on first run; users can
/// edit / delete and call "restore defaults" to bring this set back.
List<InventoryItem> defaultBuiltInInventory() {
  final now = DateTime.now();
  InventoryItem mk({
    required String id,
    required String name,
    String unit = 'each',
    double currentQty = 0,
    double reorderLevel = 1,
    double restockQty = 5,
    double unitCostGbp = 0,
    String supplier = '',
  }) =>
      InventoryItem(
        id: id,
        name: name,
        unit: unit,
        currentQty: currentQty,
        reorderLevel: reorderLevel,
        restockQty: restockQty,
        unitCostGbp: unitCostGbp,
        supplier: supplier,
        notes: '',
        updatedAt: now,
        history: const [],
        builtIn: true,
      );

  return [
    mk(id: 'inv-15mm-pipe', name: '15 mm copper pipe', unit: 'm',
        reorderLevel: 6, restockQty: 12, unitCostGbp: 4.20),
    mk(id: 'inv-22mm-pipe', name: '22 mm copper pipe', unit: 'm',
        reorderLevel: 4, restockQty: 12, unitCostGbp: 7.50),
    mk(id: 'inv-15mm-coupler', name: '15 mm equal coupler',
        reorderLevel: 5, restockQty: 20, unitCostGbp: 0.85),
    mk(id: 'inv-15mm-elbow', name: '15 mm 90° elbow',
        reorderLevel: 5, restockQty: 20, unitCostGbp: 1.10),
    mk(id: 'inv-15mm-tee', name: '15 mm equal tee',
        reorderLevel: 3, restockQty: 10, unitCostGbp: 1.40),
    mk(id: 'inv-22mm-coupler', name: '22 mm equal coupler',
        reorderLevel: 3, restockQty: 10, unitCostGbp: 1.30),
    mk(id: 'inv-22mm-elbow', name: '22 mm 90° elbow',
        reorderLevel: 3, restockQty: 10, unitCostGbp: 1.65),
    mk(id: 'inv-22mm-tee', name: '22 mm equal tee',
        reorderLevel: 2, restockQty: 6, unitCostGbp: 2.10),
    mk(id: 'inv-tap-washers-half', name: '1/2" tap washers',
        unit: 'pack', reorderLevel: 1, restockQty: 2, unitCostGbp: 1.50),
    mk(id: 'inv-tap-washers-three-quarter', name: '3/4" tap washers',
        unit: 'pack', reorderLevel: 1, restockQty: 2, unitCostGbp: 1.50),
    mk(id: 'inv-trv-head', name: 'TRV head',
        reorderLevel: 1, restockQty: 4, unitCostGbp: 8.50),
    mk(id: 'inv-lockshield', name: 'Lockshield',
        reorderLevel: 1, restockQty: 4, unitCostGbp: 5.00),
    mk(id: 'inv-isolator-15', name: '15 mm isolator valve',
        reorderLevel: 2, restockQty: 6, unitCostGbp: 2.40),
    mk(id: 'inv-isolator-22', name: '22 mm isolator valve',
        reorderLevel: 2, restockQty: 6, unitCostGbp: 3.20),
    mk(id: 'inv-magnetic-filter', name: 'Magnetic filter',
        reorderLevel: 0, restockQty: 1, unitCostGbp: 65.00),
    mk(id: 'inv-inhibitor', name: 'Inhibitor 500 ml',
        reorderLevel: 1, restockQty: 4, unitCostGbp: 12.00),
    mk(id: 'inv-ptfe', name: 'PTFE tape',
        reorderLevel: 2, restockQty: 6, unitCostGbp: 0.90),
    mk(id: 'inv-boss-white', name: 'Boss White (jointing compound)',
        reorderLevel: 0, restockQty: 1, unitCostGbp: 6.50),
  ];
}

String encodeInventory(List<InventoryItem> list) =>
    jsonEncode(list.map((i) => i.toJson()).toList());

List<InventoryItem> decodeInventory(String? raw) =>
    SchemaSafe.decodeList<InventoryItem>(
      key: 'inventory_v1',
      raw: raw,
      fromJson: InventoryItem.fromJson,
    );
