import 'dart:async';

class GuestConfirmTopUpRepository {
  Future<void> payNow({
    required String phoneNumber,
    required double amount,
  }) async {
    // TODO: Replace with real API call
    await Future.delayed(const Duration(seconds: 1));
    // throw Exception("Payment failed"); // test failure if you want
  }
}
