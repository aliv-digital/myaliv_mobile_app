import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/bottomsheet/wallet_payment_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/widgets/saved_card_payment_bottom_sheet.dart';

/// Opens the payment confirmation sheets and forwards the result to the bloc.
/// Pure plumbing — kept out of the view so widgets stay declarative.
class PaymentSheetLauncher {
  PaymentSheetLauncher._();

  static Future<void> openWallet(
    BuildContext context, {
    required double walletBalance,
    required String walletBalanceText,
    required String amountText,
  }) async {
    final bloc = context.read<HomePlansPaymentMethodBloc>();
    if (bloc.state.status == HomePlansPaymentMethodStatus.submitting) return;

    final confirmed = await WalletPaymentBottomSheet.show(
      context,
      walletBalanceText: walletBalanceText,
      amountText: amountText,
      navigateToReceiptOnConfirm: false,
    );
    if (confirmed != true) return;

    bloc.add(HomePlansPayFromWalletConfirmed(walletBalance: walletBalance));
  }

  static Future<void> openSavedCard(BuildContext context) async {
    final bloc = context.read<HomePlansPaymentMethodBloc>();
    final state = bloc.state;
    if (state.status == HomePlansPaymentMethodStatus.submitting) return;

    final token = state.selectedMethodId?.trim() ?? '';
    if (token.isEmpty) return;

    final card = _cardByToken(token);
    if (card == null) return;

    final confirmed = await SavedCardPaymentBottomSheet.show(
      context,
      cardLabel: card.displayLabel,
      amountText: state.amountText,
    );
    if (confirmed != true) return;

    bloc.add(const HomePlansPaySavedCardConfirmed());
  }

  static SavedCardModel? _cardByToken(String token) {
    for (final c in instance<SavedCardsCubit>().state.cards) {
      if (c.token == token) return c;
    }
    return null;
  }
}
