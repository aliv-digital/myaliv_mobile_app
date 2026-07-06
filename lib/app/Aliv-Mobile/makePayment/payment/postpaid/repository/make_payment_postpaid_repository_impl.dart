import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/make_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';

import 'make_payment_postpaid_repository.dart';

class MakePaymentPostPaidRepositoryImpl
    implements MakePaymentPostPaidRepository {
  MakePaymentPostPaidRepositoryImpl({MakePaymentService? service})
    : _service = service ?? instance<MakePaymentService>();

  final MakePaymentService _service;

  @override
  Future<MakePaymentPostPaidData> fetchPaymentData() async {
    return const MakePaymentPostPaidData(
      title: 'payment',
      paymentDueAmount: r'$ 129.00',
      bottomAmount: r'$ 129.00',
      bottomSubtitle: 'no vat applied',
    );
  }

  @override
  Future<bool> payWithSavedCard({
    required double amount,
    required String cardToken,
  }) async {
    final result = await _service.payWithSavedCard(
      amount: amount,
      cardToken: cardToken,
    );
    return _unwrap(result);
  }

  @override
  Future<bool> payWithNewCard({
    required double amount,
    required NewCardDetails details,
  }) async {
    final result = await _service.payWithNewCard(
      amount: amount,
      details: details,
    );
    return _unwrap(result);
  }

  bool _unwrap(ChangeBundleResult result) {
    switch (result) {
      case ChangeBundleSuccess():
        return true;
      case ChangeBundleFailure(:final message):
        throw Exception(message);
    }
  }
}
