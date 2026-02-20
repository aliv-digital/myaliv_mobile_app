import 'package:flutter/material.dart';

class TimerBox extends StatelessWidget {
  final String value;
  final String label;
  final bool compact;

  const TimerBox(this.value, this.label, {super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final labelSize = compact ? 9.0 : 10.0;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 3, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 10);

    return Container(
      height: 64,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              color: Color(0xFF0F1313),
              fontSize: 20,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: const Color(0xFF0F1313),
              fontSize: labelSize,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}
