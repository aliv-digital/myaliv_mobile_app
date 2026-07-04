import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

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

    context.push(
      AppRoutes.userProfileReceiptScreen,
      extra: UserProfileReceiptRouteArgs(
        amount: resolveMpAmountToCharge(state),
        topUpType: 'postpaid',
        recipientPhone: _accountPrimaryPhone(),
        paymentMethod: state.paymentMode == MpPaymentMode.payWithCard
            ? 'visa'
            : 'credit card',
      ),
    );
    context.read<MakePaymentPostPaidBloc>().add(const MpNavConsumed());
  }

  /// Receipt should reflect the number the API actually charged. Prefer the
  /// account's primary phone; fall back to `phoneNumber`, then null so the
  /// receipt repository can apply its own defaults.
  static String? _accountPrimaryPhone() {
    final account = instance<AccountInfoCubit>().state.accountInfo;
    final primary = account?.primaryPhoneNumber.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    final fallback = account?.phoneNumber.trim() ?? '';
    if (fallback.isNotEmpty) return fallback;
    return null;
  }
}
