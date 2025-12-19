import 'dart:math' as math;

import 'package:flutter/material.dart';

class PaymentBreakdownCard extends StatelessWidget {
  const PaymentBreakdownCard({
    super.key,
    required this.subTotal,
    required this.vat,
    required this.total,
    this.currencySymbol = r'$',
    this.backgroundColor = const Color(0xFF6B63A7),
  });

  final double subTotal;
  final double vat;
  final double total;

  final String currencySymbol;
  final Color backgroundColor;

  String _money(double v) => '$currencySymbol ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;

    return PhysicalShape(
      clipper: const _ScallopBottomClipper(
        cornerRadius: 14,
        scallopRadius: 10,
        scallopGap: 6,
        scallopDepth: 5
      ),
      clipBehavior: Clip.antiAlias,
      color: backgroundColor,
      elevation: 10,
      shadowColor: const Color(0x22000000),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RowItem(
              label: 'sub total',
              value: _money(subTotal),
              textColor: textColor,
            ),
            const SizedBox(height: 14),
            _RowItem(
              label: 'vat',
              value: _money(vat),
              textColor: textColor,
            ),
            const SizedBox(height: 16),

            // dashed divider
            const _DashedDivider(
              color: Color(0xB3FFFFFF),
              height: 1,
              dashWidth: 6,
              dashGap: 5,
            ),

            const SizedBox(height: 16),
            _RowItem(
              label: 'total',
              value: _money(total),
              textColor: textColor,
              isBold: false, // screenshot like normal weight
            ),

            // give some breathing room above scallops
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
    required this.textColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color textColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: textColor,
      fontSize: 15,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
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
    required this.scallopRadius,
    required this.scallopGap,
    this.scallopDepth = 6, // ✅ depth কমাতে এটা টিউন করবে
  });

  final double cornerRadius;
  final double scallopRadius;
  final double scallopGap;

  /// ✅ scallop cut কতটা উপরে উঠবে (depth).
  /// must be <= scallopRadius
  final double scallopDepth;

  @override
  Path getClip(Size size) {
    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(cornerRadius),
        ),
      );

    final holes = Path();

    final diameter = scallopRadius * 2;
    final step = diameter + scallopGap;

    final leftLimit = cornerRadius + 8;
    final rightLimit = size.width - cornerRadius - 8;

    final usableWidth = rightLimit - leftLimit;
    final count = (usableWidth / step).floor().clamp(0, 9999);

    final used = count * step - scallopGap;
    final startX = leftLimit + (usableWidth - used) / 2 + scallopRadius;

    // depth কমাতে center কে নিচে নামানো
    final depth = scallopDepth.clamp(0.0, scallopRadius);
    final centerYOffset = scallopRadius - depth; // depth কম হলে offset বেশি
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
        oldClipper.scallopRadius != scallopRadius ||
        oldClipper.scallopGap != scallopGap ||
        oldClipper.scallopDepth != scallopDepth;
  }
}
