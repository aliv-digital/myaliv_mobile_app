import 'package:flutter/material.dart';

import '../bloc/make_payment_postpaid_event.dart';
import '../theme/make_payment_postpaid_theme.dart';
import 'mp_amount_field.dart';
import 'mp_amount_option_tile.dart';
import 'mp_custom_amount_field.dart';

class MpPaymentDueCard extends StatelessWidget {
  final String amountText;
  final MpAmountOption selectedOption;
  final String customAmount;
  final ValueChanged<MpAmountOption> onOptionChanged;
  final ValueChanged<String> onCustomAmountChanged;

  const MpPaymentDueCard({
    super.key,
    required this.amountText,
    required this.selectedOption,
    required this.customAmount,
    required this.onOptionChanged,
    required this.onCustomAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MakePaymentPostPaidTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x12000000),
          ),
        ],
      ),
      padding: MakePaymentPostPaidTheme.paymentDueCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('amount due', style: MakePaymentPostPaidTheme.sectionLabel),
          const SizedBox(
            height: MakePaymentPostPaidTheme.paymentDueTitleToAmountGap,
          ),
          MpAmountField(value: amountText),
          const SizedBox(
            height: MakePaymentPostPaidTheme.paymentDueAmountToOptionsGap,
          ),
          Row(
            children: [
              Expanded(
                child: MpAmountOptionTile(
                  label: 'pay current\namount',
                  isSelected: selectedOption == MpAmountOption.current,
                  onTap: () => onOptionChanged(MpAmountOption.current),
                ),
              ),
              const SizedBox(
                width: MakePaymentPostPaidTheme.paymentDueOptionsBetweenGap,
              ),
              Expanded(
                child: MpAmountOptionTile(
                  label: 'other\namount',
                  isSelected: selectedOption == MpAmountOption.other,
                  onTap: () => onOptionChanged(MpAmountOption.other),
                ),
              ),
            ],
          ),
          if (selectedOption == MpAmountOption.other) ...[
            const SizedBox(height: 12),
            Text(
              'enter a custom amount',
              style: MakePaymentPostPaidTheme.helperLabel,
            ),
            const SizedBox(height: 8),
            MpCustomAmountField(
              value: customAmount,
              onChanged: onCustomAmountChanged,
            ),
          ],
        ],
      ),
    );
  }
}
