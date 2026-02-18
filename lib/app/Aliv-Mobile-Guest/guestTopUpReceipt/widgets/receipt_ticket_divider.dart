import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/theme/theme.dart';

class ReceiptTicketDivider extends StatelessWidget {
  const ReceiptTicketDivider({
    super.key,
    this.dashColor,
    this.height = 22,
  });

  final Color? dashColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(
          color: dashColor ?? ReceiptTheme.defaultDashColor,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const dashWidth = 5.0;
    const dashGap = 4.0;

    double x = 0;
    final y = size.height / 2;

    while (x < size.width) {
      final x2 = math.min(x + dashWidth, size.width);
      canvas.drawLine(Offset(x, y), Offset(x2, y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
