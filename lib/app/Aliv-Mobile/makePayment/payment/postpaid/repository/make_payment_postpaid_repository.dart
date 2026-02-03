enum MpCardBrand { visa, mastercard }

class MpPaymentMethod {
  final MpCardBrand brand;
  final String ending;
  final String expiry;

  const MpPaymentMethod({
    required this.brand,
    required this.ending,
    required this.expiry,
  });
}

class MakePaymentPostPaidData {
  final String title;
  final String paymentDueAmount;
  final String bottomAmount;
  final String bottomSubtitle;
  final List<MpPaymentMethod> methods;

  const MakePaymentPostPaidData({
    required this.title,
    required this.paymentDueAmount,
    required this.bottomAmount,
    required this.bottomSubtitle,
    required this.methods,
  });
}

abstract class MakePaymentPostPaidRepository {
  Future<MakePaymentPostPaidData> fetchPaymentData();
}
