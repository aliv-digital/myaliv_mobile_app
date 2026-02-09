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
                fontFamily: 'Circular Pro',
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
