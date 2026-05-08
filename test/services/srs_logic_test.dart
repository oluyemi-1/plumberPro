import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/services/srs_service.dart';

/// These tests cover the SM-2 scheduling math directly, so they don't need
/// Flutter binding or shared_preferences. They lock in:
/// - "Hard" lapses reset reps and re-show tomorrow.
/// - "Got" graduates 1 → 6 → interval × easiness.
/// - Easiness drifts upward on Easy and is capped at 1.3..3.0.
/// - Interval is bounded [1, 365] days.
void main() {
  final fixedNow = DateTime(2026, 5, 6);

  group('scheduleNext: Hard rating (lapse)', () {
    test('resets reps to 0 and schedules for tomorrow', () {
      const start = SrsCardState(
        easiness: 2.5,
        interval: 6,
        reps: 2,
        nextDue: null,
      );
      final next = scheduleNext(start, SrsRating.hard, now: fixedNow);
      expect(next.reps, 0);
      expect(next.interval, 1);
      expect(next.nextDue, fixedNow.add(const Duration(days: 1)));
    });

    test('does not change easiness on lapse', () {
      const start = SrsCardState(
        easiness: 2.34,
        interval: 6,
        reps: 2,
        nextDue: null,
      );
      final next = scheduleNext(start, SrsRating.hard, now: fixedNow);
      expect(next.easiness, 2.34);
    });
  });

  group('scheduleNext: Got rating (correct)', () {
    test('first review schedules for +1 day', () {
      final next = scheduleNext(SrsCardState.fresh, SrsRating.got,
          now: fixedNow);
      expect(next.reps, 1);
      expect(next.interval, 1);
      expect(next.nextDue, fixedNow.add(const Duration(days: 1)));
    });

    test('second review schedules for +6 days', () {
      const start = SrsCardState(
        easiness: 2.5,
        interval: 1,
        reps: 1,
        nextDue: null,
      );
      final next = scheduleNext(start, SrsRating.got, now: fixedNow);
      expect(next.reps, 2);
      expect(next.interval, 6);
      expect(next.nextDue, fixedNow.add(const Duration(days: 6)));
    });

    test('third+ review uses interval × easiness', () {
      const start = SrsCardState(
        easiness: 2.5,
        interval: 6,
        reps: 2,
        nextDue: null,
      );
      final next = scheduleNext(start, SrsRating.got, now: fixedNow);
      // 6 * 2.5 = 15 → rounded → 15
      expect(next.interval, 15);
      expect(next.reps, 3);
    });
  });

  group('scheduleNext: easiness bounds', () {
    test('easiness is capped at 3.0 on the upside', () {
      const start = SrsCardState(
        easiness: 3.0,
        interval: 30,
        reps: 5,
        nextDue: null,
      );
      final next = scheduleNext(start, SrsRating.easy, now: fixedNow);
      expect(next.easiness, lessThanOrEqualTo(3.0));
    });

    test('easiness floors at 1.3', () {
      // Got rating starting from minimum easiness — should not slip below.
      const start = SrsCardState(
        easiness: 1.3,
        interval: 1,
        reps: 1,
        nextDue: null,
      );
      final next = scheduleNext(start, SrsRating.got, now: fixedNow);
      expect(next.easiness, greaterThanOrEqualTo(1.3));
    });
  });

  group('scheduleNext: interval bounds', () {
    test('interval clamps at 365 days even after extreme growth', () {
      const start = SrsCardState(
        easiness: 3.0,
        interval: 200,
        reps: 10,
        nextDue: null,
      );
      final next = scheduleNext(start, SrsRating.got, now: fixedNow);
      expect(next.interval, lessThanOrEqualTo(365));
    });
  });

  group('SrsCardState.isDue', () {
    final now = DateTime(2026, 5, 6, 12);

    test('a brand-new card (no nextDue) is always due', () {
      expect(SrsCardState.fresh.isDue(now), true);
      expect(SrsCardState.fresh.isNew, true);
    });

    test('a card with nextDue in the past is due', () {
      const card = SrsCardState(
        easiness: 2.5,
        interval: 1,
        reps: 1,
        nextDue: null,
      );
      final dueYesterday = SrsCardState(
        easiness: card.easiness,
        interval: card.interval,
        reps: card.reps,
        nextDue: now.subtract(const Duration(hours: 5)),
      );
      expect(dueYesterday.isDue(now), true);
    });

    test('a card scheduled for the future is NOT due', () {
      final scheduled = SrsCardState(
        easiness: 2.5,
        interval: 6,
        reps: 2,
        nextDue: now.add(const Duration(days: 3)),
      );
      expect(scheduled.isDue(now), false);
    });
  });

  group('SrsCardState JSON', () {
    test('round-trip preserves every field', () {
      final s = SrsCardState(
        easiness: 2.34,
        interval: 6,
        reps: 2,
        nextDue: DateTime.utc(2026, 5, 12),
      );
      final back = SrsCardState.fromJson(s.toJson());
      expect(back.easiness, s.easiness);
      expect(back.interval, s.interval);
      expect(back.reps, s.reps);
      expect(back.nextDue, s.nextDue);
    });

    test('null nextDue survives the round-trip', () {
      final back = SrsCardState.fromJson(SrsCardState.fresh.toJson());
      expect(back.nextDue, isNull);
      expect(back.isNew, true);
    });
  });

  group('SrsService.idFor', () {
    test('lowercases and squashes whitespace', () {
      expect(SrsService.idFor('Annual Boiler Service'),
          'annual_boiler_service');
      expect(SrsService.idFor('  Trim  WhiteSpace  '),
          '_trim_whitespace_');
    });
  });
}
