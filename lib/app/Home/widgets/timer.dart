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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
