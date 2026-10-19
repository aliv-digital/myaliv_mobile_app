class GuestPayBillReceiptArgs {
  final String serviceName;
  final String identifierLabel;
  final String identifierValue;
  final double amount;
  final String dateText;
  final String timeText;
  final String paymentMethod;
  final String? orderId;

  const GuestPayBillReceiptArgs({
    required this.serviceName,
    required this.identifierLabel,
    required this.identifierValue,
    required this.amount,
    required this.dateText,
    required this.timeText,
    this.paymentMethod = 'credit card',
    this.orderId,
  });
}
