import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/customer_data.dart';
import 'package:plumbing_and_heating/data/data_search.dart';
import 'package:plumbing_and_heating/data/expense_data.dart';
import 'package:plumbing_and_heating/data/job_log_data.dart';
import 'package:plumbing_and_heating/data/quote_data.dart';
import 'package:plumbing_and_heating/data/reminder_data.dart';

/// Pure tests over the cross-service search aggregator. Constructs small
/// in-memory lists so failures are easy to localise.
void main() {
  Customer customer({
    String id = 'c1',
    String name = '',
    String address = '',
    String phone = '',
    String email = '',
    String notes = '',
  }) =>
      Customer(
        id: id,
        name: name,
        address: address,
        phone: phone,
        email: email,
        notes: notes,
        createdAt: DateTime.utc(2026, 1, 1),
      );

  Job job({
    String id = 'j1',
    String customerName = '',
    String address = '',
    String description = '',
    String notes = '',
  }) =>
      Job(
        id: id,
        customer: customerName,
        customerId: '',
        address: address,
        description: description,
        status: JobStatus.active,
        createdAt: DateTime.utc(2026, 1, 1),
        completedAt: null,
        hourlyRateGbp: 50,
        entries: const [],
        materials: const [],
        photos: const [],
        voiceNotes: const [],
        notes: notes,
      );

  Quote quote({
    String id = 'q1',
    String ref = 'Q-2026-001',
    String customer = '',
    String description = '',
    String notes = '',
  }) =>
      Quote(
        id: id,
        quoteRef: ref,
        customer: customer,
        customerId: '',
        address: '',
        description: description,
        estimatedHours: 0,
        hourlyRateGbp: 50,
        lines: const [],
        notes: notes,
        validForDays: 30,
        status: QuoteStatus.draft,
        createdAt: DateTime.utc(2026, 1, 1),
        sentAt: null,
        respondedAt: null,
        convertedJobId: null,
      );

  ServiceReminder reminder({
    String id = 'r1',
    String customerName = '',
    String description = '',
  }) =>
      ServiceReminder(
        id: id,
        customerId: '',
        customerName: customerName,
        address: '',
        description: description,
        dueDate: DateTime.utc(2027, 1, 1),
        createdAt: DateTime.utc(2026, 1, 1),
        sourceJobId: null,
        templateId: null,
        completed: false,
        completedAt: null,
      );

  Expense expense({
    String id = 'e1',
    String description = '',
    String category = 'Other',
  }) =>
      Expense(
        id: id,
        kind: ExpenseKind.expense,
        date: DateTime.utc(2026, 1, 1),
        category: category,
        description: description,
        amountGbp: 10,
        miles: 0,
        mileageRateGbpPerMile: 0,
        jobId: null,
      );

  group('searchUserData', () {
    test('empty query returns no results', () {
      final r = searchUserData(
        '',
        customers: [customer(name: 'Smith')],
        jobs: [job(customerName: 'Smith')],
        quotes: [quote(customer: 'Smith')],
        reminders: [reminder(customerName: 'Smith')],
        expenses: [expense(description: 'Smith')],
      );
      expect(r, isEmpty);
    });

    test('whitespace-only query returns no results', () {
      final r = searchUserData(
        '   ',
        customers: [customer(name: 'Smith')],
        jobs: const [],
        quotes: const [],
        reminders: const [],
        expenses: const [],
      );
      expect(r, isEmpty);
    });

    test('matches customer by name, address, phone, email, notes', () {
      final list = [
        customer(id: 'a', name: 'Alice'),
        customer(id: 'b', address: '5 Plumber Lane'),
        customer(id: 'c', phone: '07700900123'),
        customer(id: 'd', email: 'sam@example.com'),
        customer(id: 'e', notes: 'Side gate code 1234.'),
      ];
      for (final entry in {
        'alice': 'a',
        'plumber lane': 'b',
        '900123': 'c',
        'sam@example': 'd',
        'side gate': 'e',
      }.entries) {
        final r = searchUserData(
          entry.key,
          customers: list,
          jobs: const [],
          quotes: const [],
          reminders: const [],
          expenses: const [],
        );
        expect(r.length, 1, reason: 'no hit for "${entry.key}"');
        expect(r.first.id, entry.value);
        expect(r.first.type, DataMatchType.customer);
      }
    });

    test('matches job by customer, address, description, notes', () {
      final list = [
        job(id: 'a', customerName: 'Brown'),
        job(id: 'b', address: '7 Pipe Avenue'),
        job(id: 'c', description: 'Boiler service'),
        job(id: 'd', notes: 'Combustion analyser cal'),
      ];
      expect(
        searchUserData('brown',
            customers: const [],
            jobs: list,
            quotes: const [],
            reminders: const [],
            expenses: const [])
            .first
            .id,
        'a',
      );
      expect(
        searchUserData('pipe',
            customers: const [],
            jobs: list,
            quotes: const [],
            reminders: const [],
            expenses: const [])
            .first
            .id,
        'b',
      );
      expect(
        searchUserData('boiler',
            customers: const [],
            jobs: list,
            quotes: const [],
            reminders: const [],
            expenses: const [])
            .first
            .id,
        'c',
      );
      expect(
        searchUserData('combustion',
            customers: const [],
            jobs: list,
            quotes: const [],
            reminders: const [],
            expenses: const [])
            .first
            .id,
        'd',
      );
    });

    test('matches quote by ref, customer and description', () {
      final list = [
        quote(id: 'a', ref: 'Q-2026-451', customer: 'Smith'),
        quote(id: 'b', description: 'Power flush'),
      ];
      expect(
        searchUserData('q-2026-451',
                customers: const [],
                jobs: const [],
                quotes: list,
                reminders: const [],
                expenses: const [])
            .first
            .id,
        'a',
      );
      expect(
        searchUserData('flush',
                customers: const [],
                jobs: const [],
                quotes: list,
                reminders: const [],
                expenses: const [])
            .first
            .id,
        'b',
      );
    });

    test('matches reminder and expense', () {
      final r = searchUserData(
        'fuel',
        customers: const [],
        jobs: const [],
        quotes: const [],
        reminders: [
          reminder(id: 'rem-1', description: 'Annual fuel safety check'),
        ],
        expenses: [
          expense(id: 'exp-1', category: 'Fuel', description: 'BP refuel'),
        ],
      );
      // Both should match.
      expect(r.length, 2);
      expect(r.map((m) => m.type),
          containsAll([DataMatchType.reminder, DataMatchType.expense]));
    });

    test('case-insensitive', () {
      final r = searchUserData(
        'SMITH',
        customers: [customer(name: 'Mr Smith')],
        jobs: const [],
        quotes: const [],
        reminders: const [],
        expenses: const [],
      );
      expect(r.length, 1);
    });

    test('results are returned in customer → job → quote → reminder → expense order',
        () {
      final r = searchUserData(
        'a',
        customers: [customer(name: 'A-name')],
        jobs: [job(customerName: 'A-name')],
        quotes: [quote(customer: 'A-name')],
        reminders: [reminder(customerName: 'A-name')],
        expenses: [expense(description: 'a')],
      );
      expect(r.map((m) => m.type), [
        DataMatchType.customer,
        DataMatchType.job,
        DataMatchType.quote,
        DataMatchType.reminder,
        DataMatchType.expense,
      ]);
    });

    test('per-bucket cap limits very common queries', () {
      final manyCustomers = List<Customer>.generate(
        50,
        (i) => customer(id: 'c$i', name: 'Aaron $i'),
      );
      final r = searchUserData(
        'aaron',
        customers: manyCustomers,
        jobs: const [],
        quotes: const [],
        reminders: const [],
        expenses: const [],
        perBucketCap: 10,
      );
      expect(r.length, 10);
    });

    test('source field gives access to the original record', () {
      final c = customer(id: 'src-1', name: 'Source Test');
      final r = searchUserData(
        'source',
        customers: [c],
        jobs: const [],
        quotes: const [],
        reminders: const [],
        expenses: const [],
      );
      expect(r.first.source, same(c));
    });
  });

  group('DataMatchType.label', () {
    test('every enum value has a human-readable label', () {
      for (final t in DataMatchType.values) {
        expect(t.label, isNotEmpty);
      }
    });
  });
}
