import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/checkout_card_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/saved_card_payment_bottom_sheet.dart';

import '../bloc/make_payment_postpaid_bloc.dart';
import '../bloc/make_payment_postpaid_event.dart';
import '../bloc/make_payment_postpaid_state.dart';
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
      await _payWithNewCard(context, state);
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

  static Future<void> _payWithNewCard(
    BuildContext context,
    MakePaymentPostPaidState state,
  ) async {
    final bloc = context.read<MakePaymentPostPaidBloc>();
    final details = await CheckoutCardBottomSheet.show(
      context,
      amountText: BalanceCurrencyFormatterService.format(
        resolveMpAmountToCharge(state),
      ),
    );
    if (details == null) return;

    bloc.add(MpPayWithCardConfirmed(details));
  }

  static SavedCardModel? _cardByToken(String token) {
    for (final c in instance<SavedCardsCubit>().state.cards) {
      if (c.token == token) return c;
    }
    return null;
  }
}
