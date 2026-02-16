import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/rev_confirmation_prepaid_theme.dart';
import 'rev_promo_code_field.dart';

class RevReceiptPanel extends StatelessWidget {
  final String promoCode;
  final bool canApply;
  final VoidCallback onApply;
  final ValueChanged<String> onPromoChanged;

  final String subTotalText;
  final String vatText;
  final String totalText;

  const RevReceiptPanel({
    super.key,
    required this.promoCode,
    required this.canApply,
    required this.onApply,
    required this.onPromoChanged,
    required this.subTotalText,
    required this.vatText,
    required this.totalText,
  });

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      clipper: const _FigmaOvalScallopBottomClipper(
        topCornerRadius: 18,
        ovalHeight: 15,
        gap: 8,
        edgeInset: 0,
        targetCount: 12, // adjust if figma shows different count
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: RevConfirmationPrepaidTheme.receiptBg,
      elevation: 0, // figma-style flat (bottom bar handles shadow)
      shadowColor: const Color(0x22000000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RevPromoCodeField(
              value: promoCode,
              canApply: canApply,
              onApply: onApply,
              onChanged: onPromoChanged,
            ),
            const SizedBox(height: 18),

            _RowItem(label: 'sub total', value: subTotalText),
            const SizedBox(height: 14),
            _RowItem(label: 'vat', value: vatText),
            const SizedBox(height: 24),

            const _DashedDivider(
              color: Color(0xB3FFFFFF),
              height: 1,
              dashWidth: 6,
              dashGap: 5,
            ),

            const SizedBox(height: 24),
            _RowItem(label: 'total', value: totalText, isBold: true),

            const SizedBox(height: 18),
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
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: RevConfirmationPrepaidTheme.fontFamily,
      color: Colors.white,
      fontSize: 14,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      height: 1.1,
    );

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
      final x2 = math.min(x + dashWidth, size.width);
      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.dashWidth != dashWidth ||
        old.dashGap != dashGap;
  }
}

/// ✅ EXACT your figma-like clipper (OVAL + FLAT GAP + EXACT COUNT)
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

    // total = count*ovalWidth + (count-1)*gap
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
  bool shouldReclip(covariant _FigmaOvalScallopBottomClipper old) {
    return old.topCornerRadius != topCornerRadius ||
        old.ovalHeight != ovalHeight ||
        old.gap != gap ||
        old.edgeInset != edgeInset ||
        old.targetCount != targetCount;
  }
}
