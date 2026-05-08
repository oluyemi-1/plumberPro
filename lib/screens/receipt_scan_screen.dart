import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/expense_data.dart';
import '../data/receipt_parsing.dart';
import '../services/receipt_ocr.dart';
import '../theme.dart';
import 'edit_expense_screen.dart';

/// Pick a photo (camera or gallery), run on-device OCR over it, then open
/// the regular expense form pre-filled with whatever the parser pulled
/// out. The user always reviews before saving — heuristics are good but
/// not infallible.
class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  final _picker = ImagePicker();
  bool _busy = false;
  String? _error;
  String? _imagePath;
  ReceiptParseResult? _result;

  Future<void> _pickAndScan(ImageSource source) async {
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2400,
        imageQuality: 85,
      );
      if (picked == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }
      _imagePath = picked.path;
      final result = await ReceiptOcr.scan(picked.path);
      if (!mounted) return;
      setState(() {
        _result = result;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not scan that image: $e';
        _busy = false;
      });
    }
  }

  void _continueToExpense() {
    final r = _result ?? ReceiptParseResult.empty;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EditExpenseScreen(
          kind: ExpenseKind.expense,
          prefillDate: r.date,
          prefillAmount: r.amountGbp,
          prefillDescription: r.merchant,
          prefillCategory: r.suggestedCategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan receipt')),
      body: _busy
          ? const _BusyView()
          : _result == null
              ? _PickerView(
                  onCamera: () => _pickAndScan(ImageSource.camera),
                  onGallery: () => _pickAndScan(ImageSource.gallery),
                  error: _error,
                )
              : _ResultView(
                  imagePath: _imagePath,
                  result: _result!,
                  onAccept: _continueToExpense,
                  onRetry: () => setState(() {
                    _result = null;
                    _imagePath = null;
                  }),
                ),
    );
  }
}

class _BusyView extends StatelessWidget {
  const _BusyView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Reading the receipt…'),
        ],
      ),
    );
  }
}

class _PickerView extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final String? error;
  const _PickerView({
    required this.onCamera,
    required this.onGallery,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Card(
          color: AppColors.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.document_scanner,
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Scan a receipt',
                      style: Theme.of(context).textTheme.titleMedium),
                ]),
                const SizedBox(height: 6),
                const Text(
                  'Take a clear photo of the receipt — flat surface, even light, no glare. The app reads it on the device, pulls out the amount, date, supplier and category, and pre-fills the expense form. You always review before saving.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: onCamera,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Use camera'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onGallery,
          icon: const Icon(Icons.photo_library),
          label: const Text('Pick from gallery'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 16),
          Text(error!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 14),
        const Text(
          'Tip: works offline. The OCR model lives on your phone — receipts never leave the device.',
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  final String? imagePath;
  final ReceiptParseResult result;
  final VoidCallback onAccept;
  final VoidCallback onRetry;
  const _ResultView({
    required this.imagePath,
    required this.result,
    required this.onAccept,
    required this.onRetry,
  });

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final empty = !result.foundAnything;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        if (imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imagePath!),
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 14),
        if (empty)
          Card(
            color: Colors.redAccent.withValues(alpha: 0.08),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                  'Could not pull anything useful out of that image. Try a sharper shot, or tap Continue and fill the expense in manually.'),
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.auto_awesome,
                        color: AppColors.accent),
                    const SizedBox(width: 6),
                    Text('Detected',
                        style: Theme.of(context).textTheme.titleLarge),
                  ]),
                  const SizedBox(height: 6),
                  if (result.merchant != null)
                    _row(Icons.storefront, 'Supplier', result.merchant!),
                  if (result.amountGbp != null)
                    _row(Icons.payments, 'Amount',
                        '£${result.amountGbp!.toStringAsFixed(2)}'),
                  if (result.date != null)
                    _row(Icons.event, 'Date', _formatDate(result.date!)),
                  if (result.suggestedCategory != null)
                    _row(Icons.category, 'Suggested category',
                        result.suggestedCategory!),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: onAccept,
          icon: const Icon(Icons.check),
          label: Text(empty
              ? 'Continue without prefill'
              : 'Use these details'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.replay),
          label: const Text('Try a different photo'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Icon(icon, color: AppColors.muted, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ]),
      );
}
