import 'package:flutter/material.dart';

class DashedDivider extends StatelessWidget {
  final double height;
  final double dashWidth;
  final double dashGap;
  final Color color;

  const DashedDivider({
    super.key,
    this.height = 1,
    this.dashWidth = 6,
    this.dashGap = 6,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedPainter(
          dashWidth: dashWidth,
          dashGap: dashGap,
          color: color,
          strokeWidth: height,
        ),
      ),
    );
  }
}

class _DashedPainter extends CustomPainter {
  final double dashWidth;
  final double dashGap;
  final Color color;
  final double strokeWidth;

  _DashedPainter({
    required this.dashWidth,
    required this.dashGap,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = 0;
    final y = size.height / 2;

    while (x < size.width) {
      final x2 = (x + dashWidth)
          .clamp(0.0, size.width)
          .toDouble(); // ✅ no num issue
      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter oldDelegate) {
    return oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
