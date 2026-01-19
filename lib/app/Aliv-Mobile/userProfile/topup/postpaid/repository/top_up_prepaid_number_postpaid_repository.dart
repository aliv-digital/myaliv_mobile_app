class TopUpPrepaidNumberPostPaidRepository {
  Future<void> applyTopUp({
    required String number,
    required double amount,
  }) async {
    // TODO: API integration here
    await Future.delayed(const Duration(milliseconds: 650));
  }
}
