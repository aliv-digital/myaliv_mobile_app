import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_request_factory.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Wraps `POST /Order/payment` for postpaid make-payment. Same plumbing as
/// [ChangeBundleService] and [TopUpPaymentService]; only the URL differs.
/// The envelope reuses `topUpBody` (no `Bundle` block, `ForceNow: true`).
class MakePaymentService {
  MakePaymentService({CardPaymentService? cardPaymentService})
    : _cardPaymentService =
          cardPaymentService ?? instance<CardPaymentService>();

  final CardPaymentService _cardPaymentService;

  Future<ChangeBundleResult> payWithSavedCard({
    required double amount,
    required String cardToken,
  }) {
    return _send(
      cardPayment: ChangeBundleRequestFactory.tokenCardPayment(
        amount: amount,
        cardToken: cardToken,
      ),
      logTag: 'make-payment [saved-card]',
    );
  }

  Future<ChangeBundleResult> payWithNewCard({
    required double amount,
    required NewCardDetails details,
  }) {
    return _send(
      cardPayment: ChangeBundleRequestFactory.newCardPayment(
        amount: amount,
        details: details,
      ),
      logTag: 'make-payment [new-card]',
    );
  }

  Future<ChangeBundleResult> _send({
    required Map<String, dynamic> cardPayment,
    required String logTag,
  }) {
    final body = ChangeBundleRequestFactory.topUpBody(cardPayment: cardPayment);
    return _cardPaymentService.send(
      url: Api.orderPaymentUrl,
      body: body,
      logTag: logTag,
    );
  }
}
