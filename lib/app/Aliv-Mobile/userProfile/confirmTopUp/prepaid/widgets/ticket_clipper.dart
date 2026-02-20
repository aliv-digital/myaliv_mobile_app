import 'package:flutter/material.dart';

class TicketClipper extends CustomClipper<Path> {
  final double radius;
  final int notchCount;

  TicketClipper({this.radius = 10, this.notchCount = 10});

  @override
  Path getClip(Size size) {
    // Base rounded ticket shape
    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(18),
        ),
      );

    // Holes (semi-circles) at bottom edge
    final holes = Path();
    final usableWidth = size.width - 24;
    // final gap = usableWidth / notchCount;
    final startX = 12.0;
    final gap = size.width / notchCount;
    for (int i = 0; i < notchCount; i++) {
      final cx = startX + (i * gap) + gap / 2;
      holes.addOval(
        Rect.fromCircle(
          center: Offset(cx, size.height),
          radius: radius,
        ),
      );
    }

    // Subtract holes from base
    return Path.combine(PathOperation.difference, base, holes);
  }

  @override
  bool shouldReclip(covariant TicketClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.notchCount != notchCount;
  }
}
