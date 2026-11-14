import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class TipJarService {
  static const String tip29 = 'karos_habits_tip_29';
  static const String tip59 = 'karos_habits_tip_59';
  static const String tip99 = 'karos_habits_tip_99';

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool _ready = false;
  bool get ready => _ready;

  bool _available = false;
  bool get available => _available;

  final Map<String, ProductDetails> _products = {};
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);

  String? _lastError;
  String? get lastError => _lastError;

  Future<void> init() async {
    if (_ready) return;

    _available = await _iap.isAvailable();

    _sub = _iap.purchaseStream.listen(
      (purchases) async {
        for (final p in purchases) {
          await _handlePurchase(p);
        }
      },
      onError: (Object e, StackTrace st) {
        _lastError = e.toString();
        if (kDebugMode) {
          // ignore: avoid_print
          print('IAP purchaseStream error: $e');
        }
      },
    );

    if (!_available) {
      _ready = true;
      return;
    }

    final resp = await _iap.queryProductDetails({tip29, tip59, tip99});
    if (resp.error != null) {
      _lastError = resp.error!.message;
      _ready = true;
      return;
    }

    for (final p in resp.productDetails) {
      _products[p.id] = p;
    }

    _ready = true;
  }

  bool get donationsAvailable =>
      _available &&
      _products.containsKey(tip29) &&
      _products.containsKey(tip59) &&
      _products.containsKey(tip99);

  Future<void> donate(String productId) async {
    if (!_available) return;

    final details = _products[productId];
    if (details == null) return;

    final param = PurchaseParam(productDetails: details);

    await _iap.buyConsumable(
      purchaseParam: param,
      autoConsume: true,
    );
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        return;

      case PurchaseStatus.canceled:
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        return;

      case PurchaseStatus.error:
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        return;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        return;
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
