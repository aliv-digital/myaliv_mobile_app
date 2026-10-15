import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/theme/theme.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/widgets/home_plans_payment_method_section.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

/// Renders the saved-methods / actions section, wired to bloc events.
class PaymentMethodContent extends StatelessWidget {
  final HomePlansPaymentMethodState state;
  final bool isLoading;

  const PaymentMethodContent({
    super.key,
    required this.state,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return BlocBuilder<BalanceCubit, BalanceState>(
      builder: (context, balance) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.hasInsufficientWalletBalance(balance.walletBalance)) ...[
            _walletWarning(context),
            const SizedBox(height: 16),
          ],
          _section(context, balance),
        ],
      ),
    );
  }

  Widget _walletWarning(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: HomePlanTheme.warningBackground,
        border: Border.all(color: HomePlanTheme.warningBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: HomePlanTheme.warningText, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'insufficient fund in your wallet, please top up and try again.',
                  style: HomePlanTheme.bottomSheetWarning,
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => context.push(AppRoutes.topUpPrepaidScreen),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'add top-up',
                        style: HomePlanTheme.bottomSheetWarning.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: HomePlanTheme.warningText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: HomePlanTheme.warningText,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, BalanceState balance) {
    final bloc = context.read<HomePlansPaymentMethodBloc>();
    return HomePlansPaymentMethodSection(
      methods: state.methods,
      selectedId: state.selectedMethodId,
      paymentMode: state.paymentMode,
      showPayFromWallet: state.isPrepaidUser,
      walletBalanceText: BalanceCurrencyFormatterService.format(
        balance.walletBalance,
      ),
      onSelect: (id) => bloc.add(HomePlansPaymentMethodSelected(id)),
      onChargeToAccountSelect: (id) =>
          bloc.add(HomePlansChargeToAccountSelected(id)),
      onPayWithCard: () => bloc.add(const HomePlansPayWithCardPressed()),
      onPayFromWallet: () => bloc.add(const HomePlansPayFromWalletPressed()),
    );
  }
}
