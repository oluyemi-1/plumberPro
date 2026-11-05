import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// The proof of purchase the proxy server can check with the store: the Play
/// purchase token on Android, the transaction id on iOS, or a redeemed licence
/// code. Saved whenever Pro is granted so the AI tutor can obtain a metered
/// entitlement from the server without the user signing in.
class PurchaseProof {
  static const _kPrefs = 'purchase_proof_v1';

  /// 'android', 'ios' or 'code'.
  final String platform;
  final String token;
  final String productId;

  const PurchaseProof({
    required this.platform,
    required this.token,
    required this.productId,
  });

  static Future<void> save(PurchaseProof proof) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPrefs,
      jsonEncode({
        'platform': proof.platform,
        'token': proof.token,
        'product_id': proof.productId,
      }),
    );
  }

  static Future<PurchaseProof?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefs);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return PurchaseProof(
      platform: map['platform'] as String,
      token: map['token'] as String,
      productId: map['product_id'] as String,
    );
  }
}
