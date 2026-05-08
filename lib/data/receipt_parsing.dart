/// Pure UK-receipt text parser. The OCR step (ML Kit) lives in a service
/// that depends on Flutter; this file is dependency-free so the heuristics
/// can be unit-tested against canned receipt text without a Flutter
/// binding.
///
/// What we try to extract from raw OCR text:
/// - Total amount (looks for "TOTAL", "AMOUNT DUE", "BALANCE DUE", "TO PAY";
///   falls back to the largest £-prefixed number anywhere on the receipt).
/// - Date (UK formats: dd/mm/yyyy, dd-mm-yyyy, dd MMM yyyy; year may be 2 or
///   4 digits).
/// - Merchant (first non-empty line near the top, cleaned up).
/// - Suggested expense category (matched against known UK trade-supplier
///   and fuel-station keywords).
class ReceiptParseResult {
  final String rawText;
  final double? amountGbp;
  final DateTime? date;
  final String? merchant;

  /// Best-guess category — must match one of the values in
  /// `expenseCategories` from `expense_data.dart` so the edit-expense
  /// dropdown can pre-select it.
  final String? suggestedCategory;

  const ReceiptParseResult({
    required this.rawText,
    required this.amountGbp,
    required this.date,
    required this.merchant,
    required this.suggestedCategory,
  });

  bool get foundAnything =>
      amountGbp != null ||
      date != null ||
      merchant != null ||
      suggestedCategory != null;

  static const empty = ReceiptParseResult(
    rawText: '',
    amountGbp: null,
    date: null,
    merchant: null,
    suggestedCategory: null,
  );
}

ReceiptParseResult parseReceiptText(String rawText) {
  if (rawText.trim().isEmpty) {
    return ReceiptParseResult.empty;
  }
  final lines = rawText
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  return ReceiptParseResult(
    rawText: rawText,
    amountGbp: _parseAmount(lines),
    date: _parseDate(lines),
    merchant: _parseMerchant(lines),
    suggestedCategory: _guessCategory(rawText),
  );
}

// ─── Amount ───────────────────────────────────────────────────────

/// Returns the most plausible "total" amount on the receipt. Strategy:
///   1. Prefer the number on a line containing TOTAL / AMOUNT DUE /
///      BALANCE DUE / TO PAY (excluding "SUB TOTAL" and "SUBTOTAL").
///   2. If none of those match, fall back to the largest £-prefixed
///      number anywhere in the text.
double? _parseAmount(List<String> lines) {
  // The number on the line itself, captured as a tight pattern. Matches
  // 12.34, 1,234.56, etc. Negative not allowed (refunds are a nice-to-have).
  final amountRegex = RegExp(r'(\d{1,3}(?:,\d{3})*\.\d{2})');

  double? best;
  // Pass 1: lines that name the total. Latest wins, since receipts often
  // print "subtotal ... vat ... total" in that order.
  final totalKeyword = RegExp(
    r'(?:^|\b)(total|amount\s*due|balance\s*due|to\s*pay|grand\s*total)\b',
    caseSensitive: false,
  );
  final subtotalKeyword =
      RegExp(r'sub[\s-]*total', caseSensitive: false);
  for (final line in lines) {
    if (subtotalKeyword.hasMatch(line)) continue; // exclude
    if (!totalKeyword.hasMatch(line)) continue;
    final m = amountRegex.firstMatch(line);
    if (m == null) continue;
    final v = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (v != null) best = v;
  }
  if (best != null) return best;

  // Pass 2: largest £-prefixed number. The £ symbol is inconsistent
  // through OCR, so accept "GBP" or "£" before a number. Very small
  // numbers (e.g. VAT line of £0.20) get filtered by picking the max.
  final poundRegex = RegExp(
    r'(?:£|gbp\s*)(\d{1,3}(?:,\d{3})*\.\d{2})',
    caseSensitive: false,
  );
  double? max;
  for (final line in lines) {
    for (final m in poundRegex.allMatches(line)) {
      final v = double.tryParse(m.group(1)!.replaceAll(',', ''));
      if (v == null) continue;
      if (max == null || v > max) max = v;
    }
  }
  return max;
}

// ─── Date ─────────────────────────────────────────────────────────

DateTime? _parseDate(List<String> lines) {
  // 1. dd/mm/yyyy or dd/mm/yy with - or / or .
  final numeric = RegExp(
    r'\b(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{2}|\d{4})\b',
  );
  for (final line in lines) {
    final m = numeric.firstMatch(line);
    if (m == null) continue;
    final d = int.tryParse(m.group(1)!);
    final mo = int.tryParse(m.group(2)!);
    var y = int.tryParse(m.group(3)!);
    if (d == null || mo == null || y == null) continue;
    if (y < 100) y += 2000; // 2-digit year ⇒ 20xx
    if (!_validDate(d, mo, y)) continue;
    return DateTime(y, mo, d);
  }

  // 2. "12 May 2026" / "12 MAY 26" / "12-May-2026"
  const monthNames = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9, 'sept': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };
  final wordy = RegExp(
    r'\b(\d{1,2})[\s\-]([A-Za-z]{3,4})[\s\-](\d{2}|\d{4})\b',
  );
  for (final line in lines) {
    final m = wordy.firstMatch(line);
    if (m == null) continue;
    final d = int.tryParse(m.group(1)!);
    final mo = monthNames[m.group(2)!.toLowerCase()];
    var y = int.tryParse(m.group(3)!);
    if (d == null || mo == null || y == null) continue;
    if (y < 100) y += 2000;
    if (!_validDate(d, mo, y)) continue;
    return DateTime(y, mo, d);
  }
  return null;
}

bool _validDate(int d, int m, int y) {
  if (m < 1 || m > 12) return false;
  if (d < 1 || d > 31) return false;
  if (y < 2000 || y > 2099) return false;
  // Round-trip via DateTime to catch e.g. 31 Feb.
  final dt = DateTime(y, m, d);
  return dt.year == y && dt.month == m && dt.day == d;
}

// ─── Merchant ─────────────────────────────────────────────────────

String? _parseMerchant(List<String> lines) {
  // Walk the first ~6 lines. Skip lines that look like an address (start
  // with a digit, contain a postcode-y pattern), a phone number, or VAT
  // registration. Pick the first plausible name.
  final postcode = RegExp(
    r'\b[A-Z]{1,2}\d{1,2}[A-Z]?\s*\d[A-Z]{2}\b',
  );
  final phone = RegExp(r'\b0\d{2,4}[\s-]*\d{3,4}[\s-]*\d{3,4}\b');
  final vatReg = RegExp(r'vat\s*(?:reg|no|number)', caseSensitive: false);

  for (var i = 0; i < lines.length && i < 6; i++) {
    final l = lines[i];
    if (l.length < 3) continue;
    if (RegExp(r'^\d').hasMatch(l)) continue; // starts with a digit
    if (postcode.hasMatch(l)) continue;
    if (phone.hasMatch(l)) continue;
    if (vatReg.hasMatch(l)) continue;
    // Strip trailing receipt noise like " Ltd." that doesn't add info but
    // keep meaningful caps. Cap length so we don't return paragraphs.
    final cleaned = l.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length > 60) continue;
    return cleaned;
  }
  return null;
}

// ─── Category guess ───────────────────────────────────────────────

/// Match against keywords typical of UK plumber expenses. The returned
/// string MUST be one of the values in `expenseCategories` so the dropdown
/// pre-selects correctly — see `expense_data.dart`.
String? _guessCategory(String raw) {
  final t = raw.toLowerCase();

  bool hasAny(List<String> ks) => ks.any(t.contains);

  if (hasAny(const [
    'petrol', 'diesel', 'unleaded', 'fuel pump', 'forecourt',
    ' bp ', 'shell ', 'esso', 'texaco', 'gulf',
    'sainsbury', 'tesco fuel', 'asda fuel', 'morrisons fuel',
  ])) {
    return 'Fuel';
  }
  // Vehicle is checked before Parts because the vehicle keywords are
  // brand-specific ("kwik fit", "halfords", "mot") while some plumbing
  // terms ("fitting") are generic and would otherwise capture "tyre
  // fitting" as a parts purchase.
  if (hasAny(const [
    'mot ', 'service plus', 'tyre', 'tyres', 'kwik fit',
    'halfords', 'parking', 'congestion', 'nyc parking',
    'car wash',
  ])) {
    return 'Vehicle (MOT, service, parking)';
  }
  if (hasAny(const [
    'plumb center', 'plumbcenter', 'plumb base', 'wolseley',
    'travis perkins', 'jewson', 'screwfix', 'toolstation',
    'howdens', 'wickes', 'b&q', 'b & q', 'bss', 'pts plumbing',
    'graham', 'grahams', 'ridgeons', 'magnet',
    'copper', 'compression', 'olive', 'flux',
    'inhibitor', 'radiator', 'valve',
  ])) {
    return 'Parts & materials';
  }
  if (hasAny(const [
    'tool', 'drill', 'kit', 'machine', 'press tool',
    'milwaukee', 'makita', 'dewalt', 'rothenberger',
  ])) {
    return 'Tools & equipment';
  }
  if (hasAny(const [
    'o2 ', 'vodafone', 'three ', '\bee\b', 'sky mobile',
    'phone bill', 'data plan',
  ])) {
    return 'Phone & data';
  }
  if (hasAny(const [
    'gas safe', 'oftec', 'unipart', 'aviva', 'hiscox',
    'simply business', 'public liability', 'insurance',
  ])) {
    return 'Insurance & subscriptions';
  }
  if (hasAny(const [
    'logic', 'wcs', 'training', 'course', 'acs ', 'cpd',
    'assessment',
  ])) {
    return 'Training & qualifications';
  }
  return null;
}
