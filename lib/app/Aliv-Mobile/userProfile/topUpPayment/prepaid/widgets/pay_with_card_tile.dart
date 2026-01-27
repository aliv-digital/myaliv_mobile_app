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
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
        child: Row(
          children: [
            Icon(Icons.add, color: TopUpPaymentPrepaidTheme.primary, size: 22),
            const SizedBox(width: 10),
            Text(
              'pay with card',
              style: TopUpPaymentPrepaidTheme.bodyMd(context).copyWith(
                color: TopUpPaymentPrepaidTheme.primary,
                fontWeight: FontWeight.w800,
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
