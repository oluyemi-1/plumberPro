import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks the user's PipeSmart Pro entitlement.
///
/// In this build there is no real payment flow yet — the flag is set
/// either by the dev toggle in Settings or, eventually, by a real
/// `in_app_purchase` callback. Gating logic in list screens reads
/// [isPro] to decide whether to show locked items past the free limit.
class ProEntitlement extends ChangeNotifier {
  ProEntitlement._();
  static final ProEntitlement instance = ProEntitlement._();

  static const _kIsPro = 'pro_entitlement_is_pro_v1';
  static const _kExpiresAt = 'pro_entitlement_expires_at_v1';

  /// Number of items free in each gated feature when the user is not Pro.
  static const int freeLimit = 3;

  bool _isProFlag = false;
  DateTime? _expiresAt;
  bool _loaded = false;

  /// True if Pro is active *right now*. A grant with no [_expiresAt]
  /// is treated as lifetime; otherwise it expires at the stored time.
  /// Re-evaluated on every read, so the UI rebuilds the next time
  /// `notifyListeners` fires after the expiry has passed.
  bool get isPro {
    if (!_isProFlag) return false;
    if (_expiresAt == null) return true;
    return DateTime.now().isBefore(_expiresAt!);
  }

  /// When the current Pro grant expires, or null for lifetime / not-Pro.
  DateTime? get expiresAt => _isProFlag ? _expiresAt : null;

  /// True if Pro is active and has no expiry.
  bool get isLifetime => _isProFlag && _expiresAt == null;

  bool get loaded => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _isProFlag = prefs.getBool(_kIsPro) ?? false;
    final millis = prefs.getInt(_kExpiresAt);
    _expiresAt = millis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(millis);
    _loaded = true;
    notifyListeners();
  }

  /// Flip Pro on/off without an expiry. Used by the Settings dev toggle.
  /// Setting `false` also clears any stored expiry.
  Future<void> setPro(bool value) async {
    _isProFlag = value;
    if (!value) _expiresAt = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPro, value);
    if (!value) {
      await prefs.remove(_kExpiresAt);
    }
    notifyListeners();
  }

  /// Grant Pro until [until] (UTC-safe — DateTime is local-time agnostic
  /// for "isBefore"). Pass null for a lifetime grant.
  Future<void> grantPro({DateTime? until}) async {
    _isProFlag = true;
    _expiresAt = until;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPro, true);
    if (until == null) {
      await prefs.remove(_kExpiresAt);
    } else {
      await prefs.setInt(_kExpiresAt, until.millisecondsSinceEpoch);
    }
    notifyListeners();
  }

  /// True if the item at [index] within a feature list is unlocked.
  /// Pro users get everything; free users get the first [freeLimit].
  bool isUnlockedAt(int index) => isPro || index < freeLimit;
}
