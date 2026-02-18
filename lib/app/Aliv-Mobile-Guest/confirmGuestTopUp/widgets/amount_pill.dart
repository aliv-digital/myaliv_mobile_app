import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AmountPill extends StatelessWidget {
  const AmountPill({
    super.key,
    required this.amountText,
    required this.borderColor,
    required this.textColor,
  });

  final String amountText;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TopUpConfirmTheme.amountPillHorizontalPadding,
        vertical: TopUpConfirmTheme.amountPillVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: TopUpConfirmTheme.amountPillBackgroundColor,
        borderRadius: BorderRadius.circular(TopUpConfirmTheme.amountPillRadius),
        border: Border.all(
          width: TopUpConfirmTheme.amountPillBorderWidth,
          color: borderColor,
        ),
      ),
      child: Text(
        amountText,
        style: TopUpConfirmTheme.amountPillText.copyWith(color: textColor),
      ),
    );
  }
}
