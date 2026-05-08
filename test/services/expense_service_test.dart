import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/expense_data.dart';
import 'package:plumbing_and_heating/services/expense_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Aggregation lives in ExpenseService — it's the single source of truth for
/// the dashboard, so the maths must be exact. These tests reset the
/// singleton between cases by clearing the SharedPreferences mock and
/// calling `reload()`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(const {});
    await ExpenseService.instance.reload();
  });

  Future<void> seed(List<Expense> items) async {
    for (final e in items) {
      await ExpenseService.instance.add(e);
    }
  }

  Expense expense({
    String? id,
    required DateTime date,
    String category = 'Fuel',
    double amount = 0,
    String? jobId,
  }) =>
      Expense(
        id: id ?? generateExpenseId(),
        kind: ExpenseKind.expense,
        date: date,
        category: category,
        description: '',
        amountGbp: amount,
        miles: 0,
        mileageRateGbpPerMile: 0,
        jobId: jobId,
      );

  Expense mileage({
    String? id,
    required DateTime date,
    required double miles,
    double rate = 0.45,
    String? jobId,
  }) =>
      Expense(
        id: id ?? generateExpenseId(),
        kind: ExpenseKind.mileage,
        date: date,
        category: 'Mileage',
        description: '',
        amountGbp: 0,
        miles: miles,
        mileageRateGbpPerMile: rate,
        jobId: jobId,
      );

  group('ExpenseService.totalIn', () {
    test('returns 0 when nothing is logged', () {
      expect(ExpenseService.instance.totalIn(), 0);
    });

    test('sums all items when no range is given', () async {
      await seed([
        expense(date: DateTime(2026, 1, 1), amount: 10),
        expense(date: DateTime(2026, 5, 1), amount: 20),
        mileage(date: DateTime(2026, 5, 6), miles: 10), // 4.50
      ]);
      expect(ExpenseService.instance.totalIn(), closeTo(34.50, 1e-9));
    });

    test('respects [from, to) bounds', () async {
      await seed([
        expense(date: DateTime(2026, 4, 30), amount: 5), // before
        expense(date: DateTime(2026, 5, 1), amount: 10), // inside
        expense(date: DateTime(2026, 5, 15), amount: 20), // inside
        expense(date: DateTime(2026, 6, 1), amount: 100), // boundary, excluded
      ]);
      final from = DateTime(2026, 5, 1);
      final to = DateTime(2026, 6, 1);
      expect(
        ExpenseService.instance.totalIn(from: from, to: to),
        closeTo(30, 1e-9),
      );
    });

    test('kind filter narrows to mileage only', () async {
      await seed([
        expense(date: DateTime(2026, 5, 1), amount: 50),
        mileage(date: DateTime(2026, 5, 2), miles: 10), // 4.50
        mileage(date: DateTime(2026, 5, 3), miles: 20), // 9.00
      ]);
      expect(
        ExpenseService.instance.totalIn(kind: ExpenseKind.mileage),
        closeTo(13.50, 1e-9),
      );
    });

    test('kind filter narrows to expenses only', () async {
      await seed([
        expense(date: DateTime(2026, 5, 1), amount: 50),
        mileage(date: DateTime(2026, 5, 2), miles: 100),
      ]);
      expect(
        ExpenseService.instance.totalIn(kind: ExpenseKind.expense),
        50,
      );
    });
  });

  group('ExpenseService.milesIn', () {
    test('returns 0 with no mileage entries', () async {
      await seed([expense(date: DateTime(2026, 5, 1), amount: 50)]);
      expect(ExpenseService.instance.milesIn(), 0);
    });

    test('sums miles from mileage entries only', () async {
      await seed([
        mileage(date: DateTime(2026, 5, 1), miles: 12.5),
        mileage(date: DateTime(2026, 5, 2), miles: 8),
        expense(date: DateTime(2026, 5, 1), amount: 999), // ignored
      ]);
      expect(ExpenseService.instance.milesIn(), closeTo(20.5, 1e-9));
    });

    test('respects date range', () async {
      await seed([
        mileage(date: DateTime(2026, 4, 30), miles: 5),
        mileage(date: DateTime(2026, 5, 1), miles: 10),
        mileage(date: DateTime(2026, 5, 31), miles: 7),
        mileage(date: DateTime(2026, 6, 1), miles: 100),
      ]);
      final from = DateTime(2026, 5, 1);
      final to = DateTime(2026, 6, 1);
      expect(
        ExpenseService.instance.milesIn(from: from, to: to),
        17,
      );
    });
  });

  group('ExpenseService.totalForJobs', () {
    test('returns 0 for an empty job-id set', () async {
      await seed([
        expense(
          id: 'x',
          date: DateTime(2026, 5, 1),
          amount: 50,
          jobId: 'job-1',
        ),
      ]);
      expect(ExpenseService.instance.totalForJobs(const []), 0);
    });

    test('sums expense and mileage costs across multiple jobs', () async {
      await seed([
        expense(
          date: DateTime(2026, 5, 1),
          amount: 50,
          jobId: 'job-1',
        ),
        mileage(
          date: DateTime(2026, 5, 2),
          miles: 10, // £4.50
          jobId: 'job-2',
        ),
        expense(
          date: DateTime(2026, 5, 3),
          amount: 100,
          jobId: 'job-3', // not in the set
        ),
        expense(
          date: DateTime(2026, 5, 4),
          amount: 999, // unlinked — must be ignored
        ),
      ]);
      final sum = ExpenseService.instance
          .totalForJobs(const {'job-1', 'job-2'});
      expect(sum, closeTo(54.50, 1e-9));
    });

    test('ignores expenses with no job link', () async {
      await seed([
        expense(date: DateTime(2026, 5, 1), amount: 200), // unlinked
        expense(
            date: DateTime(2026, 5, 1),
            amount: 50,
            jobId: 'job-x'),
      ]);
      expect(
        ExpenseService.instance.totalForJobs(const ['job-x']),
        50,
      );
    });
  });

  group('ExpenseService.forJob', () {
    test('returns only items linked to the given job', () async {
      await seed([
        expense(
          id: 'unlinked',
          date: DateTime(2026, 5, 1),
          amount: 1,
        ),
        expense(
          id: 'linked-a',
          date: DateTime(2026, 5, 2),
          amount: 2,
          jobId: 'job-1',
        ),
        expense(
          id: 'linked-b',
          date: DateTime(2026, 5, 3),
          amount: 3,
          jobId: 'job-1',
        ),
        expense(
          id: 'other-job',
          date: DateTime(2026, 5, 4),
          amount: 99,
          jobId: 'job-2',
        ),
      ]);
      final list = ExpenseService.instance.forJob('job-1');
      expect(list.length, 2);
      expect(list.map((e) => e.id), containsAll(['linked-a', 'linked-b']));
    });
  });

  group('ExpenseService persistence', () {
    test('items survive a reload', () async {
      await seed([
        expense(id: 'persist-test', date: DateTime(2026, 5, 1), amount: 42),
      ]);
      await ExpenseService.instance.reload();
      final ids = ExpenseService.instance.items.map((e) => e.id);
      expect(ids, contains('persist-test'));
    });

    test('mileage rate persists across reloads', () async {
      await ExpenseService.instance.setMileageRate(0.30);
      await ExpenseService.instance.reload();
      expect(ExpenseService.instance.mileageRate, 0.30);
    });

    test('mileage rate is clamped to a sane range', () async {
      await ExpenseService.instance.setMileageRate(99); // out of bounds
      expect(ExpenseService.instance.mileageRate, lessThanOrEqualTo(5.0));
      await ExpenseService.instance.setMileageRate(-1);
      expect(ExpenseService.instance.mileageRate, greaterThanOrEqualTo(0.0));
    });
  });
}
