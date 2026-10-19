import 'package:flutter/material.dart';
import '../theme/auto_renew_prepaid_theme.dart';
import 'dashed_border_painter.dart';

class DashedAddCardButton extends StatelessWidget {
  final VoidCallback onTap;

  const DashedAddCardButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const radius = AutoRenewPrepaidTheme.pillRadius;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: double.infinity,
        child: CustomPaint(
          painter: const DashedBorderPainter(
            color: AutoRenewPrepaidTheme.dashedBorder,
            radius: radius,
            strokeWidth: AutoRenewPrepaidTheme.dashedStrokeWidth,
            dashLength: AutoRenewPrepaidTheme.dashedDashLength,
            gapLength: AutoRenewPrepaidTheme.dashedGapLength,
          ),
          child: Container(
            height: AutoRenewPrepaidTheme.primaryButtonHeight,
            width: double.infinity,
            alignment: Alignment.center,
            padding: AutoRenewPrepaidTheme.addCardButtonPadding,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: AutoRenewPrepaidTheme.primary,
                  size: AutoRenewPrepaidTheme.addCardIconSize,
                ),
                SizedBox(width: AutoRenewPrepaidTheme.addCardIconTextGap),
                Text(
                  'add a new card',
                  style: AutoRenewPrepaidTheme.addCardButtonTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
