import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/job_template_data.dart';

void main() {
  group('TemplateMaterialLine JSON', () {
    test('round-trip preserves fields', () {
      const m = TemplateMaterialLine(
        description: 'Inhibitor',
        quantity: 1,
        unitPriceGbp: 12.0,
      );
      final back = TemplateMaterialLine.fromJson(m.toJson());
      expect(back.description, m.description);
      expect(back.quantity, m.quantity);
      expect(back.unitPriceGbp, m.unitPriceGbp);
    });

    test('fromJson tolerates missing fields', () {
      final back = TemplateMaterialLine.fromJson({});
      expect(back.description, '');
      expect(back.quantity, 1.0);
      expect(back.unitPriceGbp, 0.0);
    });
  });

  group('JobTemplate JSON', () {
    test('round-trip preserves fully-populated template', () {
      final t = JobTemplate(
        id: 'tpl-1',
        name: 'Annual boiler service',
        description: 'Per manufacturer instructions.',
        defaultHourlyRateGbp: 60,
        suggestedMaterials: const [
          TemplateMaterialLine(
              description: 'Seals', quantity: 1, unitPriceGbp: 8),
        ],
        defaultNotes: 'Combustion analyser cal date:',
        iconCode: 'flame',
        builtIn: true,
      );
      final back = JobTemplate.fromJson(t.toJson());
      expect(back.id, t.id);
      expect(back.name, t.name);
      expect(back.description, t.description);
      expect(back.defaultHourlyRateGbp, t.defaultHourlyRateGbp);
      expect(back.suggestedMaterials.length, 1);
      expect(back.defaultNotes, t.defaultNotes);
      expect(back.iconCode, t.iconCode);
      expect(back.builtIn, true);
    });

    test('null hourly rate survives the round-trip', () {
      final t = JobTemplate.create(
        name: 'Whatever',
        description: '',
      );
      expect(t.defaultHourlyRateGbp, isNull);
      final back = JobTemplate.fromJson(t.toJson());
      expect(back.defaultHourlyRateGbp, isNull);
      expect(back.builtIn, false);
    });

    test('copyWith with clearRate=true wipes the default rate', () {
      final t = JobTemplate.create(
        name: 'X',
        description: '',
        defaultHourlyRateGbp: 80,
      );
      final cleared = t.copyWith(clearRate: true);
      expect(cleared.defaultHourlyRateGbp, isNull);
    });

    test('list encode/decode round-trip', () {
      final list = [
        JobTemplate.create(name: 'A', description: ''),
        JobTemplate.create(
            name: 'B', description: 'desc', defaultHourlyRateGbp: 50),
      ];
      final back = decodeTemplates(encodeTemplates(list));
      expect(back.length, 2);
      expect(back[0].name, 'A');
      expect(back[1].defaultHourlyRateGbp, 50);
    });

    test('decode is null/corrupt-safe', () {
      expect(decodeTemplates(null), isEmpty);
      expect(decodeTemplates(''), isEmpty);
      expect(decodeTemplates('not-valid'), isEmpty);
    });
  });

  group('defaultBuiltInTemplates', () {
    test('seeds at least the canonical UK plumbing scenarios', () {
      final ids = defaultBuiltInTemplates().map((t) => t.id).toSet();
      // These IDs are the keys the rest of the app passes around — if any of
      // them ever changes name, downstream features (e.g. service reminders
      // pre-pinning a template) will silently miss. Lock them in.
      expect(ids, containsAll(const {
        'tpl-boiler-service',
        'tpl-leaking-tap',
        'tpl-blocked-sink',
        'tpl-radiator-replace',
        'tpl-power-flush',
        'tpl-tightness-test',
      }));
    });

    test('every built-in is flagged builtIn = true', () {
      for (final t in defaultBuiltInTemplates()) {
        expect(t.builtIn, true, reason: '${t.id} should be flagged built-in');
      }
    });
  });
}
