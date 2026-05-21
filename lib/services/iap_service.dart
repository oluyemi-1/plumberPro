import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'pro_entitlement.dart';
import 'redemption_service.dart';

/// A purchasable PipeSmart Pro subscription tier.
class ProPlan {
  final String productId;
  final int months;
  final String label;

  const ProPlan(this.productId, this.months, this.label);
}

/// Native in-app purchase service for individual PipeSmart Pro subscriptions.
///
/// This is the in-app channel (Apple App Store / Google Play). The separate
/// redemption-code channel ([RedemptionService]) handles institutional and
/// direct-sale licences distributed outside the stores.
///
/// SERVER-LESS ENTITLEMENT MODEL
/// PipeSmart has no backend and no user accounts, so we cannot do server-side
/// receipt validation. Instead, on each `purchased`/`restored` event for a
/// known product we grant Pro until `now + plan.months` via
/// [ProEntitlement.grantPro]. The auto-renewing subscription pushes that
/// window forward each time a renewal event is delivered (app open) or
/// [restorePurchases] is called on launch. If a subscription lapses, the
/// locally-stored expiry also lapses and Pro turns off. This is the standard
/// trade-off for an account-less app; precise expiry would require a backend
/// validating the App Store / Play receipt. Documented limitation, revisit
/// in a future version if a backend is added.
class IapService extends ChangeNotifier {
  IapService._();
  static final IapService instance = IapService._();

  /// Subscription product IDs. These must be created identically in both
  /// App Store Connect (one subscription group, four durations) and Google
  /// Play Console (subscription with four base plans, or four products).
  static const plans = <ProPlan>[
    ProPlan('pipesmart_pro_1m', 1, '1 month'),
    ProPlan('pipesmart_pro_3m', 3, '3 months'),
    ProPlan('pipesmart_pro_6m', 6, '6 months'),
    ProPlan('pipesmart_pro_12m', 12, '1 year'),
  ];

  static Set<String> get _productIds => {for (final p in plans) p.productId};

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool _available = false;
  bool _loading = false;
  String? _lastError;
  List<ProductDetails> _products = const [];

  /// Whether the store is reachable on this device/platform.
  bool get available => _available;

  /// Whether a product query or purchase is currently in flight.
  bool get loading => _loading;

  /// Last user-facing error string, or null.
  String? get lastError => _lastError;

  /// Store products, ordered to match [plans] (1, 3, 6, 12 months).
  List<ProductDetails> get products {
    final byId = {for (final p in _products) p.id: p};
    return [
      for (final plan in plans)
        if (byId[plan.productId] != null) byId[plan.productId]!,
    ];
  }

  ProPlan? planForProduct(String productId) {
    for (final p in plans) {
      if (p.productId == productId) return p;
    }
    return null;
  }

  /// Initialise the store connection and load products. Safe to call once
  /// at startup; later callers can use [refreshProducts].
  Future<void> init() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      notifyListeners();
      return;
    }
    _sub ??= _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object e) {
        _lastError = e.toString();
        notifyListeners();
      },
    );
    await refreshProducts();
  }

  Future<void> refreshProducts() async {
    if (!_available) return;
    _loading = true;
    _lastError = null;
    notifyListeners();
    try {
      final response = await _iap.queryProductDetails(_productIds);
      _products = response.productDetails;
      if (response.error != null) {
        _lastError = response.error!.message;
      }
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Begin a subscription purchase for [product]. Result arrives
  /// asynchronously via the purchase stream → [_onPurchaseUpdates].
  Future<void> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    // Auto-renewable subscriptions go through buyNonConsumable in this plugin.
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Re-deliver the user's active purchases. Call on launch and from the
  /// "Restore purchases" button. Active subscriptions arrive as `restored`.
  Future<void> restore() async {
    if (!_available) return;
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          _lastError = purchase.error?.message ?? 'Purchase failed.';
          notifyListeners();
          break;
        case PurchaseStatus.canceled:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantFor(purchase);
          break;
      }
      // Always tell the store the transaction is finished, or iOS will keep
      // re-delivering it on every launch.
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _grantFor(PurchaseDetails purchase) async {
    final plan = planForProduct(purchase.productID);
    if (plan == null) return;
    final until = RedemptionService.addMonths(DateTime.now(), plan.months);
    // Only extend — never shorten — an existing entitlement.
    final current = ProEntitlement.instance.expiresAt;
    if (current == null && ProEntitlement.instance.isLifetime) return;
    if (current != null && current.isAfter(until)) return;
    await ProEntitlement.instance.grantPro(until: until);
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
