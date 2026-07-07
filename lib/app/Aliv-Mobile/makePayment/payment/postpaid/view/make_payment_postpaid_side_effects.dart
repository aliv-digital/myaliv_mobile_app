import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/postpaid_receipt_navigator.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../bloc/make_payment_postpaid_bloc.dart';
import '../bloc/make_payment_postpaid_event.dart';
import '../bloc/make_payment_postpaid_state.dart';
import 'make_payment_amount_resolver.dart';

/// Central place for bloc-driven side effects (toast on error, one-shot
/// receipt navigation on success). Keeping these off the widget tree makes
/// each rule reviewable in isolation.
class MakePaymentPostPaidSideEffects {
  MakePaymentPostPaidSideEffects._();

  /// Called from the screen's `BlocConsumer.listener`. Runs any error toast
  /// first, then handles a `paid` nav target if set.
  static void onState(
    BuildContext context,
    MakePaymentPostPaidState state,
  ) {
    _showErrorToast(state.errorMessage);
    _handlePaidNav(context, state);
  }

  static void _showErrorToast(String? message) {
    if (message == null || message.isEmpty) return;
    AppToast.show(message: message, type: ToastType.error);
  }

  static void _handlePaidNav(
    BuildContext context,
    MakePaymentPostPaidState state,
  ) {
    if (state.navTarget != MpNavTarget.paid) return;

    PostpaidReceiptNavigator.push(
      context,
      amount: resolveMpAmountToCharge(state),
      method: state.paymentMode == MpPaymentMode.payWithCard
          ? PostpaidPaymentMethod.newCard
          : PostpaidPaymentMethod.savedCard,
      cardToSave: state.paymentMode == MpPaymentMode.payWithCard
          ? state.lastNewCardDetails
          : null,
    );
    context.read<MakePaymentPostPaidBloc>().add(const MpNavConsumed());
  }
}
