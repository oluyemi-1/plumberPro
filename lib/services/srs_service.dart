import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simplified SuperMemo-2 (SM-2) spaced-repetition state for a single card.
class SrsCardState {
  final double easiness;
  final int interval; // days until next review
  final int reps;
  final DateTime? nextDue;

  const SrsCardState({
    required this.easiness,
    required this.interval,
    required this.reps,
    required this.nextDue,
  });

  static const SrsCardState fresh = SrsCardState(
    easiness: 2.5,
    interval: 0,
    reps: 0,
    nextDue: null,
  );

  bool get isNew => reps == 0 && nextDue == null;

  bool isDue(DateTime now) {
    if (nextDue == null) return true; // brand new
    return !nextDue!.isAfter(now);
  }

  Map<String, dynamic> toJson() => {
        'e': easiness,
        'i': interval,
        'r': reps,
        'd': nextDue?.toIso8601String(),
      };

  factory SrsCardState.fromJson(Map<String, dynamic> j) => SrsCardState(
        easiness: (j['e'] as num?)?.toDouble() ?? 2.5,
        interval: (j['i'] as int?) ?? 0,
        reps: (j['r'] as int?) ?? 0,
        nextDue: j['d'] == null ? null : DateTime.parse(j['d'] as String),
      );
}

/// User-facing rating buttons.
enum SrsRating { hard, got, easy }

/// SM-2 quality mapping. Real SM-2 uses 0..5; we map our three buttons to
/// values that produce a reasonable scheduling response.
int _quality(SrsRating r) {
  switch (r) {
    case SrsRating.hard:
      return 2;
    case SrsRating.got:
      return 4;
    case SrsRating.easy:
      return 5;
  }
}

/// Apply SM-2 update.
SrsCardState scheduleNext(
  SrsCardState s,
  SrsRating rating, {
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final q = _quality(rating);
  if (q < 3) {
    return SrsCardState(
      easiness: s.easiness, // unchanged on lapse
      interval: 1,
      reps: 0,
      nextDue: today.add(const Duration(days: 1)),
    );
  }
  final newReps = s.reps + 1;
  final newInterval = newReps == 1
      ? 1
      : newReps == 2
          ? 6
          : (s.interval * s.easiness).round().clamp(1, 365);
  // Easiness increment: classic SM-2 formula.
  final newEasiness =
      (s.easiness + 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
          .clamp(1.3, 3.0);
  return SrsCardState(
    easiness: newEasiness,
    interval: newInterval,
    reps: newReps,
    nextDue: today.add(Duration(days: newInterval)),
  );
}

/// Singleton manager for spaced-repetition card state. Cards are identified
/// by a stable string id (we use the lower-cased term name).
class SrsService extends ChangeNotifier {
  SrsService._();
  static final SrsService instance = SrsService._();

  static const _kCards = 'srs_cards_v1';
  final Map<String, SrsCardState> _cards = {};
  bool _loaded = false;

  bool get loaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCards);
    if (raw != null && raw.isNotEmpty) {
      try {
        final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
        for (final e in map.entries) {
          _cards[e.key] = SrsCardState.fromJson(
            (e.value as Map).cast<String, dynamic>(),
          );
        }
      } catch (_) {/* corrupted state — start fresh */}
    }
    _loaded = true;
    notifyListeners();
  }

  static String idFor(String term) =>
      term.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

  SrsCardState stateFor(String term) =>
      _cards[idFor(term)] ?? SrsCardState.fresh;

  /// Returns the cards currently due, in (due-soonest) order, plus up to
  /// [newAllowance] never-seen cards added at the end.
  List<String> dueAndNew(
    Iterable<String> allTerms, {
    int newAllowance = 6,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final due = <MapEntry<String, SrsCardState>>[];
    final neverSeen = <String>[];
    for (final t in allTerms) {
      final st = stateFor(t);
      if (st.isNew) {
        neverSeen.add(t);
      } else if (st.isDue(today)) {
        due.add(MapEntry(t, st));
      }
    }
    due.sort((a, b) {
      final an = a.value.nextDue ?? today;
      final bn = b.value.nextDue ?? today;
      return an.compareTo(bn);
    });
    return [
      ...due.map((e) => e.key),
      ...neverSeen.take(newAllowance),
    ];
  }

  int dueCount(Iterable<String> allTerms, {DateTime? now}) {
    final today = now ?? DateTime.now();
    var n = 0;
    for (final t in allTerms) {
      final st = stateFor(t);
      if (!st.isNew && st.isDue(today)) n++;
    }
    return n;
  }

  /// Records a rating and persists the new state.
  Future<void> record(String term, SrsRating rating) async {
    final id = idFor(term);
    final next = scheduleNext(stateFor(term), rating);
    _cards[id] = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCards, jsonEncode({
      for (final e in _cards.entries) e.key: e.value.toJson(),
    }));
    notifyListeners();
  }

  /// Stats for a snapshot of progress.
  ({int learned, int mastered, int neverSeen}) snapshot(
    Iterable<String> allTerms,
  ) {
    var learned = 0;
    var mastered = 0;
    var neverSeen = 0;
    for (final t in allTerms) {
      final st = stateFor(t);
      if (st.isNew) {
        neverSeen++;
      } else if (st.reps >= 3) {
        mastered++;
      } else {
        learned++;
      }
    }
    return (learned: learned, mastered: mastered, neverSeen: neverSeen);
  }

  /// Re-read all state from disk after a restore.
  Future<void> reload() async {
    _cards.clear();
    _loaded = false;
    await ensureLoaded();
  }

  Future<void> resetAll() async {
    _cards.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCards);
    notifyListeners();
  }
}
