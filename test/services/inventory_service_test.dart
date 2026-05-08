import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/inventory_data.dart';
import 'package:plumbing_and_heating/services/inventory_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(const {});
    await InventoryService.instance.reload();
  });

  group('InventoryService.adjust', () {
    test('positive delta increases currentQty and logs reason=restock',
        () async {
      final created = await InventoryService.instance.create(
        InventoryItem.create(name: 'Coupler', currentQty: 5),
      );
      final updated = await InventoryService.instance.adjust(
        id: created.id,
        delta: 10,
        reason: AdjustmentReason.restock,
        note: 'Plumb Center pickup',
      );
      expect(updated, isNotNull);
      expect(updated!.currentQty, 15);
      expect(updated.history.length, 1);
      expect(updated.history.first.delta, 10);
      expect(updated.history.first.reason, AdjustmentReason.restock);
      expect(updated.history.first.note, 'Plumb Center pickup');
    });

    test('negative delta decreases currentQty and logs reason=used',
        () async {
      final created = await InventoryService.instance.create(
        InventoryItem.create(name: 'TRV', currentQty: 4),
      );
      final updated = await InventoryService.instance.adjust(
        id: created.id,
        delta: -1,
        reason: AdjustmentReason.used,
        jobId: 'job-77',
      );
      expect(updated!.currentQty, 3);
      expect(updated.history.first.jobId, 'job-77');
      expect(updated.history.first.reason, AdjustmentReason.used);
    });

    test('history is newest-first across multiple adjustments', () async {
      final created = await InventoryService.instance.create(
        InventoryItem.create(name: 'X', currentQty: 0),
      );
      await InventoryService.instance.adjust(
        id: created.id,
        delta: 10,
        reason: AdjustmentReason.restock,
        note: 'first',
      );
      await InventoryService.instance.adjust(
        id: created.id,
        delta: -3,
        reason: AdjustmentReason.used,
        note: 'second',
      );
      final back = InventoryService.instance.findById(created.id)!;
      expect(back.currentQty, 7);
      expect(back.history.length, 2);
      expect(back.history.first.note, 'second');
      expect(back.history.last.note, 'first');
    });

    test('unknown id returns null and does not throw', () async {
      final r = await InventoryService.instance.adjust(
        id: 'does-not-exist',
        delta: 1,
        reason: AdjustmentReason.restock,
      );
      expect(r, isNull);
    });
  });

  // The built-in items are seeded with currentQty: 0 and reorderLevel > 0,
  // so they all count as low-stock. Clear the slate for tests that
  // assert exact counts.
  Future<void> wipe() async {
    for (final i in [...InventoryService.instance.items]) {
      await InventoryService.instance.delete(i.id);
    }
  }

  group('InventoryService.lowStock', () {
    test('low-stock list is recomputed after every adjustment', () async {
      await wipe();
      final i = await InventoryService.instance.create(
        InventoryItem.create(
          name: 'Coupler',
          currentQty: 5,
          reorderLevel: 3,
        ),
      );
      expect(InventoryService.instance.lowStockCount, 0);
      await InventoryService.instance.adjust(
        id: i.id,
        delta: -3,
        reason: AdjustmentReason.used,
      );
      expect(InventoryService.instance.lowStockCount, 1);
      // And the item is sorted to the top of the list.
      expect(InventoryService.instance.items.first.id, i.id);
    });

    test('items with reorderLevel = 0 never count as low-stock', () async {
      await wipe();
      await InventoryService.instance.create(InventoryItem.create(
        name: 'Magnetic filter',
        currentQty: 0,
        reorderLevel: 0,
      ));
      expect(InventoryService.instance.lowStockCount, 0);
    });
  });

  group('InventoryService.totalValueGbp', () {
    test('sums currentQty × unitCost across every item', () async {
      await InventoryService.instance.create(InventoryItem.create(
          name: 'A', currentQty: 4, unitCostGbp: 2.50));
      await InventoryService.instance.create(InventoryItem.create(
          name: 'B', currentQty: 10, unitCostGbp: 0.85));
      // 4*2.50 + 10*0.85 = 10 + 8.5 = 18.5
      expect(InventoryService.instance.totalValueGbp, closeTo(18.5, 1e-9));
    });
  });

  group('InventoryService persistence + seeding', () {
    test('first load on a clean prefs seeds the built-in items', () async {
      // setUp already cleared prefs and reloaded — built-ins should be in
      // place since this is effectively a "first run".
      final names =
          InventoryService.instance.items.map((i) => i.name).toSet();
      expect(names, contains('15 mm copper pipe'));
      expect(names, contains('TRV head'));
    });

    test(
        'second load on a previously-seeded prefs does NOT re-add the defaults',
        () async {
      // Delete every item, set seeded flag, then reload.
      for (final i in [...InventoryService.instance.items]) {
        await InventoryService.instance.delete(i.id);
      }
      await InventoryService.instance.reload();
      expect(InventoryService.instance.items, isEmpty,
          reason: 'seeding must not run again on subsequent loads');
    });

    test('restoreBuiltIns brings deleted defaults back without touching custom',
        () async {
      // Add a custom item.
      final custom = await InventoryService.instance.create(
          InventoryItem.create(name: 'Custom thing', currentQty: 1));
      // Delete a built-in.
      final trv = InventoryService.instance.items
          .firstWhere((i) => i.name == 'TRV head');
      await InventoryService.instance.delete(trv.id);
      expect(
        InventoryService.instance.items
            .where((i) => i.name == 'TRV head')
            .length,
        0,
      );
      await InventoryService.instance.restoreBuiltIns();
      expect(
        InventoryService.instance.items
            .where((i) => i.name == 'TRV head')
            .length,
        1,
      );
      // Custom item still there.
      expect(
        InventoryService.instance.items
            .firstWhere((i) => i.id == custom.id)
            .name,
        'Custom thing',
      );
    });

    test('items survive a reload — currentQty and history persist', () async {
      final i = await InventoryService.instance.create(
        InventoryItem.create(name: 'Persist', currentQty: 5),
      );
      await InventoryService.instance.adjust(
        id: i.id,
        delta: -2,
        reason: AdjustmentReason.used,
      );
      await InventoryService.instance.reload();
      final back = InventoryService.instance.findById(i.id)!;
      expect(back.currentQty, 3);
      expect(back.history.length, 1);
    });
  });
}
