import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/job_log_data.dart' show formatGbp, formatHours;
import '../data/quote_data.dart';

/// Options gathered from the user before exporting a quote PDF. Mirrors
/// `PdfExportOptions` for jobs, with a couple of quote-specific extras.
class QuotePdfOptions {
  final String businessName;
  final String businessContact;
  final bool includeVat;
  final double vatRate;

  /// Optional signature captured at quote acceptance — the customer signs
  /// to confirm they accept the price. Embedded at the end of the PDF.
  final Uint8List? signatureBytes;
  final String? signerName;
  final DateTime? signedAt;

  const QuotePdfOptions({
    required this.businessName,
    required this.businessContact,
    required this.includeVat,
    required this.vatRate,
    this.signatureBytes,
    this.signerName,
    this.signedAt,
  });

  bool get hasSignature => signatureBytes != null;
}

/// PDF builder for customer-facing quotes. Visually consistent with
/// `JobPdfExport` so a customer who has already received a job summary
/// recognises the same brand layout.
class QuotePdfExport {
  static Future<void> exportAndShare({
    required Quote quote,
    required QuotePdfOptions options,
  }) async {
    final bytes = await build(quote: quote, options: options);
    await Printing.sharePdf(
      bytes: bytes,
      filename: _safeFilename(quote),
    );
  }

  static Future<Uint8List> build({
    required Quote quote,
    required QuotePdfOptions options,
  }) async {
    final doc = pw.Document(
      title: 'Quote ${quote.quoteRef}',
      author: options.businessName.isEmpty
          ? 'PipeSmart'
          : options.businessName,
    );

    final subtotal = quote.subtotalGbp;
    final vat = options.includeVat ? subtotal * options.vatRate : 0.0;
    final total = subtotal + vat;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => _header(options),
        footer: (ctx) => _footer(ctx),
        build: (ctx) => [
          _titleBar(quote: quote),
          pw.SizedBox(height: 14),
          _customerBlock(quote),
          pw.SizedBox(height: 10),
          if (quote.description.trim().isNotEmpty) ...[
            _sectionHeader('Scope of work'),
            pw.SizedBox(height: 4),
            pw.Text(quote.description),
            pw.SizedBox(height: 10),
          ],
          _sectionHeader('Estimated labour'),
          pw.SizedBox(height: 4),
          _labourBlock(quote),
          pw.SizedBox(height: 10),
          _sectionHeader('Estimated materials'),
          pw.SizedBox(height: 4),
          if (quote.lines.isEmpty)
            pw.Text('No materials estimated.',
                style: const pw.TextStyle(color: PdfColors.grey700))
          else
            _linesTable(quote),
          pw.SizedBox(height: 10),
          _totalsBlock(
            quote: quote,
            options: options,
            subtotal: subtotal,
            vat: vat,
            total: total,
          ),
          if (quote.notes.trim().isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _sectionHeader('Notes'),
            pw.SizedBox(height: 4),
            pw.Text(quote.notes),
          ],
          pw.SizedBox(height: 14),
          _validityBlock(quote),
          if (options.hasSignature) ...[
            pw.SizedBox(height: 18),
            _signatureBlock(options),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static String _safeFilename(Quote q) {
    final cleanCustomer = q.customer
        .replaceAll(RegExp(r'[^A-Za-z0-9 _-]+'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final base = cleanCustomer.isEmpty ? 'quote' : cleanCustomer;
    return '${base}_${q.quoteRef}.pdf';
  }

  // ─── Layout helpers ──────────────────────────────────────────────

  static pw.Widget _header(QuotePdfOptions o) {
    final brand = o.businessName.isEmpty ? 'PipeSmart' : o.businessName;
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF0F4C81), width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(brand,
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF0F4C81),
              )),
          if (o.businessContact.isNotEmpty)
            pw.Text(o.businessContact,
                style: const pw.TextStyle(
                    color: PdfColors.grey700, fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context ctx) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Generated by PipeSmart',
              style: const pw.TextStyle(
                  color: PdfColors.grey600, fontSize: 9)),
          pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(
                  color: PdfColors.grey600, fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _titleBar({required Quote quote}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Quote',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.SizedBox(height: 2),
            pw.Text(
              'Reference ${quote.quoteRef} · ${_fmtDate(quote.createdAt)}',
              style: const pw.TextStyle(
                  color: PdfColors.grey700, fontSize: 11),
            ),
          ],
        ),
        _statusBadge(quote.status),
      ],
    );
  }

  static pw.Widget _statusBadge(QuoteStatus s) {
    PdfColor c;
    switch (s) {
      case QuoteStatus.draft:
        c = const PdfColor.fromInt(0xFF6B7280);
        break;
      case QuoteStatus.sent:
        c = const PdfColor.fromInt(0xFF0F4C81);
        break;
      case QuoteStatus.accepted:
        c = const PdfColor.fromInt(0xFF0E7C42);
        break;
      case QuoteStatus.rejected:
        c = const PdfColor.fromInt(0xFFB91C1C);
        break;
    }
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: PdfColor(c.red, c.green, c.blue, 0.12),
        borderRadius: pw.BorderRadius.circular(999),
      ),
      child: pw.Text(s.label,
          style: pw.TextStyle(
            color: c,
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          )),
    );
  }

  static pw.Widget _customerBlock(Quote q) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('For',
                    style: const pw.TextStyle(
                        color: PdfColors.grey700, fontSize: 9)),
                pw.SizedBox(height: 2),
                pw.Text(
                  q.customer.isEmpty ? 'Not recorded' : q.customer,
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                if (q.address.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(q.address),
                ],
              ],
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Hourly rate',
                  style: const pw.TextStyle(
                      color: PdfColors.grey700, fontSize: 9)),
              pw.SizedBox(height: 2),
              pw.Text(formatGbp(q.hourlyRateGbp),
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionHeader(String text) => pw.Text(
        text.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: pw.FontWeight.bold,
          color: const PdfColor.fromInt(0xFF0F4C81),
        ),
      );

  static pw.Widget _labourBlock(Quote q) {
    final hoursStr = q.estimatedHours == q.estimatedHours.roundToDouble()
        ? q.estimatedHours.toStringAsFixed(0)
        : q.estimatedHours.toStringAsFixed(1);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
            '$hoursStr hour${q.estimatedHours == 1 ? '' : 's'} estimated × ${formatGbp(q.hourlyRateGbp)}/h'),
        pw.Text(formatGbp(q.labourCost),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _linesTable(Quote q) {
    return pw.TableHelper.fromTextArray(
      headers: const ['Description', 'Qty', 'Unit price', 'Total'],
      data: [
        for (final l in q.lines)
          [
            l.description,
            l.quantity.toStringAsFixed(
                l.quantity == l.quantity.roundToDouble() ? 0 : 2),
            formatGbp(l.unitPriceGbp),
            formatGbp(l.totalGbp),
          ],
      ],
      headerStyle:
          pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      headerDecoration:
          const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: const {
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellPadding:
          const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    );
  }

  static pw.Widget _totalsBlock({
    required Quote quote,
    required QuotePdfOptions options,
    required double subtotal,
    required double vat,
    required double total,
  }) {
    final hoursStr =
        formatHours(Duration(seconds: (quote.estimatedHours * 3600).round()));
    final rows = <pw.Widget>[
      _totalsRow(
          'Labour ($hoursStr h × ${formatGbp(quote.hourlyRateGbp)}/h)',
          formatGbp(quote.labourCost)),
      _totalsRow('Materials', formatGbp(quote.materialsCost)),
      pw.Divider(color: PdfColors.grey400, height: 8),
      _totalsRow('Subtotal', formatGbp(subtotal)),
      if (options.includeVat)
        _totalsRow(
            'VAT ${(options.vatRate * 100).toStringAsFixed(0)}%',
            formatGbp(vat)),
      pw.Divider(color: PdfColors.grey700, height: 8),
      _totalsRow('Total estimate', formatGbp(total), bold: true, big: true),
    ];

    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.ConstrainedBox(
        constraints: const pw.BoxConstraints(maxWidth: 280),
        child: pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(children: rows),
        ),
      ),
    );
  }

  static pw.Widget _totalsRow(String label, String value,
      {bool bold = false, bool big = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                fontSize: big ? 13 : 11,
                fontWeight:
                    bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              )),
          pw.Text(value,
              style: pw.TextStyle(
                fontSize: big ? 14 : 11,
                fontWeight: pw.FontWeight.bold,
                color: big
                    ? const PdfColor.fromInt(0xFF0F4C81)
                    : PdfColors.black,
              )),
        ],
      ),
    );
  }

  static pw.Widget _validityBlock(Quote q) {
    final exp = q.expiresAt;
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            exp == null
                ? 'This estimate has no fixed expiry date.'
                : 'This estimate is valid until ${_fmtDate(exp)} (${q.validForDays} days from issue).',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Final cost may differ if scope changes on site or if hidden work is uncovered. Any variation will be agreed with you before extra work is carried out.',
            style: const pw.TextStyle(
                color: PdfColors.grey700, fontSize: 9),
          ),
        ],
      ),
    );
  }

  static pw.Widget _signatureBlock(QuotePdfOptions o) {
    final img = pw.MemoryImage(o.signatureBytes!);
    final signed =
        o.signedAt == null ? '' : 'Accepted ${_fmtDate(o.signedAt!)}';
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionHeader('Customer acceptance'),
          pw.SizedBox(height: 4),
          pw.Text(
            'I accept the estimate above. I understand that final cost may differ if the scope changes.',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            height: 90,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey700),
              ),
            ),
            child: pw.Image(img, fit: pw.BoxFit.contain),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Customer name',
                      style: const pw.TextStyle(
                          color: PdfColors.grey700, fontSize: 9)),
                  pw.Text(
                    (o.signerName == null || o.signerName!.isEmpty)
                        ? '—'
                        : o.signerName!,
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Text(signed,
                  style: const pw.TextStyle(
                      color: PdfColors.grey700, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
