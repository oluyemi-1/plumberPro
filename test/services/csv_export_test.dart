import 'package:flutter_test/flutter_test.dart';
import 'package:plumbing_and_heating/data/expense_data.dart';
import 'package:plumbing_and_heating/data/job_log_data.dart';
import 'package:plumbing_and_heating/services/csv_export.dart';

/// Tests over the pure CSV formatters. The share helpers (which write to
/// temp files and call the system share sheet) aren't tested here — they
/// require platform plumbing — but the row-level escaping and column
/// ordering must be locked down because accountants will load these into
/// Excel / Xero / FreeAgent and one bad escape ruins the whole row.
void main() {
  group('CsvExport.expensesCsv', () {
    test('emits a header row even when there are no items', () {
      final csv = CsvExport.expensesCsv(const []);
      final lines = csv.trim().split('\n');
      expect(lines.length, 1);
      expect(lines.first, startsWith('Date,Type,Category,Description'));
    });

    test('renders an expense row with date, category, amount', () {
      final csv = CsvExport.expensesCsv([
        Expense(
          id: 'e1',
          kind: ExpenseKind.expense,
          date: DateTime(2026, 5, 6),
          category: 'Fuel',
          description: 'BP refuel',
          amountGbp: 67.50,
          miles: 0,
          mileageRateGbpPerMile: 0,
          jobId: null,
        ),
      ]);
      final rows = csv.trim().split('\n');
      expect(rows.length, 2);
      // The data row in column order.
      expect(rows[1], contains('2026-05-06'));
      expect(rows[1], contains('Expense'));
      expect(rows[1], contains('Fuel'));
      expect(rows[1], contains('BP refuel'));
      expect(rows[1], contains('67.50'));
    });

    test('mileage rows expose miles and rate, expenses leave them blank', () {
      final csv = CsvExport.expensesCsv([
        Expense(
          id: 'e1',
          kind: ExpenseKind.mileage,
          date: DateTime(2026, 5, 6),
          category: 'Mileage',
          description: 'Surbiton round-trip',
          amountGbp: 0,
          miles: 12.5,
          mileageRateGbpPerMile: 0.45,
          jobId: null,
        ),
        Expense(
          id: 'e2',
          kind: ExpenseKind.expense,
          date: DateTime(2026, 5, 6),
          category: 'Fuel',
          description: 'BP',
          amountGbp: 50,
          miles: 0,
          mileageRateGbpPerMile: 0,
          jobId: null,
        ),
      ]);
      final rows = csv.trim().split('\n');
      // Mileage row shows miles + rate.
      expect(rows[1].split(',')[5], '12.50'); // miles column
      expect(rows[1].split(',')[6], '0.45');  // rate column
      // Expense row has empty mileage cells.
      final expenseCells = rows[2].split(',');
      expect(expenseCells[5], ''); // miles blank
      expect(expenseCells[6], ''); // rate blank
    });

    test('mileage amount column is computed (miles × rate), not the stored 0',
        () {
      final csv = CsvExport.expensesCsv([
        Expense(
          id: 'e1',
          kind: ExpenseKind.mileage,
          date: DateTime(2026, 5, 6),
          category: 'Mileage',
          description: '',
          amountGbp: 999, // should be ignored
          miles: 10,
          mileageRateGbpPerMile: 0.45,
          jobId: null,
        ),
      ]);
      final row = csv.trim().split('\n')[1];
      // amount cell is the 5th column (index 4).
      expect(row.split(',')[4], '4.50');
    });

    test('quotes fields containing commas, newlines and double-quotes', () {
      final csv = CsvExport.expensesCsv([
        Expense(
          id: 'e1',
          kind: ExpenseKind.expense,
          date: DateTime(2026, 5, 6),
          category: 'Other',
          description: 'Plumb Center, "Smith St", 20m\ncopper',
          amountGbp: 12.34,
          miles: 0,
          mileageRateGbpPerMile: 0,
          jobId: null,
        ),
      ]);
      // The description must be wrapped in double-quotes with embedded
      // quotes doubled, and the line must NOT have been split prematurely
      // by the comma or the embedded newline.
      expect(csv, contains('"Plumb Center, ""Smith St"", 20m\ncopper"'));
    });

    test('resolveCustomer maps job ids to customer names in the CSV', () {
      final csv = CsvExport.expensesCsv(
        [
          Expense(
            id: 'e1',
            kind: ExpenseKind.expense,
            date: DateTime(2026, 5, 6),
            category: 'Parts & materials',
            description: 'Inhibitor',
            amountGbp: 14,
            miles: 0,
            mileageRateGbpPerMile: 0,
            jobId: 'job-42',
          ),
        ],
        resolveCustomer: (id) => id == 'job-42' ? 'Mrs Brown' : null,
      );
      expect(csv, contains('Mrs Brown'));
      expect(csv, contains('job-42'));
    });

    test('unlinked expenses leave the customer column blank', () {
      final csv = CsvExport.expensesCsv(
        [
          Expense(
            id: 'e1',
            kind: ExpenseKind.expense,
            date: DateTime(2026, 5, 6),
            category: 'Other',
            description: '',
            amountGbp: 10,
            miles: 0,
            mileageRateGbpPerMile: 0,
            jobId: null,
          ),
        ],
        resolveCustomer: (_) => 'should not be called',
      );
      // Last column is the resolved customer; should be empty.
      final cells = csv.trim().split('\n')[1].split(',');
      expect(cells.last, '');
    });
  });

  group('CsvExport.jobsCsv', () {
    test('emits a header row when there are no jobs', () {
      final csv = CsvExport.jobsCsv(const []);
      expect(csv.trim().split('\n').length, 1);
      expect(csv, startsWith('Job id,Created,Completed,Status'));
    });

    test('a completed job rolls up labour, materials and total at "now"',
        () {
      final now = DateTime(2030, 1, 1);
      final job = Job(
        id: 'job-1',
        customer: 'Mrs Brown',
        customerId: '',
        address: '',
        description: 'Boiler service',
        status: JobStatus.completed,
        createdAt: DateTime(2026, 3, 1),
        completedAt: DateTime(2026, 3, 1, 12, 0),
        hourlyRateGbp: 60,
        entries: [
          TimeEntry(
            id: 'e1',
            start: DateTime(2026, 3, 1, 9, 0),
            end: DateTime(2026, 3, 1, 11, 0),
          ),
        ],
        materials: const [
          MaterialLine(
              id: 'm1',
              description: 'Seals',
              quantity: 1,
              unitPriceGbp: 8),
        ],
        photos: const [],
        voiceNotes: const [],
        notes: '',
      );
      final csv = CsvExport.jobsCsv([job], now: now);
      final row = csv.trim().split('\n')[1];
      final cells = row.split(',');
      expect(cells[0], 'job-1');
      expect(cells[1], '2026-03-01');
      expect(cells[2], '2026-03-01');
      expect(cells[3], 'Completed');
      expect(cells[4], 'Mrs Brown');
      expect(cells[7], '60.00');     // hourly rate
      expect(cells[8], '2.00');      // hours
      expect(cells[9], '120.00');    // labour
      expect(cells[10], '8.00');     // materials
      expect(cells[11], '128.00');   // total
    });

    test('an unfinished job leaves Completed blank but still totals time',
        () {
      final now = DateTime(2026, 3, 1, 11, 0);
      final job = Job(
        id: 'job-2',
        customer: 'A',
        customerId: '',
        address: '',
        description: '',
        status: JobStatus.active,
        createdAt: DateTime(2026, 3, 1),
        completedAt: null,
        hourlyRateGbp: 50,
        entries: [
          TimeEntry(
            id: 'e1',
            start: DateTime(2026, 3, 1, 10, 0),
            // running — durationAt(now) = 1h
          ),
        ],
        materials: const [],
        photos: const [],
        voiceNotes: const [],
        notes: '',
      );
      final csv = CsvExport.jobsCsv([job], now: now);
      final cells = csv.trim().split('\n')[1].split(',');
      expect(cells[2], ''); // Completed column blank
      expect(cells[3], 'Active');
      expect(cells[8], '1.00'); // hours
      expect(cells[9], '50.00'); // labour
    });

    test('quotes addresses and descriptions that contain commas', () {
      final job = Job(
        id: 'jx',
        customer: 'Smith, Mr',
        customerId: '',
        address: '12 High St, London',
        description: 'Boiler, pump, TRV',
        status: JobStatus.active,
        createdAt: DateTime(2026, 3, 1),
        completedAt: null,
        hourlyRateGbp: 50,
        entries: const [],
        materials: const [],
        photos: const [],
        voiceNotes: const [],
        notes: '',
      );
      final csv = CsvExport.jobsCsv([job], now: DateTime(2026, 3, 1));
      // All three commas-containing fields should be quoted, so the row
      // should still split into the expected number of columns when parsed
      // properly. Quick sanity check: each is wrapped.
      expect(csv, contains('"Smith, Mr"'));
      expect(csv, contains('"12 High St, London"'));
      expect(csv, contains('"Boiler, pump, TRV"'));
    });
  });
}
