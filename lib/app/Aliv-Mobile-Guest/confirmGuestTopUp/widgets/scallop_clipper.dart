import 'package:flutter/material.dart';

class ScallopBottomClipper extends CustomClipper<Path> {
  final double radius;

  const ScallopBottomClipper({this.radius = 8});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height - radius),
        const Radius.circular(12),
      ),
    );

    // scallops along bottom edge
    final scallopPath = Path();
    scallopPath.moveTo(0, size.height - radius);

    final diameter = radius * 2;
    final count = (size.width / diameter).ceil();
    final usedWidth = count * diameter;
    final startX = (size.width - usedWidth) / 2;

    scallopPath.lineTo(startX, size.height - radius);

    for (int i = 0; i < count; i++) {
      final x1 = startX + i * diameter;
      final x2 = x1 + diameter;

      scallopPath.quadraticBezierTo(
        x1 + radius,
        size.height,
        x2,
        size.height - radius,
      );
    }

    scallopPath.lineTo(size.width, size.height - radius);
    scallopPath.lineTo(size.width, 0);
    scallopPath.close();

    // keep top, cut bottom with scallops look by intersect-like technique:
    return Path.combine(PathOperation.intersect, path, scallopPath);
  }

  @override
  bool shouldReclip(covariant ScallopBottomClipper oldClipper) {
    return oldClipper.radius != radius;
  }
}
