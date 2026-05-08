import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/schema_safe.dart';
import 'package:plumbing_and_heating/services/diagnostics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A minimal item type the test uses to exercise the decoder. Lives only
/// in this file so the tests don't depend on any production model.
class _Tiny {
  final String id;
  final int n;
  _Tiny(this.id, this.n);
  factory _Tiny.fromJson(Map<String, dynamic> j) =>
      _Tiny(j['id'] as String, (j['n'] as num).toInt());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(const {});
    await DiagnosticsService.instance.reload();
  });

  group('SchemaSafe.decodeList — happy path', () {
    test('returns empty for null / empty input', () {
      expect(
        SchemaSafe.decodeList<_Tiny>(
          key: 'k',
          raw: null,
          fromJson: _Tiny.fromJson,
        ),
        isEmpty,
      );
      expect(
        SchemaSafe.decodeList<_Tiny>(
          key: 'k',
          raw: '',
          fromJson: _Tiny.fromJson,
        ),
        isEmpty,
      );
    });

    test('decodes a well-formed JSON array', () {
      final out = SchemaSafe.decodeList<_Tiny>(
        key: 'k',
        raw: '[{"id":"a","n":1},{"id":"b","n":2}]',
        fromJson: _Tiny.fromJson,
      );
      expect(out.length, 2);
      expect(out[0].id, 'a');
      expect(out[1].n, 2);
    });
  });

  group('SchemaSafe.decodeList — failure preserves the raw blob', () {
    test('garbage JSON: returns empty + writes corrupt-backup key', () async {
      const bad = 'this is not valid json';
      final out = SchemaSafe.decodeList<_Tiny>(
        key: 'jobs_v1',
        raw: bad,
        fromJson: _Tiny.fromJson,
      );
      expect(out, isEmpty);

      // Wait for the fire-and-forget save.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final keys = await SchemaSafe.listCorruptedBackupKeys('jobs_v1');
      expect(keys.length, 1, reason: 'one backup written');
      expect(keys.first, startsWith('jobs_v1_corrupt_'));

      // The original blob is recoverable from the backup.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(keys.first), bad);

      // And the failure was logged.
      expect(
        DiagnosticsService.instance.events
            .any((e) => e.source == 'SchemaSafe'),
        true,
      );
    });

    test('JSON object instead of array: empty + diagnostics + backup',
        () async {
      const bad = '{"id":"a","n":1}'; // object, not array
      final out = SchemaSafe.decodeList<_Tiny>(
        key: 'shape_test',
        raw: bad,
        fromJson: _Tiny.fromJson,
      );
      expect(out, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final keys =
          await SchemaSafe.listCorruptedBackupKeys('shape_test');
      expect(keys.length, 1);
    });

    test('list element with the wrong shape: empty + backup', () async {
      // `n` should be a num. Putting a string forces fromJson to throw.
      const bad = '[{"id":"a","n":"not-a-number"}]';
      final out = SchemaSafe.decodeList<_Tiny>(
        key: 'wrong_field',
        raw: bad,
        fromJson: _Tiny.fromJson,
      );
      expect(out, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final keys =
          await SchemaSafe.listCorruptedBackupKeys('wrong_field');
      expect(keys.length, 1);
    });

    test('two consecutive failures write two distinct backup keys',
        () async {
      SchemaSafe.decodeList<_Tiny>(
        key: 'bk',
        raw: 'garbage 1',
        fromJson: _Tiny.fromJson,
      );
      // Sleep enough that the millisecond-precision timestamp differs.
      await Future<void>.delayed(const Duration(milliseconds: 5));
      SchemaSafe.decodeList<_Tiny>(
        key: 'bk',
        raw: 'garbage 2',
        fromJson: _Tiny.fromJson,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final keys = await SchemaSafe.listCorruptedBackupKeys('bk');
      expect(keys.length, 2,
          reason: 'each failure should preserve its own blob');
    });
  });

  group('listCorruptedBackupKeys', () {
    test('returns empty when nothing has been backed up', () async {
      final keys =
          await SchemaSafe.listCorruptedBackupKeys('never_failed');
      expect(keys, isEmpty);
    });

    test('only matches keys for the requested prefix', () async {
      SchemaSafe.decodeList<_Tiny>(
        key: 'a',
        raw: 'bad',
        fromJson: _Tiny.fromJson,
      );
      SchemaSafe.decodeList<_Tiny>(
        key: 'b',
        raw: 'bad',
        fromJson: _Tiny.fromJson,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect((await SchemaSafe.listCorruptedBackupKeys('a')).length, 1);
      expect((await SchemaSafe.listCorruptedBackupKeys('b')).length, 1);
      expect((await SchemaSafe.listCorruptedBackupKeys('c')).length, 0);
    });
  });
}
