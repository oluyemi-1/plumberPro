// Mint PipeSmart Pro redemption codes.
//
// Usage (from project root):
//   dart run tools/generate_codes.dart                        # 10 lifetime codes
//   dart run tools/generate_codes.dart 50                     # 50 lifetime codes
//   dart run tools/generate_codes.dart 50 college             # 50 lifetime, with batch label
//   dart run tools/generate_codes.dart 50 college 1y          # 50 codes valid for 1 year
//   dart run tools/generate_codes.dart 200 jtl-spring 6mo     # 200 codes valid for 6 months
//
// Duration values accepted:
//   1m | 1mo | 1month                → 1 month
//   3m | 3mo | 3months               → 3 months
//   6m | 6mo | 6months               → 6 months
//   1y | 12m | 12mo | 1year          → 12 months
//   life | lifetime | perm           → no expiry (legacy format)
//
// The expiry clock starts when the user redeems the code, not when you
// generated it. So a 12-month code generated today and redeemed in
// 3 months will expire 15 months from now.
//
// The codes are HMAC-signed with the same secret hard-coded in
// `lib/services/redemption_service.dart`. If you rotate the secret in
// one file you MUST rotate it in the other, and every previously
// issued code will stop working.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

// MUST match `RedemptionService._secret` in
// lib/services/redemption_service.dart.
const _secret =
    'pipesmart-pro-2026-karitec-rotate-this-to-invalidate-old-codes';

String _signatureFor(String payload) {
  final hmac = Hmac(sha256, utf8.encode(_secret));
  final digest = hmac.convert(utf8.encode(payload));
  return digest.toString().toUpperCase().substring(0, 8);
}

String _hexNonce(Random rng) {
  final bytes = List<int>.generate(4, (_) => rng.nextInt(256));
  return bytes
      .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join();
}

String _mintLifetime(Random rng) {
  final nonce = _hexNonce(rng);
  final sig = _signatureFor(nonce);
  final body = '$nonce$sig';
  return 'PSMART-${body.substring(0, 4)}-${body.substring(4, 8)}-${body.substring(8, 12)}-${body.substring(12, 16)}';
}

String _mintTiered(int months, Random rng) {
  final tier = months.toRadixString(16).padLeft(2, '0').toUpperCase();
  final nonce = _hexNonce(rng);
  final sig = _signatureFor('$tier$nonce');
  final body = '$tier$nonce$sig';
  return 'PSMART-${body.substring(0, 2)}-${body.substring(2, 6)}-${body.substring(6, 10)}-${body.substring(10, 14)}-${body.substring(14, 18)}';
}

/// Parse a human duration string into months (1..254) or null for lifetime.
int? _parseDuration(String raw) {
  final s = raw.trim().toLowerCase();
  if (s.isEmpty) return null;
  if (s == 'life' || s == 'lifetime' || s == 'perm' || s == 'permanent') {
    return null;
  }
  // Strip trailing letters.
  final num = RegExp(r'^(\d+)').firstMatch(s)?.group(1);
  if (num == null) {
    stderr.writeln('Unrecognised duration "$raw".');
    exit(2);
  }
  final n = int.parse(num);
  if (s.endsWith('y') || s.endsWith('year') || s.endsWith('years')) {
    return n * 12;
  }
  if (s.endsWith('m') ||
      s.endsWith('mo') ||
      s.endsWith('month') ||
      s.endsWith('months')) {
    return n;
  }
  stderr.writeln('Unrecognised duration "$raw" — expected e.g. 1m, 6mo, 1y, life.');
  exit(2);
}

String _durationLabel(int? months) {
  if (months == null) return 'lifetime';
  if (months == 12) return '1 year';
  if (months % 12 == 0) return '${months ~/ 12} years';
  return '$months month${months == 1 ? '' : 's'}';
}

void main(List<String> args) {
  final count = args.isEmpty ? 10 : (int.tryParse(args[0]) ?? 10);
  final label = args.length > 1 ? args[1] : '';
  final months = args.length > 2 ? _parseDuration(args[2]) : null;
  final stamp = DateTime.now().toIso8601String().substring(0, 10);

  stdout.writeln('# PipeSmart Pro redemption codes');
  if (label.isNotEmpty) stdout.writeln('# batch: $label');
  stdout.writeln('# generated: $stamp');
  stdout.writeln('# count: $count');
  stdout.writeln('# duration: ${_durationLabel(months)} from redemption');
  stdout.writeln(
      '# each code unlocks Pro on a single device; expiry counts from when the user redeems');
  stdout.writeln('');

  final rng = Random.secure();
  final seen = <String>{};
  var emitted = 0;
  while (emitted < count) {
    final code = months == null ? _mintLifetime(rng) : _mintTiered(months, rng);
    if (seen.add(code)) {
      stdout.writeln(code);
      emitted++;
    }
  }
}
