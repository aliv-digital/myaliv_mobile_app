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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 2, color: borderColor),
      ),
      child: Text(
        amountText,
        style: TopUpConfirmTheme.amountPillText.copyWith(color: textColor),
      ),
    );
  }
}
