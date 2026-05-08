import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DiagSeverity { info, warning, error }

DiagSeverity _decodeSeverity(String? raw) {
  for (final s in DiagSeverity.values) {
    if (s.name == raw) return s;
  }
  return DiagSeverity.info;
}

/// One entry in the diagnostics log. `source` is a short string identifying
/// the subsystem (e.g. `NotificationsService`, `BackupService`) so the user
/// — or whoever's debugging a field issue — can scan the log quickly.
class DiagEvent {
  final DateTime at;
  final DiagSeverity severity;
  final String source;
  final String message;
  final String? details;

  const DiagEvent({
    required this.at,
    required this.severity,
    required this.source,
    required this.message,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
        'at': at.toIso8601String(),
        'severity': severity.name,
        'source': source,
        'message': message,
        'details': details,
      };

  factory DiagEvent.fromJson(Map<String, dynamic> j) => DiagEvent(
        at: DateTime.tryParse(j['at'] as String? ?? '') ?? DateTime.now(),
        severity: _decodeSeverity(j['severity'] as String?),
        source: j['source'] as String? ?? '?',
        message: j['message'] as String? ?? '',
        details: j['details'] as String?,
      );
}

/// In-app diagnostics log so silent failures (notification scheduling,
/// photo IO, JSON decode, backup zip) surface somewhere visible. Persists
/// across launches but caps at [maxEvents] so the prefs blob stays small.
///
/// **Local-only.** Not included in backup/restore — the log is debug-of-the-
/// moment, and exporting it would just bloat the backup zip.
class DiagnosticsService extends ChangeNotifier {
  DiagnosticsService._();
  static final DiagnosticsService instance = DiagnosticsService._();

  static const _kKey = 'diag_log_v1';
  static const int maxEvents = 200;

  final List<DiagEvent> _events = [];
  bool _loaded = false;

  /// Newest first.
  List<DiagEvent> get events => List.unmodifiable(_events);
  bool get loaded => _loaded;

  int get errorCount =>
      _events.where((e) => e.severity == DiagSeverity.error).length;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        _events.addAll(list.map(DiagEvent.fromJson));
      } catch (_) {
        // Corrupt log — start clean rather than crash the whole app.
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _events.clear();
    _loaded = false;
    await ensureLoaded();
  }

  void info(String source, String message, [String? details]) =>
      _add(DiagSeverity.info, source, message, details);

  void warning(String source, String message, [String? details]) =>
      _add(DiagSeverity.warning, source, message, details);

  void error(String source, String message, [String? details]) =>
      _add(DiagSeverity.error, source, message, details);

  void _add(
    DiagSeverity severity,
    String source,
    String message,
    String? details,
  ) {
    _events.insert(
      0,
      DiagEvent(
        at: DateTime.now(),
        severity: severity,
        source: source,
        message: message,
        details: details,
      ),
    );
    if (_events.length > maxEvents) {
      _events.removeRange(maxEvents, _events.length);
    }
    // Echo to debug console so you also see it during local dev.
    if (kDebugMode) {
      debugPrint('[$severity] $source: $message${details == null ? '' : '\n$details'}');
    }
    // Fire-and-forget save — log writes shouldn't block the call site.
    _save();
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _kKey,
        jsonEncode(_events.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      // Don't recurse — if persisting the log itself fails, we just lose it
      // on the next launch. Better than an infinite loop.
      if (kDebugMode) debugPrint('DiagnosticsService save failed: $e');
    }
  }

  Future<void> clear() async {
    _events.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
    notifyListeners();
  }
}
