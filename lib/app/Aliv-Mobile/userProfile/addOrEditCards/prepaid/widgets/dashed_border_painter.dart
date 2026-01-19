import 'dart:math' as math;
import 'package:flutter/material.dart';

class DeepDashedRRectPainter extends CustomPainter {
  final Color color;

  /// main stroke
  final double strokeWidth;

  /// halo stroke (drawn behind main dash to increase visibility)
  final double haloWidth;
  final double haloOpacity;

  final double radius;
  final double dash;
  final double gap;

  const DeepDashedRRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.haloWidth,
    required this.haloOpacity,
    required this.radius,
    required this.dash,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(radius, size.height / 2);

    // ✅ keep stroke inside bounds
    final rect = Rect.fromLTWH(
      haloWidth / 2,
      haloWidth / 2,
      size.width - haloWidth,
      size.height - haloWidth,
    );

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)));

    // 1) halo paint (behind)
    final haloPaint = Paint()
      ..isAntiAlias = true
      ..color = color.withOpacity(haloOpacity)
      ..strokeWidth = haloWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 2) main paint (front)
    final mainPaint = Paint()
      ..isAntiAlias = true
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final len = math.min(dash, metric.length - distance);
        final seg = metric.extractPath(distance, distance + len);

        // ✅ draw halo first, then main (makes dash "deep")
        canvas.drawPath(seg, haloPaint);
        canvas.drawPath(seg, mainPaint);

        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DeepDashedRRectPainter old) {
    return old.color != color ||
        old.strokeWidth != strokeWidth ||
        old.haloWidth != haloWidth ||
        old.haloOpacity != haloOpacity ||
        old.radius != radius ||
        old.dash != dash ||
        old.gap != gap;
  }
}
