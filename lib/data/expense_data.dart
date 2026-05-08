import 'dart:convert';
import 'dart:math' as math;

import 'schema_safe.dart';

/// Distinguishes a free-form expense (fuel receipt, tool purchase, etc.) from
/// a mileage entry, where the amount is derived from miles × rate.
enum ExpenseKind { expense, mileage }

ExpenseKind _decodeKind(String? raw) {
  for (final k in ExpenseKind.values) {
    if (k.name == raw) return k;
  }
  return ExpenseKind.expense;
}

/// Categories used for general expenses. Mileage entries always use the
/// dedicated "Mileage" category, so we don't list it here.
const expenseCategories = <String>[
  'Fuel',
  'Parts & materials',
  'Tools & equipment',
  'Vehicle (MOT, service, parking)',
  'Phone & data',
  'Insurance & subscriptions',
  'Training & qualifications',
  'Other',
];

/// A single business expense — either a money outlay (with explicit amount)
/// or a mileage trip (where the amount = miles × rate). Both are kept in one
/// list so the user sees them in chronological order on a single screen.
class Expense {
  final String id;
  final ExpenseKind kind;
  final DateTime date;
  final String category;
  final String description;

  /// Direct amount for `ExpenseKind.expense`. Ignored for mileage — use
  /// [computedAmountGbp] to get the right number for either kind.
  final double amountGbp;

  /// Mileage only.
  final double miles;
  final double mileageRateGbpPerMile;

  /// Optional link to a job in the JobLogService — lets the user see all
  /// expenses tied to a specific call-out.
  final String? jobId;

  const Expense({
    required this.id,
    required this.kind,
    required this.date,
    required this.category,
    required this.description,
    required this.amountGbp,
    required this.miles,
    required this.mileageRateGbpPerMile,
    required this.jobId,
  });

  /// Resolved cost in £ — derived for mileage, otherwise the stored amount.
  double get computedAmountGbp =>
      kind == ExpenseKind.mileage ? miles * mileageRateGbpPerMile : amountGbp;

  Expense copyWith({
    DateTime? date,
    String? category,
    String? description,
    double? amountGbp,
    double? miles,
    double? mileageRateGbpPerMile,
    String? jobId,
    bool clearJob = false,
  }) =>
      Expense(
        id: id,
        kind: kind,
        date: date ?? this.date,
        category: category ?? this.category,
        description: description ?? this.description,
        amountGbp: amountGbp ?? this.amountGbp,
        miles: miles ?? this.miles,
        mileageRateGbpPerMile:
            mileageRateGbpPerMile ?? this.mileageRateGbpPerMile,
        jobId: clearJob ? null : (jobId ?? this.jobId),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'date': date.toIso8601String(),
        'category': category,
        'description': description,
        'amount': amountGbp,
        'miles': miles,
        'rate': mileageRateGbpPerMile,
        'jobId': jobId,
      };

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String,
        kind: _decodeKind(j['kind'] as String?),
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        category: j['category'] as String? ?? 'Other',
        description: j['description'] as String? ?? '',
        amountGbp: (j['amount'] as num?)?.toDouble() ?? 0,
        miles: (j['miles'] as num?)?.toDouble() ?? 0,
        mileageRateGbpPerMile: (j['rate'] as num?)?.toDouble() ?? 0.45,
        jobId: j['jobId'] as String?,
      );
}

String generateExpenseId() {
  final ts = DateTime.now().millisecondsSinceEpoch;
  final r = math.Random().nextInt(1 << 32);
  return 'x-$ts-${r.toRadixString(36)}';
}

String encodeExpenses(List<Expense> list) =>
    jsonEncode(list.map((e) => e.toJson()).toList());

List<Expense> decodeExpenses(String? raw) =>
    SchemaSafe.decodeList<Expense>(
      key: 'expenses_v1',
      raw: raw,
      fromJson: Expense.fromJson,
    );
