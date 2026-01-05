class GuestPayBillConfirmRepository {
  Future<double> fetchVat({
    required String serviceName,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return 0.00; // screenshot অনুযায়ী
  }

  Future<void> payNow({
    required String serviceName,
    required String identifierValue,
    required double totalAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return;
  }
}
