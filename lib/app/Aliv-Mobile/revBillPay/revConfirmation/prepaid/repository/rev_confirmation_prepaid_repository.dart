class RevConfirmationData {
  final String customerName;
  final String service;
  final String accountNumber;

  final double amount; // base amount/subtotal
  final double vat; // vat amount

  const RevConfirmationData({
    required this.customerName,
    required this.service,
    required this.accountNumber,
    required this.amount,
    required this.vat,
  });
}

class PromoResult {
  final double discount; // discount amount
  const PromoResult({required this.discount});
}

abstract class RevConfirmationPrepaidRepository {
  Future<RevConfirmationData> fetchConfirmation();
  Future<PromoResult> applyPromo({
    required String code,
    required double subtotal,
  });
}
