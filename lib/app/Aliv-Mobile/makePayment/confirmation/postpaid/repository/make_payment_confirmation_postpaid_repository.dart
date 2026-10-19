class MakePaymentConfirmationPostPaidData {
  final String title;
  final String customerName;
  final String accountNumber;
  final String headerLabel;
  final String amountPill;
  final String subtotal;
  final String vat;
  final String total;
  final String bottomSubtitle;
  final String bottomAmount;

  const MakePaymentConfirmationPostPaidData({
    required this.title,
    required this.customerName,
    required this.accountNumber,
    required this.headerLabel,
    required this.amountPill,
    required this.subtotal,
    required this.vat,
    required this.total,
    required this.bottomSubtitle,
    required this.bottomAmount,
  });
}

abstract class MakePaymentConfirmationPostPaidRepository {
  Future<MakePaymentConfirmationPostPaidData> fetchConfirmation();
  Future<void> applyPromo({required String code});
}
