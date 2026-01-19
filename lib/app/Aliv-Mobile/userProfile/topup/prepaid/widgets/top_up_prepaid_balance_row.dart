import 'package:flutter/material.dart';
import '../theme/top_up_prepaid_theme.dart';

class TopUpPrepaidBalanceRow extends StatelessWidget {
  final double balance;

  const TopUpPrepaidBalanceRow({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_balance_wallet_outlined, size: 18, color: TopUpPrepaidTheme.primary),
        const SizedBox(width: 8),
        Text('Current Balance', style: TopUpPrepaidTheme.balanceLabel()),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: TopUpPrepaidTheme.pillBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text('\$${balance.toStringAsFixed(2)}', style: TopUpPrepaidTheme.pillText()),
        ),
      ],
    );
  }
}
