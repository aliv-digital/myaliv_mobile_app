import 'dart:async';

abstract class TopUpPaymentPrepaidRepository {
  Future<void> payNow({required String paymentMethodId});
}

/// Demo repository (replace with real API/local store)
class TopUpPaymentPrepaidRepositoryImpl
    implements TopUpPaymentPrepaidRepository {
  @override
  Future<void> payNow({required String paymentMethodId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // Throw if payment fails:
    // throw Exception('Payment failed');
  }
}
