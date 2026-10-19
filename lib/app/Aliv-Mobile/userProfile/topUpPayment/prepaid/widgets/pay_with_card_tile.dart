// PARKED 2026-05-19: Superseded by shared PaymentOptionTile (radio-style)
// in lib/resources/widgets/cards/payment_option_tile.dart.
// Reason: payment-method list was unified so saved cards, "pay with card",
// and "pay from wallet" all behave as radio-selectable items.
// To restore: uncomment, restore the import in top_up_payment_screen.dart.

/*
import 'package:flutter/material.dart';

import '../theme/top_up_payment_prepaid_theme.dart';


class PayWithCardTile extends StatelessWidget {
  final VoidCallback onTap;

  const PayWithCardTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 16),
        child: Row(
          children: [
            Icon(Icons.add, color: Color(0xFF5045A7), size: 22),
            const SizedBox(width: 10),
            Text(
              'pay with card',
              style: TextStyle(
                color: const Color(0xFF5045A7),
                fontSize: 13,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: TopUpPaymentPrepaidTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
*/
