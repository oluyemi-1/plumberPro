import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../data/receipt_parsing.dart';
import 'diagnostics_service.dart';

/// Thin wrapper around `google_mlkit_text_recognition` plus the pure
/// `parseReceiptText` heuristics. On-device, free, works offline. Adds
/// ~20 MB to the APK from the bundled ML model — accepted in exchange for
/// no API costs and no user-key management.
class ReceiptOcr {
  /// Run OCR on the image at [imagePath] and return the parsed amount /
  /// date / merchant / category guess. Returns [ReceiptParseResult.empty]
  /// on failure (every error path is logged via DiagnosticsService).
  static Future<ReceiptParseResult> scan(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final RecognizedText recognized =
          await recognizer.processImage(inputImage);
      return parseReceiptText(recognized.text);
    } catch (e, st) {
      DiagnosticsService.instance.error(
        'ReceiptOcr',
        'Text recognition failed for $imagePath.',
        '$e\n$st',
      );
      return ReceiptParseResult.empty;
    } finally {
      try {
        await recognizer.close();
      } catch (e) {
        if (kDebugMode) debugPrint('Recognizer close failed: $e');
      }
    }
  }
}
