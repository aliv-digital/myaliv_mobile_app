import 'package:flutter/material.dart';

class OutlinedAmountText extends StatelessWidget {
  const OutlinedAmountText({super.key});

  static const Color fillColor = Color(0xFF5146A8); // purple
  static const Color strokeColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stroke
        Text(
          '\$129.00',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = strokeColor,
          ),
        ),

        // Fill
        const Text(
          '\$129.00',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: fillColor,
          ),
        ),
      ],
    );
  }
}
