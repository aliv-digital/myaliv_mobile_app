import 'package:flutter/material.dart';

class ScallopBottomClipper extends CustomClipper<Path> {
  final double radius;

  ScallopBottomClipper({this.radius = 10});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
      );

    // Cut semicircles at bottom
    final scallop = Path();
    final diameter = radius * 2;
    final count = (size.width / diameter).floor();

    for (int i = 0; i < count; i++) {
      final cx = (i * diameter) + radius;
      scallop.addOval(
        Rect.fromCircle(center: Offset(cx, size.height), radius: radius),
      );
    }

    return Path.combine(PathOperation.difference, path, scallop);
  }

  @override
  bool shouldReclip(covariant ScallopBottomClipper oldClipper) {
    return oldClipper.radius != radius;
  }
}
