import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/inventory_data.dart';

/// Singleton store for the plumber's van stock. Behaves like the other
/// CRUD services in the app: ChangeNotifier, ensureLoaded, reload, plus a
/// dedicated `adjust` method that updates the current quantity *and*
/// records an audit entry in the item's history.
class InventoryService extends ChangeNotifier {
  InventoryService._();
  static final InventoryService instance = InventoryService._();

  static const _kKey = 'inventory_v1';
  static const _kSeeded = 'inventory_seeded_v1';

  final List<InventoryItem> _items = [];
  bool _loaded = false;

  /// Sorted: low-stock first, then alphabetical by name.
  List<InventoryItem> get items => List.unmodifiable(_items);
  bool get loaded => _loaded;

  /// Items currently at or below their reorder level (with reorderLevel > 0).
  List<InventoryItem> get lowStock =>
      _items.where((i) => i.isLowStock).toList();

  int get lowStockCount => lowStock.length;

  /// Total cost-basis value of everything in stock (£).
  double get totalValueGbp =>
      _items.fold(0.0, (sum, i) => sum + i.valueGbp);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final stored = decodeInventory(prefs.getString(_kKey));
    final seeded = prefs.getBool(_kSeeded) ?? false;
    if (stored.isEmpty && !seeded) {
      _items.addAll(defaultBuiltInInventory());
      await prefs.setString(_kKey, encodeInventory(_items));
      await prefs.setBool(_kSeeded, true);
    } else {
      _items.addAll(stored);
    }
    _sort();
    _loaded = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _items.clear();
    _loaded = false;
    await ensureLoaded();
  }

  void _sort() {
    _items.sort((a, b) {
      if (a.isLowStock != b.isLowStock) return a.isLowStock ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, encodeInventory(_items));
  }

  InventoryItem? findById(String id) {
    for (final i in _items) {
      if (i.id == id) return i;
    }
    return null;
  }

  Future<InventoryItem> create(InventoryItem item) async {
    _items.add(item);
    _sort();
    await _save();
    notifyListeners();
    return item;
  }

  Future<void> update(InventoryItem item) async {
    final i = _items.indexWhere((x) => x.id == item.id);
    if (i == -1) return;
    _items[i] = item;
    _sort();
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _save();
    notifyListeners();
  }

  /// Apply a stock adjustment of [delta] (positive = added, negative =
  /// used) and append a history entry. Returns the updated item, or null
  /// if [id] doesn't match.
  Future<InventoryItem?> adjust({
    required String id,
    required double delta,
    required AdjustmentReason reason,
    String? jobId,
    String? note,
  }) async {
    final i = _items.indexWhere((x) => x.id == id);
    if (i == -1) return null;
    final cur = _items[i];
    final entry = InventoryAdjustment(
      id: 'adj-${DateTime.now().millisecondsSinceEpoch}-${math.Random().nextInt(1 << 16)}',
      when: DateTime.now(),
      delta: delta,
      reason: reason,
      jobId: jobId,
      note: note,
    );
    final updated = cur.copyWith(
      currentQty: cur.currentQty + delta,
      updatedAt: DateTime.now(),
      history: [entry, ...cur.history], // newest first
    );
    _items[i] = updated;
    _sort();
    await _save();
    notifyListeners();
    return updated;
  }

  /// Re-add any built-in items the user has deleted, leaving custom items
  /// and quantities alone. Same pattern as `JobTemplateService`.
  Future<void> restoreBuiltIns() async {
    final defaults = defaultBuiltInInventory();
    final existing = _items.map((i) => i.id).toSet();
    var added = 0;
    for (final d in defaults) {
      if (!existing.contains(d.id)) {
        _items.add(d);
        added++;
      }
    }
    if (added == 0) return;
    _sort();
    await _save();
    notifyListeners();
  }
}
