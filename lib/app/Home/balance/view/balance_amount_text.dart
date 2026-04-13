import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';

/// Reusable widget to display balance amount from BalanceCubit
///
/// Usage:
/// - BalanceAmountText(type: BalanceType.wallet) - for wallet/top-up balance
/// - BalanceAmountText(type: BalanceType.bonus) - for bonus/reward balance
class BalanceAmountText extends StatelessWidget {
  final BalanceType type;
  final TextStyle? style;

  const BalanceAmountText({
    super.key,
    required this.type,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalanceCubit, BalanceState>(
      builder: (context, state) {
        final balance = type == BalanceType.wallet
            ? state.walletBalanceFormatted
            : state.bonusBalanceFormatted;

        return Text(
          '\$$balance',
          style: style ??
              const TextStyle(
                color: Color(0xFF5045A7),
                fontSize: 24,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
        );
      },
    );
  }
}

/// Type of balance to display
enum BalanceType {
  wallet, // Top-up balance / Balance due (postpaid)
  bonus, // Reward balance
}
