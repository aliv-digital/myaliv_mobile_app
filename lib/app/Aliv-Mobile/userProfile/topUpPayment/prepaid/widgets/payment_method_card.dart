import 'package:flutter/material.dart';
import '../theme/top_up_payment_prepaid_theme.dart';

class PaymentMethodCard extends StatelessWidget {
  final Widget child;

  const PaymentMethodCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TopUpPaymentPrepaidTheme.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Color(0x22000000),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}
