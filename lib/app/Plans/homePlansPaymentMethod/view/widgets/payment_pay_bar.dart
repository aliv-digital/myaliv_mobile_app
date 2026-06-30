import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
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
        // TODO: open add-card flow when route is ready.
        return;
    }
  }

  void _payFromWallet(BuildContext context) {
    final balance = context.read<BalanceCubit>().state;
    PaymentSheetLauncher.openWallet(
      context,
      walletBalance: balance.walletBalance,
      walletBalanceText:
          BalanceCurrencyFormatterService.format(balance.walletBalance),
      amountText: state.amountText,
    );
  }
}
