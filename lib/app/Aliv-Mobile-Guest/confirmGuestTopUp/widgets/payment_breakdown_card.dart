import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/theme.dart';

class PaymentBreakdownCard extends StatelessWidget {
  const PaymentBreakdownCard({
    super.key,
    required this.subTotal,
    required this.vat,
    required this.total,
    this.currencySymbol = r'$',
    this.backgroundColor = TopUpConfirmTheme.breakdownBackgroundColor,
  });

  final double subTotal;
  final double vat;
  final double total;

  final String currencySymbol;
  final Color backgroundColor;

  String _money(double v) => '$currencySymbol ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: const _ScallopBottomClipper(
        cornerRadius: TopUpConfirmTheme.breakdownCardRadius,
        scallopCount: TopUpConfirmTheme.breakdownScallopCount,
        scallopGap: TopUpConfirmTheme.breakdownScallopGap,
        scallopDepth: TopUpConfirmTheme.breakdownScallopDepth,
        scallopSideInset: TopUpConfirmTheme.breakdownScallopSideInset,
      ),
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      elevation: TopUpConfirmTheme.breakdownElevation,
      shadowColor: TopUpConfirmTheme.payBarShadowColor,
      child: Padding(
        padding: TopUpConfirmTheme.breakdownCardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RowItem(
              label: 'sub total',
              value: _money(subTotal),
              textColor: TopUpConfirmTheme.breakdownTextColor,
            ),
            const SizedBox(height: TopUpConfirmTheme.breakdownRowGap),
            _RowItem(
              label: 'vat',
              value: _money(vat),
              textColor: TopUpConfirmTheme.breakdownTextColor,
            ),
            const SizedBox(height: TopUpConfirmTheme.breakdownGapBeforeDivider),
            const _DashedDivider(
              color: TopUpConfirmTheme.breakdownDashColor,
              height: TopUpConfirmTheme.breakdownDashHeight,
              dashWidth: TopUpConfirmTheme.breakdownDashWidth,
              dashGap: TopUpConfirmTheme.breakdownDashGap,
            ),
            const SizedBox(height: TopUpConfirmTheme.breakdownGapAfterDivider),
            _RowItem(
              label: 'total',
              value: _money(total),
              textColor: TopUpConfirmTheme.breakdownTextColor,
              isBold: false,
            ),
            const SizedBox(height: TopUpConfirmTheme.breakdownBottomInnerGap),
          ],
        ),
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.label,
    required this.value,
    required this.textColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color textColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final baseStyle = isBold
        ? TopUpConfirmTheme.breakdownEmphasizedText
        : TopUpConfirmTheme.breakdownText;
    final style = baseStyle.copyWith(color: textColor);

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({
    required this.color,
    required this.height,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double height;
  final double dashWidth;
  final double dashGap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _DashedDividerPainter(
          color: color,
          strokeWidth: height,
          dashWidth: dashWidth,
          dashGap: dashGap,
        ),
      ),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  _DashedDividerPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double x = 0;
    final y = size.height / 2;

    while (x < size.width) {
      final double x2 = math.min(x + dashWidth, size.width);

      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);

      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}

/// Cuts half-circle "bites" from the bottom edge.
class _ScallopBottomClipper extends CustomClipper<Path> {
  const _ScallopBottomClipper({
    required this.cornerRadius,
    required this.scallopCount,
    required this.scallopGap,
    required this.scallopSideInset,
    this.scallopDepth = 6,
  });

  final double cornerRadius;
  final int scallopCount;
  final double scallopGap;
  final double scallopSideInset;

  /// Scallop cut depth; clamped to computed scallop radius.
  final double scallopDepth;

  @override
  Path getClip(Size size) {
    final base = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, size.width, size.height),
          topLeft: Radius.circular(cornerRadius),
          topRight: Radius.circular(cornerRadius),
        ),
      );

    final holes = Path();

    // Keep a small horizontal inset so the first/last scallops align like design.
    final leftLimit = scallopSideInset;
    final rightLimit = size.width - scallopSideInset;

    final usableWidth = (rightLimit - leftLimit).clamp(0.0, size.width);
    final count = scallopCount.clamp(1, 9999);
    final totalGap = (count - 1) * scallopGap;
    final diameter = ((usableWidth - totalGap) / count).clamp(0.0, usableWidth);
    final scallopRadius = diameter / 2;
    if (scallopRadius <= 0) {
      return base;
    }
    final step = diameter + scallopGap;
    final startX = leftLimit + scallopRadius;

    final depth = scallopDepth.clamp(0.0, scallopRadius);
    final centerYOffset = scallopRadius - depth;
    final centerY = size.height + centerYOffset;

    for (int i = 0; i < count; i++) {
      final cx = startX + i * step;

      holes.addOval(
        Rect.fromCircle(
          center: Offset(cx, centerY),
          radius: scallopRadius,
        ),
      );
    }

    return Path.combine(PathOperation.difference, base, holes);
  }

  @override
  bool shouldReclip(covariant _ScallopBottomClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.scallopCount != scallopCount ||
        oldClipper.scallopGap != scallopGap ||
        oldClipper.scallopSideInset != scallopSideInset ||
        oldClipper.scallopDepth != scallopDepth;
  }
}
