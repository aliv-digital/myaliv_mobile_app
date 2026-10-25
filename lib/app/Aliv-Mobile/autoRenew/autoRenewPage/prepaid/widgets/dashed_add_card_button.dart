import 'package:flutter/material.dart';
import '../theme/auto_renew_prepaid_theme.dart';
import 'dashed_border_painter.dart';

class DashedAddCardButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isLoading;

  const DashedAddCardButton({
    super.key,
    required this.onTap,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    const radius = AutoRenewPrepaidTheme.pillRadius;

    return InkWell(
      onTap: isEnabled && !isLoading ? onTap : null,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: AutoRenewPrepaidTheme.addCardIconSize,
                    height: AutoRenewPrepaidTheme.addCardIconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AutoRenewPrepaidTheme.primary,
                    ),
                  )
                else
                  const Icon(
                    Icons.add,
                    color: AutoRenewPrepaidTheme.primary,
                    size: AutoRenewPrepaidTheme.addCardIconSize,
                  ),
                const SizedBox(width: AutoRenewPrepaidTheme.addCardIconTextGap),
                const Text(
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
