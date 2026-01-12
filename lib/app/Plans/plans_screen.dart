import 'package:flutter/material.dart';

class PlansScreen1 extends StatelessWidget {
  const PlansScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Center(
          child: Text(
            'Plans',
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
