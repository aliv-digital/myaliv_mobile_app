import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/theme/home_plans_payment_method_theme.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/services/payment_sheet_launcher.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';

/// Bottom "pay now" bar. Dispatches the matching sheet for the current mode.
class PaymentPayBar extends StatelessWidget {
  final HomePlansPaymentMethodState state;
  final bool isSubmitting;

  const PaymentPayBar({
    super.key,
    required this.state,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultBottomPayBar(
      amountText: state.amountText,
      isVatExclusive:
          state.vatNote.toLowerCase().contains('no vat applied'),
      isButtonEnabled: state.isPayNowEnabled,
      isLoading: isSubmitting,
      buttonColor: HomePlansPaymentMethodTheme.payBtnBg,
      onPayNow: () => _onPayNow(context),
    );
  }

  void _onPayNow(BuildContext context) {
    AppSession.appRoute = state.isPrepaidUser ? 'prepaidPlan' : 'postpaidPlan';

    switch (state.paymentMode) {
      case HomePlansPaymentMode.chargeToMyAccount:
      case HomePlansPaymentMode.payFromWallet:
        _payFromWallet(context);
        return;
      case HomePlansPaymentMode.card:
        PaymentSheetLauncher.openSavedCard(context);
        return;
      case HomePlansPaymentMode.payWithCard:
        PaymentSheetLauncher.openPayWithCard(context);
        return;
    }
  }

  void _payFromWallet(BuildContext context) {
    if (!state.isPrepaidUser) {
      // Postpaid "charge to my account" does not use wallet balance, so submit
      // it directly without opening the prepaid wallet confirmation sheet.
      context.read<HomePlansPaymentMethodBloc>().add(
        const HomePlansChargeToAccountRequested(),
      );
      return;
    }

    // Keep the existing wallet confirmation and balance check for prepaid users.
    final balance = context.read<BalanceCubit>().state;
    PaymentSheetLauncher.openWallet(
      context,
      walletBalance: balance.walletBalance,
      walletBalanceText: BalanceCurrencyFormatterService.format(balance.walletBalance),
      amountText: state.amountText,
    );
  }
}
