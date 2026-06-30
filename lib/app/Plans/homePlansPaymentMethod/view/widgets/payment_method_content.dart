import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/widgets/home_plans_payment_method_section.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';

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
      builder: (context, balance) => _section(context, balance),
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
