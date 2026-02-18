import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimerBox extends StatelessWidget {
  final String value;
  final String label;

  const TimerBox(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: const Color(0xFF0F1313),
                fontSize: 20,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.10,
              ),
            ),
            // const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: const Color(0xFF0F1313),
                fontSize: 10,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.05,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
