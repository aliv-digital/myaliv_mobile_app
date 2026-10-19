import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';

import '../bloc/make_payment_postpaid_state.dart';
import '../theme/make_payment_postpaid_theme.dart';
import '../view/make_payment_amount_resolver.dart';
import '../view/make_payment_postpaid_pay_flow.dart';

/// Bottom "pay now" bar. Reads the amount + gating flags off the current
/// state and delegates the tap to [MakePaymentPostPaidPayFlow].
class MpPayBottomBar extends StatelessWidget {
  const MpPayBottomBar({super.key, required this.state});

  final MakePaymentPostPaidState state;

  @override
  Widget build(BuildContext context) {
    return DefaultBottomPayBar(
      amountText: BalanceCurrencyFormatterService.format(
        resolveMpAmountToCharge(state),
      ),
      isButtonEnabled: state.canPayNow,
      isLoading: state.isBusy,
      backgroundColor: MakePaymentPostPaidTheme.bottomBarBg,
      buttonColor: MakePaymentPostPaidTheme.primary,
      disabledButtonColor: MakePaymentPostPaidTheme.payButtonDisabled,
      onPayNow: () => MakePaymentPostPaidPayFlow.onPayNow(context, state),
    );
  }
}
