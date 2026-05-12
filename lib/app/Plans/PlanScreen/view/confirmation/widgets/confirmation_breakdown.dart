import 'package:flutter/material.dart';

import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_payment_break_down_card.dart';

class ConfirmationBreakdown extends StatelessWidget {
  final String subTotalText;
  final String vatText;
  final String totalText;
  final String? promoValue;
  final ValueChanged<String>? onPromoChanged;
  final VoidCallback? onPromoApply;

  const ConfirmationBreakdown({
    super.key,
    required this.subTotalText,
    required this.vatText,
    required this.totalText,
    this.promoValue,
    this.onPromoChanged,
    this.onPromoApply,
  });

  bool get _showPromoInput => promoValue != null;

  @override
  Widget build(BuildContext context) {
    return CustomPaymentBreakDownCard(
      backgroundColor: HexColor.fromHex('#645D9C'),
      input: _showPromoInput
          ? CustomPaymentBreakdownInputConfig(
              value: promoValue!,
              hintText: 'promo code',
              actionText: 'apply',
              onChanged: onPromoChanged,
              onActionTap: onPromoApply,
            )
          : null,
      items: [
        CustomPaymentBreakdownLineItem(label: 'sub total', value: subTotalText),
        CustomPaymentBreakdownLineItem(label: 'vat', value: vatText),
        CustomPaymentBreakdownLineItem(label: 'total', value: totalText),
      ],
    );
  }
}
