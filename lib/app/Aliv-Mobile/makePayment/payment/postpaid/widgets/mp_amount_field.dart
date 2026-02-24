import 'package:flutter/material.dart';

import '../theme/make_payment_postpaid_theme.dart';

class MpAmountField extends StatelessWidget {
  final String value;

  const MpAmountField({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final sanitizedValue = value.replaceAll(r'$', '').trim();

    return Container(
      height: 38,
      alignment: Alignment.centerLeft,
      padding: MakePaymentPostPaidTheme.paymentDueAmountFieldPadding,
      decoration: BoxDecoration(
        color: MakePaymentPostPaidTheme.amountFieldBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(r'$', style: MakePaymentPostPaidTheme.amountText),
          SizedBox(
            width: MakePaymentPostPaidTheme.paymentDueCurrencyToValueGap,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MakePaymentPostPaidTheme
                  .paymentDueAmountValueHorizontalPadding,
            ),
            child: Text(
              sanitizedValue,
              style: MakePaymentPostPaidTheme.amountText,
            ),
          ),
        ],
      ),
    );
  }
}
