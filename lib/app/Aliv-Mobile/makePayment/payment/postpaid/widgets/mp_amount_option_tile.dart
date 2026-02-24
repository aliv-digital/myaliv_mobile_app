import 'package:flutter/material.dart';

import '../theme/make_payment_postpaid_theme.dart';

class MpAmountOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MpAmountOptionTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = MakePaymentPostPaidTheme.border;
    const bgColor = Colors.white;
    final textStyle = isSelected
        ? MakePaymentPostPaidTheme.optionTextSelected
        : MakePaymentPostPaidTheme.optionText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: MakePaymentPostPaidTheme.paymentDueOptionTilePadding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(label, style: textStyle),
            ),
            const SizedBox(
              width:
                  MakePaymentPostPaidTheme.paymentDueOptionTextToIndicatorGap,
            ),
            _SelectionIndicator(selected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool selected;

  const _SelectionIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    final border = selected
        ? MakePaymentPostPaidTheme.radioSelectedBorder
        : MakePaymentPostPaidTheme.radioBorder;

    return Container(
      width: MakePaymentPostPaidTheme.amountOptionIndicatorSize,
      height: MakePaymentPostPaidTheme.amountOptionIndicatorSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: border,
          width: MakePaymentPostPaidTheme.amountOptionIndicatorBorderWidth,
        ),
        color: selected
            ? MakePaymentPostPaidTheme.radioSelectedFill
            : MakePaymentPostPaidTheme.radioFill,
      ),
      child: selected
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}
