class MakePaymentPostPaidData {
  final String title;
  final String paymentDueAmount;
  final String bottomAmount;
  final String bottomSubtitle;

  const MakePaymentPostPaidData({
    required this.title,
    required this.paymentDueAmount,
    required this.bottomAmount,
    required this.bottomSubtitle,
  });
}

abstract class MakePaymentPostPaidRepository {
  Future<MakePaymentPostPaidData> fetchPaymentData();
}
