import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/expense_data.dart';
import '../data/job_log_data.dart';
import 'customer_service.dart';
import 'expense_service.dart';
import 'job_log_service.dart';

/// CSV (RFC 4180-flavoured) generation for expenses and jobs, plus a
/// share-out helper. Designed for end-of-tax-year hand-off to an accountant.
///
/// The pure formatters ([expensesCsv], [jobsCsv]) are deliberately
/// dependency-free so they can be unit-tested without a Flutter binding.
class CsvExport {
  /// Render every expense in [items] to a CSV string. [resolveCustomer]
  /// optionally turns a job id into a customer name so the accountant sees
  /// who an expense relates to without needing to open the app.
  static String expensesCsv(
    List<Expense> items, {
    String? Function(String jobId)? resolveCustomer,
  }) {
    final buf = StringBuffer();
    buf.writeln(_row(const [
      'Date',
      'Type',
      'Category',
      'Description',
      'Amount (GBP)',
      'Miles',
      'Mileage rate (GBP/mile)',
      'Linked job id',
      'Linked customer',
    ]));
    for (final e in items) {
      buf.writeln(_row([
        _formatDate(e.date),
        e.kind == ExpenseKind.mileage ? 'Mileage' : 'Expense',
        e.category,
        e.description,
        e.computedAmountGbp.toStringAsFixed(2),
        e.kind == ExpenseKind.mileage
            ? _formatNumber(e.miles)
            : '',
        e.kind == ExpenseKind.mileage
            ? e.mileageRateGbpPerMile.toStringAsFixed(2)
            : '',
        e.jobId ?? '',
        e.jobId == null ? '' : (resolveCustomer?.call(e.jobId!) ?? ''),
      ]));
    }
    return buf.toString();
  }

  /// Render every job in [items] to a CSV string. Hours, labour, materials
  /// and total are computed at [now] (defaults to `DateTime.now()`).
  static String jobsCsv(
    List<Job> items, {
    DateTime? now,
  }) {
    final whenNow = now ?? DateTime.now();
    final buf = StringBuffer();
    buf.writeln(_row(const [
      'Job id',
      'Created',
      'Completed',
      'Status',
      'Customer',
      'Address',
      'Description',
      'Hourly rate (GBP)',
      'Hours',
      'Labour (GBP)',
      'Materials (GBP)',
      'Total (GBP)',
    ]));
    for (final j in items) {
      final hours = j.totalTime(whenNow).inSeconds / 3600.0;
      buf.writeln(_row([
        j.id,
        _formatDate(j.createdAt),
        j.completedAt == null ? '' : _formatDate(j.completedAt!),
        j.status.label,
        j.customer,
        j.address,
        j.description,
        j.hourlyRateGbp.toStringAsFixed(2),
        hours.toStringAsFixed(2),
        j.labourCostAt(whenNow).toStringAsFixed(2),
        j.materialsCost.toStringAsFixed(2),
        j.totalCostAt(whenNow).toStringAsFixed(2),
      ]));
    }
    return buf.toString();
  }

  // ─── Sharing helpers (live services) ────────────────────────────

  /// Generate expenses + jobs CSVs for the given range and open the system
  /// share sheet with both attached. Pulls live data from the services.
  static Future<void> shareForRange({
    required DateTime? from,
    required DateTime? to,
    required String rangeSlug,
  }) async {
    final items = ExpenseService.instance.items.where((e) {
      if (from != null && e.date.isBefore(from)) return false;
      if (to != null && !e.date.isBefore(to)) return false;
      return true;
    }).toList();

    final jobs = JobLogService.instance.jobs.where((j) {
      final d = j.completedAt ?? j.createdAt;
      if (from != null && d.isBefore(from)) return false;
      if (to != null && !d.isBefore(to)) return false;
      return true;
    }).toList();

    final customers = {
      for (final c in CustomerService.instance.customers) c.id: c,
    };
    String? lookupCustomer(String jobId) {
      for (final j in JobLogService.instance.jobs) {
        if (j.id == jobId) {
          if (j.customerId.isNotEmpty &&
              customers[j.customerId] != null) {
            return customers[j.customerId]!.name;
          }
          return j.customer.isEmpty ? null : j.customer;
        }
      }
      return null;
    }

    final expensesCsvStr =
        expensesCsv(items, resolveCustomer: lookupCustomer);
    final jobsCsvStr = jobsCsv(jobs);

    final tmp = await getTemporaryDirectory();
    final expensesFile =
        File('${tmp.path}/pipesmart-expenses-$rangeSlug.csv');
    final jobsFile = File('${tmp.path}/pipesmart-jobs-$rangeSlug.csv');
    await expensesFile.writeAsString(expensesCsvStr, flush: true);
    await jobsFile.writeAsString(jobsCsvStr, flush: true);

    await Share.shareXFiles(
      [
        XFile(expensesFile.path,
            mimeType: 'text/csv', name: expensesFile.uri.pathSegments.last),
        XFile(jobsFile.path,
            mimeType: 'text/csv', name: jobsFile.uri.pathSegments.last),
      ],
      subject: 'PipeSmart CSV export — $rangeSlug',
      text: 'Expenses and jobs exported as CSV. Drop into your accounting '
          'tool or share with your accountant.',
    );
  }

  /// Same as [shareForRange] but only the expenses CSV.
  static Future<void> shareExpensesForRange({
    required DateTime? from,
    required DateTime? to,
    required String rangeSlug,
  }) async {
    final items = ExpenseService.instance.items.where((e) {
      if (from != null && e.date.isBefore(from)) return false;
      if (to != null && !e.date.isBefore(to)) return false;
      return true;
    }).toList();

    final customers = {
      for (final c in CustomerService.instance.customers) c.id: c,
    };
    String? lookupCustomer(String jobId) {
      for (final j in JobLogService.instance.jobs) {
        if (j.id == jobId) {
          if (j.customerId.isNotEmpty &&
              customers[j.customerId] != null) {
            return customers[j.customerId]!.name;
          }
          return j.customer.isEmpty ? null : j.customer;
        }
      }
      return null;
    }

    final csvStr = expensesCsv(items, resolveCustomer: lookupCustomer);
    final tmp = await getTemporaryDirectory();
    final file = File('${tmp.path}/pipesmart-expenses-$rangeSlug.csv');
    await file.writeAsString(csvStr, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv', name: file.uri.pathSegments.last)],
      subject: 'PipeSmart expenses — $rangeSlug',
      text: 'Expenses exported as CSV.',
    );
  }

  // ─── Internal CSV plumbing ──────────────────────────────────────

  /// Quote a single cell per RFC 4180. Empty strings stay empty (no quotes).
  /// Strings containing comma, double-quote, CR, LF or leading/trailing
  /// whitespace get wrapped; internal double-quotes are doubled.
  static String _escapeCell(Object? raw) {
    if (raw == null) return '';
    final s = raw.toString();
    if (s.isEmpty) return '';
    final needsQuoting = s.contains(',') ||
        s.contains('"') ||
        s.contains('\n') ||
        s.contains('\r') ||
        s.startsWith(' ') ||
        s.endsWith(' ');
    if (!needsQuoting) return s;
    final escaped = s.replaceAll('"', '""');
    return '"$escaped"';
  }

  static String _row(List<Object?> cells) =>
      cells.map(_escapeCell).join(',');

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _formatNumber(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
}
