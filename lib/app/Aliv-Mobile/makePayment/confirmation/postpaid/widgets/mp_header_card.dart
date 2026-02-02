import 'package:flutter/material.dart';

import '../theme/make_payment_confirmation_postpaid_theme.dart';

class MpHeaderCard extends StatelessWidget {
  final String customerName;
  final String accountNumber;
  final String headerLabel;
  final String amountText;

  const MpHeaderCard({
    super.key,
    required this.customerName,
    required this.accountNumber,
    required this.headerLabel,
    required this.amountText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MakePaymentConfirmationPostPaidTheme.cardBg,
        borderRadius:
            BorderRadius.circular(MakePaymentConfirmationPostPaidTheme.cardRadius),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: MakePaymentConfirmationPostPaidTheme.name,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    accountNumber,
                    style: MakePaymentConfirmationPostPaidTheme.accountNumber,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE6E6F2)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    headerLabel,
                    style: MakePaymentConfirmationPostPaidTheme.headerLabel,
                  ),
                ),
                _AmountPill(text: amountText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountPill extends StatelessWidget {
  final String text;

  const _AmountPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MakePaymentConfirmationPostPaidTheme.amountPillBg,
        borderRadius:
            BorderRadius.circular(MakePaymentConfirmationPostPaidTheme.pillRadius),
        border: Border.all(
          color: MakePaymentConfirmationPostPaidTheme.amountPillBorder,
          width: 1,
        ),
      ),
      child: Text(text, style: MakePaymentConfirmationPostPaidTheme.amountPill),
    );
  }
}
