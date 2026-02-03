import 'package:flutter/material.dart';

import '../theme/make_payment_postpaid_theme.dart';

class MpBottomBar extends StatelessWidget {
  final String amountText;
  final String subtitle;
  final bool enabled;
  final VoidCallback onPayNow;

  const MpBottomBar({
    super.key,
    required this.amountText,
    required this.subtitle,
    required this.enabled,
    required this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = enabled
        ? MakePaymentPostPaidTheme.primary
        : MakePaymentPostPaidTheme.payButtonDisabled;

    return Container(
      decoration: const BoxDecoration(
        color: MakePaymentPostPaidTheme.bottomBarBg,
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, -6),
            color: Color(0x14000000),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(amountText, style: MakePaymentPostPaidTheme.bottomAmount),
                  const SizedBox(height: 2),
                  Text(subtitle, style: MakePaymentPostPaidTheme.bottomSubtitle),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              height: 40,
              child: InkWell(
                onTap: enabled ? onPayNow : null,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Opacity(
                    opacity: enabled ? 1 : 0.7,
                    child: Text('pay now', style: MakePaymentPostPaidTheme.payNow),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
