import 'package:flutter/material.dart';

class LoginBottomStripes extends StatelessWidget {
  const LoginBottomStripes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _Stripe(color: Color(0xFFF26C4F), height: 8), // উপরের কমলা
        _Stripe(color: Color(0xFFE89BB8), height: 6), // হালকা পিংক
        _Stripe(color: Color(0xFF000000), height: 6), // কালো
        _Stripe(color: Color(0xFF6ECFF6), height: 6), // লাইট ব্লু
        _Stripe(color: Color(0xFFFBB03B), height: 8), // নিচের হলুদ/কমলা
      ],
    );
  }
}

class _Stripe extends StatelessWidget {
  final Color color;
  final double height;

  const _Stripe({required this.color, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: color,
    );
  }
}
