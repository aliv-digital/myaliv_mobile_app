import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_request_factory.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/plan_bundle.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Wraps `POST /Order/change-bundle`. Supplies the URL + change-bundle
/// envelope; the actual POST is delegated to [CardPaymentService] so top-up
/// and any future card-based flows share the same plumbing.
class ChangeBundleService {
  ChangeBundleService({CardPaymentService? cardPaymentService})
    : _cardPaymentService = cardPaymentService ?? instance<CardPaymentService>();

  final CardPaymentService _cardPaymentService;

  Future<ChangeBundleResult> payFromWallet({
    required double amount,
    required PlanBundle bundle,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) {
    return _send(
      cardPayment: ChangeBundleRequestFactory.walletCardPayment(amount: amount),
      bundle: bundle,
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
      logTag: 'change-bundle [wallet]',
    );
  }

  Future<ChangeBundleResult> payWithSavedCard({
    required double amount,
    required String cardToken,
    required PlanBundle bundle,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) {
    return _send(
      cardPayment: ChangeBundleRequestFactory.tokenCardPayment(
        amount: amount,
        cardToken: cardToken,
      ),
      bundle: bundle,
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
      logTag: 'change-bundle [saved-card]',
    );
  }

  Future<ChangeBundleResult> payWithNewCard({
    required double amount,
    required NewCardDetails details,
    required PlanBundle bundle,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) {
    return _send(
      cardPayment: ChangeBundleRequestFactory.newCardPayment(
        amount: amount,
        details: details,
      ),
      bundle: bundle,
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
      logTag: 'change-bundle [new-card]',
    );
  }

  Future<ChangeBundleResult> _send({
    required Map<String, dynamic> cardPayment,
    required PlanBundle bundle,
    required bool forceNow,
    DateTime? selectedBeginDate,
    required String logTag,
  }) async {
    final Map<String, dynamic> body;
    try {
      body = ChangeBundleRequestFactory.changeBundleBody(
        cardPayment: cardPayment,
        bundle: bundle,
        forceNow: forceNow,
        selectedBeginDate: selectedBeginDate,
      );
    } catch (e) {
      return ChangeBundleFailure(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }

    return _cardPaymentService.send(
      url: Api.payFromWalletUrl,
      body: body,
      logTag: logTag,
    );
  }
}
