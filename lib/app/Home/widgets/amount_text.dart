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
            color: const Color(0xFF5045A7),
            fontSize: 24,
            fontFamily: 'Circular Pro',
            fontWeight: FontWeight.w700,
          ),
        )
      ],
    );
  }
}
