class TopUpPrepaidRepository {
  /// ✅ Later: call API here
  Future<double> fetchCurrentBalance() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return 129.00; // mock from screenshot
  }

  /// ✅ Later: submit topup API here
  Future<void> topUp({required double amount}) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }
}
