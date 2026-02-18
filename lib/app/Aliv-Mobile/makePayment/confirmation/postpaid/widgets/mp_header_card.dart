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
            padding: MakePaymentConfirmationPostPaidTheme.headerTopSectionPadding,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: MakePaymentConfirmationPostPaidTheme.name,
                  ),
                  const SizedBox(
                    height: MakePaymentConfirmationPostPaidTheme
                        .headerNameToAccountGap,
                  ),
                  Text(
                    accountNumber,
                    style: MakePaymentConfirmationPostPaidTheme.accountNumber,
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            height: MakePaymentConfirmationPostPaidTheme.headerDividerThickness,
            thickness: MakePaymentConfirmationPostPaidTheme.headerDividerThickness,
            color: MakePaymentConfirmationPostPaidTheme.headerDividerColor,
          ),
          Padding(
            padding:
                MakePaymentConfirmationPostPaidTheme.headerBottomSectionPadding,
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
      padding: MakePaymentConfirmationPostPaidTheme.amountPillPadding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MakePaymentConfirmationPostPaidTheme.amountPillBg,
        borderRadius:
            BorderRadius.circular(MakePaymentConfirmationPostPaidTheme.pillRadius),
      ),
      child: Text(text, style: MakePaymentConfirmationPostPaidTheme.amountPill),
    );
  }
}
