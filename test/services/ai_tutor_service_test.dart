import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/content_index.dart';
import 'package:plumbing_and_heating/services/ai_tutor_service.dart';
import 'package:plumbing_and_heating/services/purchase_proof.dart';
import 'package:shared_preferences/shared_preferences.dart';

AiMessage _m(String role, String text) =>
    AiMessage(role: role, content: text, when: DateTime(2026, 1, 1));

/// Pure pieces of the tutor service: the history window sent upstream and the
/// entitlement record the proxy returns. The HTTP paths need a live proxy.
void main() {
  group('AiTutorService.requestWindow', () {
    test('returns everything when under the limit', () {
      final all = [_m('user', 'a'), _m('assistant', 'b'), _m('user', 'c')];
      expect(AiTutorService.requestWindow(all), all);
    });

    test('keeps only the most recent messages', () {
      final all = List.generate(
        30,
        (i) => _m(i.isEven ? 'user' : 'assistant', '$i'),
      );
      final w = AiTutorService.requestWindow(all, max: 20);
      expect(w.length, 20);
      expect(w.first.content, '10');
      expect(w.first.role, 'user');
      expect(w.last.content, '29');
    });

    test(
      'drops a leading assistant turn so the slice starts with the user',
      () {
        final all = List.generate(
          21,
          (i) => _m(i.isEven ? 'user' : 'assistant', '$i'),
        );
        // A naive last-20 slice would start at index 1, an assistant turn.
        final w = AiTutorService.requestWindow(all, max: 20);
        expect(w.first.role, 'user');
        expect(w.first.content, '2');
        expect(w.length, 19);
      },
    );

    test('empty in, empty out', () {
      expect(AiTutorService.requestWindow(const []), isEmpty);
    });
  });

  group('AiTutorService.plainSpeech', () {
    test('removes bold, heading and bullet markers', () {
      const md = '**1. Find the leak**\n- Check the PRV\n## Next\nUse `PTFE` tape *carefully*.';
      expect(
        AiTutorService.plainSpeech(md),
        '1. Find the leak\nCheck the PRV\nNext\nUse PTFE tape carefully.',
      );
    });

    test('leaves ordinary text alone', () {
      const plain = 'Set the system to 1.5 bar cold, then bleed each radiator.';
      expect(AiTutorService.plainSpeech(plain), plain);
    });
  });

  group('simulation tags', () {
    const answer = 'Bleed it from the top.\n\n[sim:radiator_bleed]\n[sim:pressure_test] [sim:radiator_bleed]';

    test('are extracted in order without repeats', () {
      expect(AiTutorService.simulationTags(answer),
          ['radiator_bleed', 'pressure_test']);
      expect(AiTutorService.simulationTags('no tags here'), isEmpty);
      expect(AiTutorService.simulationTags('[sim:Bad Id]'), isEmpty);
    });

    test('are removed from display text and speech', () {
      expect(AiTutorService.withoutSimulationTags(answer),
          'Bleed it from the top.');
      expect(AiTutorService.plainSpeech(answer).contains('sim:'), isFalse);
    });

    test('catalogue appears in the system prompt only when supplied', () {
      final svc = AiTutorService.instance;
      final before = svc.systemText;
      expect(before.contains('Simulations available'), isFalse);
      svc.simulations = const [SimulationRef('radiator_bleed', 'Bleeding a radiator')];
      final after = svc.systemText;
      expect(after, startsWith(before));
      expect(after, contains('radiator_bleed: Bleeding a radiator'));
      expect(after, contains('[sim:id]'));
      svc.simulations = const [];
    });

    test('content index exposes every simulation with a unique id', () {
      final refs = simulationRefs();
      expect(refs.length, greaterThan(40));
      expect(refs.map((r) => r.id).toSet().length, refs.length);
      final indexIds = buildContentIndex()
          .where((e) => e.type == 'Simulation')
          .map((e) => e.id)
          .toSet();
      for (final r in refs) {
        expect(indexIds, contains('sim:${r.id}'));
      }
    });
  });

  group('AiEntitlement', () {
    test('round-trips through JSON and computes remaining', () {
      final ent = AiEntitlement(
        token: 't.sig',
        expiresAt: DateTime.utc(2026, 11, 12),
        limit: 300,
        used: 57,
        resetsAt: DateTime.utc(2026, 12, 1),
      );
      final back = AiEntitlement.fromJson(ent.toJson());
      expect(back.token, 't.sig');
      expect(back.expiresAt, ent.expiresAt);
      expect(back.remaining, 243);
      expect(back.resetsAt, ent.resetsAt);
    });

    test('remaining never goes negative and is null when unknown', () {
      expect(
        AiEntitlement(
          token: 't',
          expiresAt: DateTime(2030),
          limit: 10,
          used: 12,
        ).remaining,
        0,
      );
      expect(
        AiEntitlement(token: 't', expiresAt: DateTime(2030)).remaining,
        isNull,
      );
    });

    test('withUsage keeps fields that are not supplied', () {
      final ent = AiEntitlement(
        token: 't',
        expiresAt: DateTime(2030),
        limit: 300,
        used: 1,
      );
      final next = ent.withUsage(used: 2);
      expect(next.limit, 300);
      expect(next.used, 2);
      expect(next.token, 't');
    });
  });

  group('PurchaseProof', () {
    test('saves and loads via SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await PurchaseProof.load(), isNull);
      await PurchaseProof.save(
        const PurchaseProof(
          platform: 'android',
          token: 'tok',
          productId: 'pipesmart_pro_1m',
        ),
      );
      final p = await PurchaseProof.load();
      expect(p!.platform, 'android');
      expect(p.token, 'tok');
      expect(p.productId, 'pipesmart_pro_1m');
    });
  });
}
