import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_request_factory.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_request.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/payment_success.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/saved_card_payment_bottom_sheet.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/make_payment_postpaid_bloc.dart';
import '../bloc/make_payment_postpaid_event.dart';
import '../bloc/make_payment_postpaid_state.dart';
import '../theme/make_payment_postpaid_theme.dart';
import 'make_payment_amount_resolver.dart';

/// Orchestrates the "pay now" gesture: opens the correct confirmation sheet
/// for the chosen mode, then dispatches the matching confirmation event so
/// the bloc's shared `_submit` handler can drive the API call.
///
/// Split out from the screen because the sheet-open flow is where new
/// funding sources (wallet, apple pay, etc.) are likeliest to plug in.
class MakePaymentPostPaidPayFlow {
  MakePaymentPostPaidPayFlow._();

  static Future<void> onPayNow(
    BuildContext context,
    MakePaymentPostPaidState state,
  ) async {
    if (state.paymentMode == MpPaymentMode.payWithCard) {
      _payWithNewCard(context, state);
      return;
    }
    await _payWithSavedCard(context, state);
  }

  static Future<void> _payWithSavedCard(
    BuildContext context,
    MakePaymentPostPaidState state,
  ) async {
    final bloc = context.read<MakePaymentPostPaidBloc>();
    final token = state.selectedMethodToken?.trim() ?? '';
    if (token.isEmpty) return;

    final card = _cardByToken(token);
    if (card == null) return;

    final confirmed = await SavedCardPaymentBottomSheet.show(
      context,
      cardLabel: card.displayLabel,
      amountText: BalanceCurrencyFormatterService.format(
        resolveMpAmountToCharge(state),
      ),
    );
    if (confirmed != true) return;

    bloc.add(const MpPaySavedCardConfirmed());
  }

  static void _payWithNewCard(
    BuildContext context,
    MakePaymentPostPaidState state,
  ) {
    final bloc = context.read<MakePaymentPostPaidBloc>();
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);

    final request = PaymentRequest(
      url: Api.orderPayment3DSUrl,
      body: ChangeBundleRequestFactory.orderPaymentBodyFor3DS(
        amount: resolveMpAmountToCharge(state),
      ),
      redirectScheme: 'myaliv',
    );

    navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PaymentIFrameScreen(
          request: request,
          appBarBgColor: MakePaymentPostPaidTheme.appBarBg,
          title: 'payment',
          onSuccess: (PaymentSuccess success) {
            navigator.pop();
            bloc.add(Mp3DSSucceeded(orderId: success.orderId));
          },
          onFailure: (String message) {
            navigator.pop();
            AppToast.show(message: message, type: ToastType.error);
          },
          onHomeTap: () {
            navigator.pop();
            router.go(AppRoutes.home);
          },
        ),
      ),
    );
  }

  static SavedCardModel? _cardByToken(String token) {
    for (final c in instance<SavedCardsCubit>().state.cards) {
      if (c.token == token) return c;
    }
    return null;
  }
}
