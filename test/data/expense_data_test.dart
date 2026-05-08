import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/expense_data.dart';

void main() {
  group('Expense.computedAmountGbp', () {
    test('uses the stored amount for free-form expenses', () {
      final e = Expense(
        id: 'e1',
        kind: ExpenseKind.expense,
        date: DateTime.utc(2026, 5, 1),
        category: 'Fuel',
        description: 'BP',
        amountGbp: 67.50,
        miles: 0,
        mileageRateGbpPerMile: 0,
        jobId: null,
      );
      expect(e.computedAmountGbp, 67.50);
    });

    test('mileage entries derive from miles × rate, ignoring amountGbp', () {
      final e = Expense(
        id: 'e2',
        kind: ExpenseKind.mileage,
        date: DateTime.utc(2026, 5, 1),
        category: 'Mileage',
        description: 'To customer',
        amountGbp: 999.0, // should be ignored
        miles: 12,
        mileageRateGbpPerMile: 0.45,
        jobId: null,
      );
      expect(e.computedAmountGbp, closeTo(5.40, 1e-9));
    });
  });

  group('Expense JSON', () {
    test('round-trip preserves expense kind', () {
      final e = Expense(
        id: 'e3',
        kind: ExpenseKind.expense,
        date: DateTime.utc(2026, 5, 1),
        category: 'Tools & equipment',
        description: 'Crimper',
        amountGbp: 89.99,
        miles: 0,
        mileageRateGbpPerMile: 0,
        jobId: 'job-7',
      );
      final back = Expense.fromJson(e.toJson());
      expect(back.id, e.id);
      expect(back.kind, ExpenseKind.expense);
      expect(back.category, e.category);
      expect(back.amountGbp, e.amountGbp);
      expect(back.jobId, 'job-7');
    });

    test('round-trip preserves mileage kind', () {
      final e = Expense(
        id: 'e4',
        kind: ExpenseKind.mileage,
        date: DateTime.utc(2026, 5, 1),
        category: 'Mileage',
        description: '',
        amountGbp: 0,
        miles: 22.5,
        mileageRateGbpPerMile: 0.45,
        jobId: null,
      );
      final back = Expense.fromJson(e.toJson());
      expect(back.kind, ExpenseKind.mileage);
      expect(back.miles, 22.5);
      expect(back.mileageRateGbpPerMile, 0.45);
      expect(back.computedAmountGbp, closeTo(10.125, 1e-9));
    });

    test('fromJson tolerates missing fields', () {
      final back = Expense.fromJson({'id': 'ex'});
      expect(back.id, 'ex');
      expect(back.kind, ExpenseKind.expense); // default
      expect(back.amountGbp, 0);
      expect(back.miles, 0);
      expect(back.mileageRateGbpPerMile, 0.45); // HMRC default
      expect(back.category, 'Other');
    });

    test('list encode/decode round-trip', () {
      final list = [
        Expense(
          id: 'e1',
          kind: ExpenseKind.expense,
          date: DateTime.utc(2026, 5, 1),
          category: 'Fuel',
          description: 'BP',
          amountGbp: 50,
          miles: 0,
          mileageRateGbpPerMile: 0,
          jobId: null,
        ),
        Expense(
          id: 'e2',
          kind: ExpenseKind.mileage,
          date: DateTime.utc(2026, 5, 2),
          category: 'Mileage',
          description: '',
          amountGbp: 0,
          miles: 10,
          mileageRateGbpPerMile: 0.45,
          jobId: null,
        ),
      ];
      final back = decodeExpenses(encodeExpenses(list));
      expect(back.length, 2);
      expect(back[0].kind, ExpenseKind.expense);
      expect(back[1].kind, ExpenseKind.mileage);
    });

    test('decode is null/corrupt-safe', () {
      expect(decodeExpenses(null), isEmpty);
      expect(decodeExpenses(''), isEmpty);
      expect(decodeExpenses('not-json'), isEmpty);
    });
  });

  group('expenseCategories', () {
    test('exposes the canonical UK plumbing expense buckets', () {
      // UI dropdowns use these strings as keys — if any of these is renamed
      // existing expense records will keep showing the old category but new
      // entries will have the new one, fragmenting reports. Lock them in.
      expect(expenseCategories, contains('Fuel'));
      expect(expenseCategories, contains('Parts & materials'));
      expect(expenseCategories, contains('Tools & equipment'));
      expect(expenseCategories, contains('Other'));
    });
  });
}
