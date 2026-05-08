import 'customer_data.dart';
import 'expense_data.dart';
import 'job_log_data.dart';
import 'quote_data.dart';
import 'reminder_data.dart';

/// Possible types of a user-data search hit. Used by the UI to colour the
/// result tile and pick the right detail-screen builder when tapped.
enum DataMatchType { customer, job, quote, reminder, expense }

extension DataMatchTypeX on DataMatchType {
  String get label {
    switch (this) {
      case DataMatchType.customer:
        return 'Customer';
      case DataMatchType.job:
        return 'Job';
      case DataMatchType.quote:
        return 'Quote';
      case DataMatchType.reminder:
        return 'Reminder';
      case DataMatchType.expense:
        return 'Expense';
    }
  }
}

/// A single match in the user's own data (jobs / customers / quotes /
/// reminders / expenses). Pure data — the UI layer turns this into a tile.
class DataMatch {
  final DataMatchType type;
  final String id;
  final String title;
  final String subtitle;

  /// The original record, in case the caller wants more than the
  /// pre-formatted title/subtitle (used to navigate to the right detail
  /// screen by type-checking).
  final Object source;

  const DataMatch({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.source,
  });
}

/// Pure search across the user's own records. Returns matches in a stable
/// order (customers → jobs → quotes → reminders → expenses) and caps each
/// bucket so a sweeping single-letter query doesn't produce thousands of
/// rows.
///
/// Designed to be tested in isolation — pass the data lists directly
/// rather than reaching into singletons.
List<DataMatch> searchUserData(
  String query, {
  required List<Customer> customers,
  required List<Job> jobs,
  required List<Quote> quotes,
  required List<ServiceReminder> reminders,
  required List<Expense> expenses,
  int perBucketCap = 25,
}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];

  final results = <DataMatch>[];

  bool hit(String? s) => s != null && s.toLowerCase().contains(q);

  for (final c in customers) {
    if (results.where((r) => r.type == DataMatchType.customer).length >=
        perBucketCap) {
      break;
    }
    if (hit(c.name) ||
        hit(c.address) ||
        hit(c.phone) ||
        hit(c.email) ||
        hit(c.notes)) {
      results.add(DataMatch(
        type: DataMatchType.customer,
        id: c.id,
        title: c.name.isEmpty ? 'Unnamed customer' : c.name,
        subtitle:
            [c.address, c.phone, c.email].where((s) => s.isNotEmpty).join(' · '),
        source: c,
      ));
    }
  }

  for (final j in jobs) {
    if (results.where((r) => r.type == DataMatchType.job).length >=
        perBucketCap) {
      break;
    }
    if (hit(j.customer) ||
        hit(j.address) ||
        hit(j.description) ||
        hit(j.notes)) {
      final money = j.totalCostAt(DateTime.now());
      results.add(DataMatch(
        type: DataMatchType.job,
        id: j.id,
        title: j.customer.isEmpty ? 'Untitled job' : j.customer,
        subtitle: [
          if (j.description.isNotEmpty) j.description,
          j.status.label,
          '£${money.toStringAsFixed(2)}',
        ].join(' · '),
        source: j,
      ));
    }
  }

  for (final q2 in quotes) {
    if (results.where((r) => r.type == DataMatchType.quote).length >=
        perBucketCap) {
      break;
    }
    if (hit(q2.customer) ||
        hit(q2.address) ||
        hit(q2.description) ||
        hit(q2.notes) ||
        hit(q2.quoteRef)) {
      results.add(DataMatch(
        type: DataMatchType.quote,
        id: q2.id,
        title: '${q2.quoteRef} · ${q2.customer.isEmpty ? 'Untitled' : q2.customer}',
        subtitle: [
          q2.status.label,
          if (q2.description.isNotEmpty) q2.description,
          '£${q2.subtotalGbp.toStringAsFixed(2)}',
        ].join(' · '),
        source: q2,
      ));
    }
  }

  for (final r in reminders) {
    if (results.where((x) => x.type == DataMatchType.reminder).length >=
        perBucketCap) {
      break;
    }
    if (hit(r.customerName) ||
        hit(r.address) ||
        hit(r.description)) {
      results.add(DataMatch(
        type: DataMatchType.reminder,
        id: r.id,
        title: r.customerName.isEmpty ? 'Untitled' : r.customerName,
        subtitle: [
          r.completed ? 'Done' : (r.isOverdue() ? 'Overdue' : 'Open'),
          if (r.description.isNotEmpty) r.description,
        ].join(' · '),
        source: r,
      ));
    }
  }

  for (final e in expenses) {
    if (results.where((r) => r.type == DataMatchType.expense).length >=
        perBucketCap) {
      break;
    }
    if (hit(e.description) || hit(e.category)) {
      results.add(DataMatch(
        type: DataMatchType.expense,
        id: e.id,
        title: e.description.isEmpty ? e.category : e.description,
        subtitle: [
          e.kind == ExpenseKind.mileage ? 'Mileage' : e.category,
          '£${e.computedAmountGbp.toStringAsFixed(2)}',
        ].join(' · '),
        source: e,
      ));
    }
  }

  return results;
}
