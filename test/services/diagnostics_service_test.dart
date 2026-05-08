import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/services/diagnostics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(const {});
    await DiagnosticsService.instance.reload();
  });

  group('DiagnosticsService logging', () {
    test('records an info / warning / error event each', () {
      final svc = DiagnosticsService.instance;
      svc.info('TestSource', 'an info note');
      svc.warning('TestSource', 'a warning');
      svc.error('TestSource', 'an error');
      expect(svc.events.length, 3);
      // Newest first.
      expect(svc.events[0].severity, DiagSeverity.error);
      expect(svc.events[1].severity, DiagSeverity.warning);
      expect(svc.events[2].severity, DiagSeverity.info);
    });

    test('errorCount counts only error-severity entries', () {
      final svc = DiagnosticsService.instance;
      svc.info('s', 'a');
      svc.error('s', 'b');
      svc.error('s', 'c');
      svc.warning('s', 'd');
      expect(svc.errorCount, 2);
    });

    test('caps at maxEvents — oldest are dropped first', () {
      final svc = DiagnosticsService.instance;
      // Push one more than the cap.
      for (var i = 0; i < DiagnosticsService.maxEvents + 5; i++) {
        svc.info('TestSource', 'evt $i');
      }
      expect(svc.events.length, DiagnosticsService.maxEvents);
      // Newest first — most recent push should be at index 0.
      expect(svc.events.first.message,
          'evt ${DiagnosticsService.maxEvents + 4}');
    });
  });

  group('DiagnosticsService persistence', () {
    test('events survive a reload', () async {
      DiagnosticsService.instance.error('SourceA', 'persist test');
      // Give the fire-and-forget _save() a tick to flush.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await DiagnosticsService.instance.reload();
      expect(DiagnosticsService.instance.events.length, 1);
      expect(DiagnosticsService.instance.events.first.source, 'SourceA');
      expect(DiagnosticsService.instance.events.first.severity,
          DiagSeverity.error);
    });

    test('clear() empties the log on disk too', () async {
      DiagnosticsService.instance.info('s', 'one');
      DiagnosticsService.instance.error('s', 'two');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await DiagnosticsService.instance.clear();
      expect(DiagnosticsService.instance.events, isEmpty);
      // And it's gone from prefs after reload.
      await DiagnosticsService.instance.reload();
      expect(DiagnosticsService.instance.events, isEmpty);
    });
  });

  group('DiagEvent JSON', () {
    test('round-trip preserves every field, including details', () {
      final e = DiagEvent(
        at: DateTime.utc(2026, 5, 6, 12, 30),
        severity: DiagSeverity.warning,
        source: 'NotificationsService',
        message: 'Re-arm failed',
        details: 'TimeoutException after 5s\n#0  ...stack',
      );
      final back = DiagEvent.fromJson(e.toJson());
      expect(back.at, e.at);
      expect(back.severity, DiagSeverity.warning);
      expect(back.source, e.source);
      expect(back.message, e.message);
      expect(back.details, e.details);
    });

    test('fromJson tolerates a missing severity (defaults to info)', () {
      final back = DiagEvent.fromJson({
        'at': '2026-05-06T12:00:00Z',
        'source': 's',
        'message': 'm',
      });
      expect(back.severity, DiagSeverity.info);
      expect(back.details, isNull);
    });
  });
}
