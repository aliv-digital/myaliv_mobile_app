import 'dart:async';
import '../models/top_up_breakdown.dart';


abstract class ConfirmTopUpPrepaidRepository {
  Future<TopUpBreakdown> getInitialBreakdown({required double amount});
  Future<TopUpBreakdown> applyPromoCode({
    required double amount,
    required String promoCode,
  });

  Future<void> confirmTopUp({
    required String customerName,
    required String customerPhone,
    required double amount,
    required String? promoCode,
  });
}

/// Simple demo implementation:
/// - VAT = 0
/// - Promo: SAVE10 => 10% off, NAHIN50 => 50% off
class ConfirmTopUpPrepaidRepositoryImpl implements ConfirmTopUpPrepaidRepository {
  @override
  Future<TopUpBreakdown> getInitialBreakdown({required double amount}) async {
    // Simulate latency
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return TopUpBreakdown(
      subTotal: amount,
      vat: 0,
      total: amount,
      vatExclusive: true,
    );
  }

  @override
  Future<TopUpBreakdown> applyPromoCode({
    required double amount,
    required String promoCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final code = promoCode.trim().toUpperCase();
    double discount = 0;

    if (code == 'SAVE10') discount = 0.10;
    if (code == 'NAHIN50') discount = 0.50;

    if (discount == 0) {
      throw const PromoCodeException('Invalid promo code');
    }

    final discounted = amount * (1 - discount);
    return TopUpBreakdown(
      subTotal: discounted,
      vat: 0,
      total: discounted,
      vatExclusive: true,
    );
  }

  @override
  Future<void> confirmTopUp({
    required String customerName,
    required String customerPhone,
    required double amount,
    required String? promoCode,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // In real impl: call API, handle failures.
    // Throw on failure:
    // throw Exception('Something went wrong');
  }
}

class PromoCodeException implements Exception {
  final String message;
  const PromoCodeException(this.message);

  @override
  String toString() => message;
}
