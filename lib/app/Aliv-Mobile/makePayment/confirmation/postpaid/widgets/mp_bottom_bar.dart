import 'package:flutter/material.dart';

import '../theme/make_payment_confirmation_postpaid_theme.dart';

class MpBottomBar extends StatelessWidget {
  final String amountText;
  final String subtitle;
  final VoidCallback onContinue;

  const MpBottomBar({
    super.key,
    required this.amountText,
    required this.subtitle,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
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
                  Text(amountText, style: MakePaymentConfirmationPostPaidTheme.bottomAmount),
                  const SizedBox(height: 2),
                  Text(subtitle, style: MakePaymentConfirmationPostPaidTheme.bottomSubtitle),
                ],
              ),
            ),
            SizedBox(
              width: 200,
              height: 44,
              child: InkWell(
                onTap: onContinue,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MakePaymentConfirmationPostPaidTheme.continueBtnBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    'continue',
                    style: MakePaymentConfirmationPostPaidTheme.continueText,
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
