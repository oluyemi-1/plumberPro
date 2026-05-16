import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pro_entitlement.dart';

/// Result of a redemption attempt.
class RedemptionResult {
  /// The status string — one of the `result*` constants on [RedemptionService].
  final String status;

  /// When the granted Pro entitlement expires. Null on a lifetime grant
  /// or on a failed redemption.
  final DateTime? expiresAt;

  /// Number of months granted (1, 3, 6, 12) or null for lifetime/failure.
  final int? months;

  const RedemptionResult(this.status, {this.expiresAt, this.months});

  bool get ok => status == RedemptionService.resultOk;
}

/// One-shot redemption codes for PipeSmart Pro.
///
/// Two code formats are supported:
///
/// **Legacy (lifetime)** — `PSMART-XXXX-XXXX-XXXX-XXXX`
///   - 16 hex chars: 8 random nonce + 8 truncated HMAC-SHA256
///   - Grants lifetime Pro.
///
/// **Tiered (expiring)** — `PSMART-TT-XXXX-XXXX-XXXX-XXXX`
///   - 18 hex chars: 2 tier + 8 random nonce + 8 HMAC over `tier||nonce`
///   - Tier is months as hex (`01`=1mo, `03`=3mo, `06`=6mo, `0C`=12mo).
///   - Grants Pro until `redemption_time + months`.
///
/// All validation happens on-device. On successful redemption the code
/// is recorded in SharedPreferences so it cannot be redeemed twice on
/// the same device. Single-use *across devices* would require a server.
///
/// To **rotate** the signing key — e.g. to invalidate every code ever
/// issued — change [_secret] and ship a new build. The
/// [tools/generate_codes.dart] CLI script must use the same value.
class RedemptionService {
  RedemptionService._();
  static final RedemptionService instance = RedemptionService._();

  static const _kRedeemed = 'redeemed_codes_v1';

  /// HMAC signing key for redemption codes. Keep this in sync with
  /// `tools/generate_codes.dart`. Treat as a secret — anyone with this
  /// string can mint valid codes.
  static const _secret =
      'pipesmart-pro-2026-karitec-rotate-this-to-invalidate-old-codes';

  static const _hex = '0123456789ABCDEF';

  /// Result codes for redeem attempts.
  static const String resultOk = 'ok';
  static const String resultMalformed = 'malformed';
  static const String resultInvalid = 'invalid';
  static const String resultAlreadyRedeemed = 'already_redeemed';

  /// Strip the human formatting (`PSMART-` prefix, dashes, spaces) and
  /// upper-case the body. Returns null if the result isn't valid hex
  /// or isn't a known length (16 = legacy lifetime, 18 = tiered).
  static String? _normalise(String raw) {
    final cleaned = raw
        .trim()
        .toUpperCase()
        .replaceAll(' ', '')
        .replaceAll('PSMART-', '')
        .replaceAll('-', '');
    if (cleaned.length != 16 && cleaned.length != 18) return null;
    for (final c in cleaned.codeUnits) {
      if (!_hex.codeUnits.contains(c)) return null;
    }
    return cleaned;
  }

  static String _signatureFor(String payload) {
    final hmac = Hmac(sha256, utf8.encode(_secret));
    final digest = hmac.convert(utf8.encode(payload));
    return digest.toString().toUpperCase().substring(0, 8);
  }

  /// True if [raw] is a structurally valid, HMAC-signed code.
  /// Does NOT consult redemption history.
  static bool isStructurallyValid(String raw) {
    final body = _normalise(raw);
    if (body == null) return false;
    if (body.length == 16) {
      // Legacy lifetime: signature is over the nonce alone.
      final nonce = body.substring(0, 8);
      final sig = body.substring(8, 16);
      return _signatureFor(nonce) == sig;
    }
    // Tiered: signature is over tier + nonce together.
    final tier = body.substring(0, 2);
    final nonce = body.substring(2, 10);
    final sig = body.substring(10, 18);
    return _signatureFor('$tier$nonce') == sig;
  }

  /// Reformat a normalised body back to the dashed display form.
  static String _format(String body) {
    if (body.length == 16) {
      return 'PSMART-${body.substring(0, 4)}-${body.substring(4, 8)}-${body.substring(8, 12)}-${body.substring(12, 16)}';
    }
    // 18-char tiered body.
    return 'PSMART-${body.substring(0, 2)}-${body.substring(2, 6)}-${body.substring(6, 10)}-${body.substring(10, 14)}-${body.substring(14, 18)}';
  }

  /// Build a lifetime code (used by CLI for back-compat / founding gifts).
  static String generateLifetime({Random? rng}) {
    final r = rng ?? Random.secure();
    final nonceBytes = List<int>.generate(4, (_) => r.nextInt(256));
    final nonce = nonceBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();
    final sig = _signatureFor(nonce);
    return _format('$nonce$sig');
  }

  /// Build a tiered (expiring) code for [months] of Pro.
  /// Valid months: any positive int 1..254. Common choices: 1, 3, 6, 12.
  static String generateTiered(int months, {Random? rng}) {
    if (months <= 0 || months > 254) {
      throw ArgumentError('months must be between 1 and 254, got $months');
    }
    final r = rng ?? Random.secure();
    final tier = months.toRadixString(16).padLeft(2, '0').toUpperCase();
    final nonceBytes = List<int>.generate(4, (_) => r.nextInt(256));
    final nonce = nonceBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();
    final sig = _signatureFor('$tier$nonce');
    return _format('$tier$nonce$sig');
  }

  /// Add [months] calendar months to [from], best-effort. We approximate
  /// by clamping the day-of-month so e.g. Jan 31 + 1 month = Feb 28/29.
  static DateTime addMonths(DateTime from, int months) {
    final newMonthTotal = from.month - 1 + months;
    final newYear = from.year + newMonthTotal ~/ 12;
    final newMonth = newMonthTotal % 12 + 1;
    final daysInNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = from.day > daysInNewMonth ? daysInNewMonth : from.day;
    return DateTime(
        newYear, newMonth, newDay, from.hour, from.minute, from.second);
  }

  Future<Set<String>> _loadRedeemed() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kRedeemed) ?? const []).toSet();
  }

  /// Attempt to redeem a code. On success, grants Pro entitlement
  /// (lifetime for legacy codes, time-limited for tiered codes).
  Future<RedemptionResult> redeem(String raw) async {
    final body = _normalise(raw);
    if (body == null) return const RedemptionResult(resultMalformed);
    if (!isStructurallyValid(raw)) {
      return const RedemptionResult(resultInvalid);
    }
    final formatted = _format(body);
    final redeemed = await _loadRedeemed();
    if (redeemed.contains(formatted)) {
      return const RedemptionResult(resultAlreadyRedeemed);
    }

    // Compute the entitlement window.
    int? months;
    DateTime? expiresAt;
    if (body.length == 18) {
      months = int.parse(body.substring(0, 2), radix: 16);
      expiresAt = addMonths(DateTime.now(), months);
    }

    // Persist and grant.
    redeemed.add(formatted);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kRedeemed, redeemed.toList());
    await ProEntitlement.instance.grantPro(until: expiresAt);
    return RedemptionResult(resultOk, expiresAt: expiresAt, months: months);
  }
}
