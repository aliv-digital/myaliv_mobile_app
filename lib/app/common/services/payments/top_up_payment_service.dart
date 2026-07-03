import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_request_factory.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Wraps `POST /Order/top-up/{PrimaryPhoneNumber}`. Uses the same
/// [CardPaymentService] plumbing as [ChangeBundleService]; the only
/// differences are the URL (phone in path) and the envelope (no `Bundle`).
class TopUpPaymentService {
  TopUpPaymentService({CardPaymentService? cardPaymentService})
    : _cardPaymentService = cardPaymentService ?? instance<CardPaymentService>();

  final CardPaymentService _cardPaymentService;

  Future<ChangeBundleResult> payWithSavedCard({
    required double amount,
    required String primaryPhoneNumber,
    required String cardToken,
  }) {
    return _send(
      primaryPhoneNumber: primaryPhoneNumber,
      cardPayment: ChangeBundleRequestFactory.tokenCardPayment(
        amount: amount,
        cardToken: cardToken,
      ),
      logTag: 'top-up [saved-card]',
    );
  }

  Future<ChangeBundleResult> payWithNewCard({
    required double amount,
    required String primaryPhoneNumber,
    required NewCardDetails details,
  }) {
    return _send(
      primaryPhoneNumber: primaryPhoneNumber,
      cardPayment: ChangeBundleRequestFactory.newCardPayment(
        amount: amount,
        details: details,
      ),
      logTag: 'top-up [new-card]',
    );
  }

  Future<ChangeBundleResult> _send({
    required String primaryPhoneNumber,
    required Map<String, dynamic> cardPayment,
    required String logTag,
  }) {
    final phone = primaryPhoneNumber.trim();
    if (phone.isEmpty) {
      return Future.value(
        const ChangeBundleFailure('Recipient phone number is required.'),
      );
    }

    final body = ChangeBundleRequestFactory.topUpBody(cardPayment: cardPayment);

    return _cardPaymentService.send(
      url: Api.topUpUrl(phone),
      body: body,
      logTag: logTag,
    );
  }
}
