import 'package:flutter/material.dart';
import '../theme/auto_renew_prepaid_theme.dart';
import 'dashed_border_painter.dart';

class DashedAddCardButton extends StatelessWidget {
  final VoidCallback onTap;

  const DashedAddCardButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const radius = 999.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: double.infinity, // ✅ full width
        child: CustomPaint(
          painter: const DashedBorderPainter(
            color: AutoRenewPrepaidTheme.dashedBorder,
            radius: radius, // ✅ pill radius
            strokeWidth: 1.2,
            dashLength: 6,
            gapLength: 5,
          ),
          child: Container(
            height: 56, // ✅ match figma better
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AutoRenewPrepaidTheme.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'add a new card',
                  style: TextStyle(
                    color: AutoRenewPrepaidTheme.primary,
                    fontSize: 14,
                    fontFamily: AutoRenewPrepaidTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
