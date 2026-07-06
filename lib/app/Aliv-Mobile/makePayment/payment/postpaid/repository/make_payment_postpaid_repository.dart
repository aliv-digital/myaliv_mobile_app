import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';

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

  Future<bool> payWithSavedCard({
    required double amount,
    required String cardToken,
  });

  Future<bool> payWithNewCard({
    required double amount,
    required NewCardDetails details,
  });
}
