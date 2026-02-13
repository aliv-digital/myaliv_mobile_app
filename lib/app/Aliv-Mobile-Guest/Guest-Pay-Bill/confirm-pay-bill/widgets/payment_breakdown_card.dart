import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/confirm-pay-bill/theme/guest_pay_bill_confirm_theme.dart';

class PaymentBreakdownCard extends StatelessWidget {
  const PaymentBreakdownCard({
    super.key,
    required this.subTotal,
    required this.vat,
    required this.total,
    this.currencySymbol = r'$',
    this.topCornerRadius = GuestPayBillConfirmTheme.breakdownTopCornerRadius,
    this.elevation = GuestPayBillConfirmTheme.breakdownElevation,
    this.ovalHeight = GuestPayBillConfirmTheme.breakdownOvalHeight,
    this.gap = GuestPayBillConfirmTheme.breakdownScallopGap,
    this.edgeInset = GuestPayBillConfirmTheme.breakdownEdgeInset,
    this.targetCount = GuestPayBillConfirmTheme.breakdownTargetScallopCount,
  });

  final double subTotal;
  final double vat;
  final double total;

  final String currencySymbol;
  final Color backgroundColor =
      GuestPayBillConfirmTheme.paymentBreakDownCardColor;

  final double topCornerRadius;
  final double elevation;

  // scallops
  final double ovalHeight;
  final double gap;
  final double edgeInset;

  final int targetCount;

  String _money(double v) => '$currencySymbol ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    const rowTextColor = Colors.white;

    return PhysicalShape(
      clipper: _FigmaOvalScallopBottomClipper(
        topCornerRadius: topCornerRadius,
        ovalHeight: ovalHeight,
        gap: gap,
        edgeInset: edgeInset,
        targetCount: targetCount,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: backgroundColor,
      elevation: elevation,
      shadowColor: const Color(0x22000000),
      child: Padding(
        padding: GuestPayBillConfirmTheme.breakdownPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RowItem(
              label: GuestPayBillConfirmTheme.subTotalLabel,
              value: _money(subTotal),
              textColor: rowTextColor,
            ),
            const SizedBox(height: GuestPayBillConfirmTheme.breakdownRowGap),
            _RowItem(
              label: GuestPayBillConfirmTheme.vatLabel,
              value: _money(vat),
              textColor: rowTextColor,
            ),
            const SizedBox(
                height: GuestPayBillConfirmTheme.breakdownGapBeforeDivider),
            const _DashedDivider(
              color: GuestPayBillConfirmTheme.breakdownDividerColor,
              height: GuestPayBillConfirmTheme.breakdownDividerHeight,
              dashWidth: GuestPayBillConfirmTheme.breakdownDividerDashWidth,
              dashGap: GuestPayBillConfirmTheme.breakdownDividerDashGap,
            ),
            const SizedBox(
                height: GuestPayBillConfirmTheme.breakdownGapAfterDivider),
            _RowItem(
              label: GuestPayBillConfirmTheme.totalLabel,
              value: _money(total),
              textColor: rowTextColor,
              isBold: false,
            ),
            const SizedBox(
                height: GuestPayBillConfirmTheme.breakdownBottomInnerGap),
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
    final style = isBold
        ? GuestPayBillConfirmTheme.breakdownRowEmphasis
        : GuestPayBillConfirmTheme.breakdownRow;

    return Row(
      children: [
        Expanded(child: Text(label, style: style.copyWith(color: textColor))),
        Text(value, style: style.copyWith(color: textColor)),
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
      final x2 = math.min(x + dashWidth, size.width);
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

class _FigmaOvalScallopBottomClipper extends CustomClipper<Path> {
  const _FigmaOvalScallopBottomClipper({
    required this.topCornerRadius,
    required this.ovalHeight,
    required this.gap,
    required this.edgeInset,
    required this.targetCount,
  });

  final double topCornerRadius;
  final double ovalHeight;
  final double gap;
  final double edgeInset;
  final int targetCount;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    // base: rounded top only
    final base = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, w, h),
          topLeft: Radius.circular(topCornerRadius),
          topRight: Radius.circular(topCornerRadius),
          bottomLeft: Radius.zero,
          bottomRight: Radius.zero,
        ),
      );

    final usableW = (w - 2 * edgeInset).clamp(0.0, w);
    if (usableW <= 0 || ovalHeight <= 0) return base;

    final count = targetCount.clamp(1, 200);

    final ovalWidth = (usableW - (count - 1) * gap) / count;

    if (ovalWidth <= 6) return base;

    final used = (count * ovalWidth) + ((count - 1) * gap);
    final startLeft = edgeInset + (usableW - used) / 2;

    final holes = Path();
    for (int i = 0; i < count; i++) {
      final left = startLeft + i * (ovalWidth + gap);
      final cx = left + ovalWidth / 2;

      holes.addOval(
        Rect.fromCenter(
          center: Offset(cx, h),
          width: ovalWidth,
          height: ovalHeight,
        ),
      );
    }

    return Path.combine(PathOperation.difference, base, holes);
  }

  @override
  bool shouldReclip(covariant _FigmaOvalScallopBottomClipper oldClipper) {
    return oldClipper.topCornerRadius != topCornerRadius ||
        oldClipper.ovalHeight != ovalHeight ||
        oldClipper.gap != gap ||
        oldClipper.edgeInset != edgeInset ||
        oldClipper.targetCount != targetCount;
  }
}
