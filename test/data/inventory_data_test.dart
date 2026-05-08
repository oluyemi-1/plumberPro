import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/inventory_data.dart';

void main() {
  group('InventoryAdjustment JSON', () {
    test('round-trip preserves every field including jobId + reason', () {
      final a = InventoryAdjustment(
        id: 'adj-1',
        when: DateTime.utc(2026, 5, 6, 10, 0),
        delta: -2,
        reason: AdjustmentReason.used,
        jobId: 'job-42',
        note: 'Used on Brown boiler service',
      );
      final back = InventoryAdjustment.fromJson(a.toJson());
      expect(back.id, a.id);
      expect(back.when, a.when);
      expect(back.delta, -2);
      expect(back.reason, AdjustmentReason.used);
      expect(back.jobId, 'job-42');
      expect(back.note, a.note);
    });

    test('fromJson defaults reason to correction when missing', () {
      final back = InventoryAdjustment.fromJson({
        'id': 'a',
        'when': '2026-05-06T00:00:00Z',
        'delta': 1,
      });
      expect(back.reason, AdjustmentReason.correction);
      expect(back.jobId, isNull);
      expect(back.note, isNull);
    });
  });

  group('InventoryItem stock helpers', () {
    InventoryItem mk({
      double current = 5,
      double reorder = 2,
    }) =>
        InventoryItem(
          id: 'i',
          name: 'X',
          unit: 'each',
          currentQty: current,
          reorderLevel: reorder,
          restockQty: 10,
          unitCostGbp: 1.50,
          supplier: '',
          notes: '',
          updatedAt: DateTime.utc(2026, 5, 6),
          history: const [],
          builtIn: false,
        );

    test('valueGbp = qty × unit cost', () {
      expect(mk(current: 4).valueGbp, closeTo(6.0, 1e-9));
    });

    test('isLowStock fires at or below reorder level', () {
      expect(mk(current: 3, reorder: 2).isLowStock, false);
      expect(mk(current: 2, reorder: 2).isLowStock, true);
      expect(mk(current: 1, reorder: 2).isLowStock, true);
    });

    test('reorder level 0 disables the alert entirely', () {
      expect(mk(current: 0, reorder: 0).isLowStock, false);
      expect(mk(current: 0, reorder: 0).isOutOfStock, false);
    });

    test('isOutOfStock fires only when qty is at or below 0 with an alert',
        () {
      expect(mk(current: 0, reorder: 2).isOutOfStock, true);
      expect(mk(current: -1, reorder: 2).isOutOfStock, true);
      expect(mk(current: 1, reorder: 2).isOutOfStock, false);
    });
  });

  group('InventoryItem JSON', () {
    test('round-trip preserves every field, including history list order',
        () {
      final i = InventoryItem(
        id: 'i-1',
        name: '15 mm coupler',
        unit: 'each',
        currentQty: 12,
        reorderLevel: 5,
        restockQty: 20,
        unitCostGbp: 0.85,
        supplier: 'Plumb Center',
        notes: 'Yorkshire fittings preferred',
        updatedAt: DateTime.utc(2026, 5, 6, 9, 0),
        history: [
          InventoryAdjustment(
            id: 'a1',
            when: DateTime.utc(2026, 5, 5),
            delta: -2,
            reason: AdjustmentReason.used,
            jobId: 'j-1',
            note: null,
          ),
          InventoryAdjustment(
            id: 'a2',
            when: DateTime.utc(2026, 5, 1),
            delta: 20,
            reason: AdjustmentReason.restock,
            jobId: null,
            note: 'Pickup from Plumb Center',
          ),
        ],
        builtIn: false,
      );
      final back = InventoryItem.fromJson(i.toJson());
      expect(back.id, i.id);
      expect(back.name, i.name);
      expect(back.currentQty, 12);
      expect(back.reorderLevel, 5);
      expect(back.unitCostGbp, 0.85);
      expect(back.supplier, 'Plumb Center');
      expect(back.history.length, 2);
      expect(back.history.first.id, 'a1');
      expect(back.history.first.reason, AdjustmentReason.used);
      expect(back.history.last.delta, 20);
      expect(back.builtIn, false);
    });

    test('list encode / decode round-trip', () {
      final list = [
        InventoryItem.create(name: 'A', currentQty: 1),
        InventoryItem.create(name: 'B', currentQty: 5, reorderLevel: 2),
      ];
      final back = decodeInventory(encodeInventory(list));
      expect(back.length, 2);
      expect(back[0].name, 'A');
      expect(back[1].reorderLevel, 2);
    });

    test('decode is null / empty / corrupt-safe', () {
      expect(decodeInventory(null), isEmpty);
      expect(decodeInventory(''), isEmpty);
      expect(decodeInventory('not-json'), isEmpty);
    });

    test('legacy item without history field decodes to empty list', () {
      final back = InventoryItem.fromJson({
        'id': 'legacy',
        'name': 'Legacy',
        'unit': 'each',
        'currentQty': 3,
        'reorderLevel': 1,
        'restockQty': 5,
        'unitCost': 1.0,
        'supplier': '',
        'notes': '',
        'updatedAt': '2026-05-06T00:00:00Z',
      });
      expect(back.history, isEmpty);
      expect(back.builtIn, false);
    });
  });

  group('AdjustmentReason', () {
    test('every enum value has a human-readable label', () {
      for (final r in AdjustmentReason.values) {
        expect(r.label, isNotEmpty);
      }
    });
  });

  group('defaultBuiltInInventory', () {
    test('seeds the canonical UK plumbing van set', () {
      final ids = defaultBuiltInInventory().map((i) => i.id).toSet();
      // Lock down the IDs the rest of the app may reference.
      expect(ids, containsAll(const {
        'inv-15mm-pipe',
        'inv-22mm-pipe',
        'inv-15mm-coupler',
        'inv-trv-head',
        'inv-isolator-15',
        'inv-isolator-22',
        'inv-inhibitor',
        'inv-magnetic-filter',
      }));
    });

    test('every built-in is flagged builtIn = true', () {
      for (final i in defaultBuiltInInventory()) {
        expect(i.builtIn, true,
            reason: '${i.id} should be flagged built-in');
      }
    });
  });
}
