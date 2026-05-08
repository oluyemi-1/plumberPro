import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/reminder_data.dart';

void main() {
  group('ServiceReminder predicates', () {
    final now = DateTime(2026, 5, 6, 12, 0); // fixed reference

    ServiceReminder make(DateTime due, {bool completed = false}) =>
        ServiceReminder(
          id: 'r-test',
          customerId: '',
          customerName: 'A',
          address: '',
          description: 'service',
          dueDate: due,
          createdAt: now,
          sourceJobId: null,
          templateId: null,
          completed: completed,
          completedAt: completed ? now : null,
        );

    test('isOverdue: due strictly before today', () {
      expect(make(DateTime(2026, 5, 5)).isOverdue(now: now), true);
      // Same calendar day is not overdue (it's due today).
      expect(make(DateTime(2026, 5, 6, 23, 59)).isOverdue(now: now), false);
      expect(make(DateTime(2026, 5, 7)).isOverdue(now: now), false);
    });

    test('isOverdue ignores completed reminders', () {
      expect(
        make(DateTime(2026, 5, 5), completed: true).isOverdue(now: now),
        false,
      );
    });

    test('isDueWithin matches if due before now+window', () {
      expect(
        make(DateTime(2026, 5, 10))
            .isDueWithin(const Duration(days: 30), now: now),
        true,
      );
      expect(
        make(DateTime(2026, 7, 1))
            .isDueWithin(const Duration(days: 30), now: now),
        false,
      );
    });

    test('isDueWithin ignores completed reminders', () {
      expect(
        make(DateTime(2026, 5, 10), completed: true)
            .isDueWithin(const Duration(days: 30), now: now),
        false,
      );
    });

    test('notificationId is stable for the same id', () {
      final a = make(DateTime(2026, 5, 10));
      final b = make(DateTime(2026, 12, 1));
      expect(a.notificationId, b.notificationId,
          reason: 'shared id ⇒ same slot');
      expect(a.notificationId, greaterThanOrEqualTo(2000),
          reason: 'must not collide with daily-reminder slot 1001');
    });
  });

  group('ServiceReminder JSON', () {
    test('round-trip preserves every field', () {
      final r = ServiceReminder(
        id: 'r-1',
        customerId: 'c-9',
        customerName: 'Mrs Smith',
        address: '12 Plumber Lane',
        description: 'Annual boiler service',
        dueDate: DateTime.utc(2027, 5, 6),
        createdAt: DateTime.utc(2026, 5, 6),
        sourceJobId: 'j-77',
        templateId: 'tpl-boiler-service',
        completed: false,
        completedAt: null,
      );
      final back = ServiceReminder.fromJson(r.toJson());
      expect(back.id, r.id);
      expect(back.customerId, r.customerId);
      expect(back.customerName, r.customerName);
      expect(back.address, r.address);
      expect(back.description, r.description);
      expect(back.dueDate, r.dueDate);
      expect(back.sourceJobId, r.sourceJobId);
      expect(back.templateId, r.templateId);
      expect(back.completed, false);
      expect(back.completedAt, isNull);
    });

    test('round-trip survives a completed reminder', () {
      final r = ServiceReminder(
        id: 'r-2',
        customerId: '',
        customerName: 'B',
        address: '',
        description: 'follow-up',
        dueDate: DateTime.utc(2027, 1, 1),
        createdAt: DateTime.utc(2026, 1, 1),
        sourceJobId: null,
        templateId: null,
        completed: true,
        completedAt: DateTime.utc(2026, 6, 1),
      );
      final back = ServiceReminder.fromJson(r.toJson());
      expect(back.completed, true);
      expect(back.completedAt, r.completedAt);
    });

    test('list encode/decode round-trip', () {
      final list = [
        ServiceReminder.create(
          customerId: '',
          customerName: 'A',
          address: '',
          description: 'X',
          dueDate: DateTime.utc(2027, 1, 1),
        ),
        ServiceReminder.create(
          customerId: '',
          customerName: 'B',
          address: '',
          description: 'Y',
          dueDate: DateTime.utc(2027, 2, 1),
        ),
      ];
      final back = decodeReminders(encodeReminders(list));
      expect(back.length, 2);
      expect(back[0].customerName, 'A');
      expect(back[1].dueDate, DateTime.utc(2027, 2, 1));
    });

    test('decode is null/corrupt-safe', () {
      expect(decodeReminders(null), isEmpty);
      expect(decodeReminders(''), isEmpty);
      expect(decodeReminders('not-valid'), isEmpty);
    });

    test('copyWith(clearCompleted: true) reopens a done reminder', () {
      final r = ServiceReminder(
        id: 'r-3',
        customerId: '',
        customerName: 'C',
        address: '',
        description: '',
        dueDate: DateTime.utc(2027, 1, 1),
        createdAt: DateTime.utc(2026, 1, 1),
        sourceJobId: null,
        templateId: null,
        completed: true,
        completedAt: DateTime.utc(2026, 1, 1),
      );
      final reopened = r.copyWith(clearCompleted: true);
      expect(reopened.completed, false);
      expect(reopened.completedAt, isNull);
    });
  });
}
