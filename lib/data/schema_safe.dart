import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/diagnostics_service.dart';

/// Helper for decoding JSON blobs out of `shared_preferences` without
/// silently losing user data on a parse error.
///
/// The previous pattern in every `decodeXxx` function was:
/// ```dart
/// try { ... } catch (_) { return const []; }
/// ```
/// — which swallows the original raw blob, so if a single byte gets
/// corrupted (or a future-version blob is read by an older app build) the
/// user wakes up to an empty job log with no recovery path.
///
/// `SchemaSafe.decodeList` instead:
///   - Tries the supplied decoder.
///   - On any exception, **preserves the raw blob** under a timestamped
///     `<key>_corrupt_<ms>` prefs key (so the user / a future migration
///     pass can recover it).
///   - Logs the failure to [DiagnosticsService] with the source key + the
///     stack trace.
///   - Returns the empty-list fallback (same shape as before, so callers
///     don't change behaviour for the common case).
class SchemaSafe {
  /// Decode a JSON-encoded list from prefs. [key] is the prefs key the
  /// blob lives under — used for the corrupted-backup name and for the
  /// diagnostics line so failures are easy to correlate.
  static List<T> decodeList<T>({
    required String key,
    required String? raw,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw FormatException('Expected JSON array, got ${decoded.runtimeType}');
      }
      final out = <T>[];
      for (final entry in decoded) {
        if (entry is! Map) {
          throw FormatException(
              'Expected object in list, got ${entry.runtimeType}');
        }
        out.add(fromJson(entry.cast<String, dynamic>()));
      }
      return out;
    } catch (e, st) {
      _preserve(key, raw);
      DiagnosticsService.instance.error(
        'SchemaSafe',
        'Could not decode "$key" — raw blob preserved under a timestamped backup key.',
        '$e\n$st',
      );
      return const [];
    }
  }

  /// Stash the unparseable blob so a recovery script (or a manual
  /// inspection in Diagnostics) can get it back. Fire-and-forget — if
  /// the preserve fails too we just log it; we don't recurse into another
  /// SchemaSafe call.
  static Future<void> _preserve(String key, String raw) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString('${key}_corrupt_$stamp', raw);
    } catch (e) {
      if (kDebugMode) debugPrint('SchemaSafe preserve failed: $e');
    }
  }

  /// Returns every prefs key starting with `<key>_corrupt_` — useful for
  /// the Diagnostics screen to surface that *something* went wrong and
  /// the user has a recoverable backup hiding in prefs.
  static Future<List<String>> listCorruptedBackupKeys(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getKeys()
        .where((k) => k.startsWith('${key}_corrupt_'))
        .toList()
      ..sort();
  }
}
