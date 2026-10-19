import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/make_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/postpaid_receipt_navigator.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/checkout_card_bottom_sheet.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

/// End-to-end "pay with new card" for postpaid, aimed at surfaces that
/// don't own a bloc-based submit path (e.g. auto-pay screen). Runs:
///
///   sheet → `MakePaymentService.payWithNewCard` → toast / receipt nav.
///
/// Returns `true` iff the payment succeeded. Callers use the return value
/// only if they need a follow-up (auto-enrol, refresh, etc.). Cancels and
/// failures are indistinguishable from the caller's perspective — both
/// handled internally (cancel = silent, failure = toast).
///
/// Bloc-based screens (make-payment) go through their own submit machinery
/// and reuse [PostpaidReceiptNavigator] directly instead of this flow.
class PostpaidPayWithNewCardFlow {
  PostpaidPayWithNewCardFlow._();

  static Future<bool> run(
    BuildContext context, {
    required double amount,
    MakePaymentService? service,
  }) async {
    final details = await CheckoutCardBottomSheet.show(
      context,
      amountText: BalanceCurrencyFormatterService.format(amount),
    );
    if (details == null) return false;
    if (!context.mounted) return false;

    final result = await _invoke(
      service ?? instance<MakePaymentService>(),
      amount: amount,
      details: details,
    );
    if (!context.mounted) return false;

    switch (result) {
      case ChangeBundleSuccess():
        PostpaidReceiptNavigator.push(
          context,
          amount: amount,
          method: PostpaidPaymentMethod.newCard,
          cardToSave: details,
        );
        return true;
      case ChangeBundleFailure(:final message):
        AppToast.show(message: message, type: ToastType.error);
        return false;
    }
  }

  /// Wraps the service call so any thrown exception (e.g. an unexpected
  /// bug in the plumbing) becomes a [ChangeBundleFailure] with a generic
  /// message — the switch above then handles it uniformly.
  static Future<ChangeBundleResult> _invoke(
    MakePaymentService service, {
    required double amount,
    required NewCardDetails details,
  }) async {
    try {
      return await service.payWithNewCard(amount: amount, details: details);
    } catch (_) {
      return const ChangeBundleFailure('Payment failed. Try again.');
    }
  }
}
