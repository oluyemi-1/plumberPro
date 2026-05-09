import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/job_log_data.dart';
import 'job_log_service.dart';

/// Options gathered from the user before export.
class PdfExportOptions {
  final String businessName;
  final String businessContact;
  final String invoiceNumber;
  final bool includeVat;
  final double vatRate;
  final bool includePhotos;

  /// PNG bytes captured from the signature canvas. When non-null, a sign-off
  /// block with the customer's printed name and a date is appended at the
  /// end of the document.
  final Uint8List? signatureBytes;
  final String? signerName;
  final DateTime? signedAt;

  const PdfExportOptions({
    required this.businessName,
    required this.businessContact,
    required this.invoiceNumber,
    required this.includeVat,
    required this.vatRate,
    required this.includePhotos,
    this.signatureBytes,
    this.signerName,
    this.signedAt,
  });

  bool get hasSignature => signatureBytes != null;
}

class JobPdfExport {
  /// Build the PDF document and trigger the system share/print sheet.
  static Future<void> exportAndShare({
    required Job job,
    required PdfExportOptions options,
  }) async {
    final bytes = await build(job: job, options: options);
    await Printing.sharePdf(
      bytes: bytes,
      filename: _safeFilename(job, options),
    );
  }

  /// Build the PDF and return its bytes — used by the system print preview.
  static Future<Uint8List> build({
    required Job job,
    required PdfExportOptions options,
  }) async {
    final doc = pw.Document(
      title: 'Job ${options.invoiceNumber.isEmpty ? job.id : options.invoiceNumber}',
      author: options.businessName.isEmpty
          ? 'PipeSmart'
          : options.businessName,
    );

    // Pre-load photo bytes (file -> memory).
    final photoImages = <_LoadedPhoto>[];
    if (options.includePhotos) {
      for (final p in job.photos) {
        try {
          final path = await JobLogService.instance.photoPath(p);
          final bytes = await File(path).readAsBytes();
          photoImages.add(_LoadedPhoto(
            photo: p,
            image: pw.MemoryImage(bytes),
          ));
        } catch (_) {/* skip a photo we can't read */}
      }
    }

    final now = DateTime.now();
    final dur = job.totalTime(now);
    final labour = job.labourCostAt(now);
    final materials = job.materialsCost;
    final subtotal = labour + materials;
    final vat = options.includeVat ? subtotal * options.vatRate : 0.0;
    final total = subtotal + vat;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => _header(options),
        footer: (ctx) => _footer(ctx),
        build: (ctx) => [
          _titleBar(job: job, options: options),
          pw.SizedBox(height: 14),
          _customerBlock(job),
          pw.SizedBox(height: 10),
          if (job.description.trim().isNotEmpty) ...[
            _sectionHeader('Job description'),
            pw.SizedBox(height: 4),
            pw.Text(job.description),
            pw.SizedBox(height: 10),
          ],
          _sectionHeader('Time on the job'),
          pw.SizedBox(height: 4),
          if (job.entries.isEmpty)
            pw.Text('No time entries recorded.',
                style: const pw.TextStyle(color: PdfColors.grey700))
          else
            _timeTable(job, now),
          pw.SizedBox(height: 10),
          _sectionHeader('Materials'),
          pw.SizedBox(height: 4),
          if (job.materials.isEmpty)
            pw.Text('No materials recorded.',
                style: const pw.TextStyle(color: PdfColors.grey700))
          else
            _materialsTable(job),
          pw.SizedBox(height: 10),
          _totalsBlock(
            job: job,
            now: now,
            options: options,
            labour: labour,
            materials: materials,
            subtotal: subtotal,
            vat: vat,
            total: total,
            duration: dur,
          ),
          if (job.notes.trim().isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _sectionHeader('Notes'),
            pw.SizedBox(height: 4),
            pw.Text(job.notes),
          ],
          if (photoImages.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            _sectionHeader('Photos'),
            pw.SizedBox(height: 6),
            _photosGrid(photoImages),
          ],
          if (options.hasSignature) ...[
            pw.SizedBox(height: 18),
            _signatureBlock(options),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _signatureBlock(PdfExportOptions o) {
    final img = pw.MemoryImage(o.signatureBytes!);
    final signed =
        o.signedAt == null ? '' : 'Signed ${_fmtDate(o.signedAt!)}';
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionHeader('Customer sign-off'),
          pw.SizedBox(height: 4),
          pw.Text(
            'I confirm the work described above was carried out to my satisfaction.',
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

  static String _safeFilename(Job job, PdfExportOptions o) {
    final ref = o.invoiceNumber.isEmpty ? job.id : o.invoiceNumber;
    final cleanCustomer = job.customer
        .replaceAll(RegExp(r'[^A-Za-z0-9 _-]+'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final base = cleanCustomer.isEmpty ? 'job' : cleanCustomer;
    return '${base}_$ref.pdf';
  }

  // ─── Layout helpers ──────────────────────────────────────────────

  static pw.Widget _header(PdfExportOptions o) {
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

  static pw.Widget _titleBar({
    required Job job,
    required PdfExportOptions options,
  }) {
    final ref = options.invoiceNumber.isEmpty
        ? job.id.substring(0, job.id.length.clamp(0, 12))
        : options.invoiceNumber;
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Job summary',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.SizedBox(height: 2),
            pw.Text(
              'Reference $ref · ${_fmtDate(job.createdAt)}',
              style: const pw.TextStyle(
                  color: PdfColors.grey700, fontSize: 11),
            ),
          ],
        ),
        _statusBadge(job.status),
      ],
    );
  }

  static pw.Widget _statusBadge(JobStatus s) {
    final c = s == JobStatus.completed
        ? const PdfColor.fromInt(0xFF0E7C42)
        : const PdfColor.fromInt(0xFF0F4C81);
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

  static pw.Widget _customerBlock(Job job) {
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
                pw.Text('Customer',
                    style: const pw.TextStyle(
                        color: PdfColors.grey700, fontSize: 9)),
                pw.SizedBox(height: 2),
                pw.Text(
                  job.customer.isEmpty ? 'Not recorded' : job.customer,
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                if (job.address.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(job.address),
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
              pw.Text(formatGbp(job.hourlyRateGbp),
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              if (job.completedAt != null)
                pw.Text('Completed ${_fmtDate(job.completedAt!)}',
                    style: const pw.TextStyle(
                        color: PdfColors.grey700, fontSize: 9)),
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

  static pw.Widget _timeTable(Job job, DateTime now) {
    return pw.TableHelper.fromTextArray(
      headers: const ['Date', 'Start', 'End', 'Hours'],
      data: [
        for (final e in job.entries)
          [
            _fmtDate(e.start),
            _fmtTime(e.start),
            e.isRunning ? 'running' : _fmtTime(e.end!),
            formatHours(e.durationAt(now)),
          ],
      ],
      headerStyle:
          pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      headerDecoration:
          const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: const {3: pw.Alignment.centerRight},
      cellStyle: const pw.TextStyle(fontSize: 10),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    );
  }

  static pw.Widget _materialsTable(Job job) {
    return pw.TableHelper.fromTextArray(
      headers: const ['Description', 'Qty', 'Unit price', 'Total'],
      data: [
        for (final m in job.materials)
          [
            m.description,
            m.quantity.toStringAsFixed(
                m.quantity == m.quantity.roundToDouble() ? 0 : 2),
            formatGbp(m.unitPriceGbp),
            formatGbp(m.totalGbp),
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
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    );
  }

  static pw.Widget _totalsBlock({
    required Job job,
    required DateTime now,
    required PdfExportOptions options,
    required double labour,
    required double materials,
    required double subtotal,
    required double vat,
    required double total,
    required Duration duration,
  }) {
    final rows = <pw.Widget>[
      _totalsRow(
          'Labour (${formatHours(duration)} h × ${formatGbp(job.hourlyRateGbp)}/h)',
          formatGbp(labour)),
      _totalsRow('Materials', formatGbp(materials)),
      pw.Divider(color: PdfColors.grey400, height: 8),
      _totalsRow('Subtotal', formatGbp(subtotal)),
      if (options.includeVat)
        _totalsRow(
            'VAT ${(options.vatRate * 100).toStringAsFixed(0)}%',
            formatGbp(vat)),
      pw.Divider(color: PdfColors.grey700, height: 8),
      _totalsRow('Total due', formatGbp(total), bold: true, big: true),
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

  static pw.Widget _photosGrid(List<_LoadedPhoto> photos) {
    final rows = <pw.Widget>[];
    for (var i = 0; i < photos.length; i += 2) {
      final left = photos[i];
      final right = (i + 1 < photos.length) ? photos[i + 1] : null;
      rows.add(pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _photoTile(left)),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: right == null
                ? pw.SizedBox()
                : _photoTile(right),
          ),
        ],
      ));
      rows.add(pw.SizedBox(height: 8));
    }
    return pw.Column(children: rows);
  }

  static pw.Widget _photoTile(_LoadedPhoto p) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.ClipRRect(
            horizontalRadius: 4,
            verticalRadius: 4,
            child: pw.Image(
              p.image,
              fit: pw.BoxFit.cover,
              height: 180,
              width: double.infinity,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _fmtDate(p.photo.takenAt),
            style: const pw.TextStyle(
                color: PdfColors.grey700, fontSize: 9),
          ),
          if (p.photo.caption.isNotEmpty)
            pw.Text(
              p.photo.caption,
              style: const pw.TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  static String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _LoadedPhoto {
  final JobPhoto photo;
  final pw.MemoryImage image;
  const _LoadedPhoto({required this.photo, required this.image});
}
