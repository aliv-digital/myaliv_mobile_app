import 'package:flutter/material.dart';

class EnterPasswordAutoRenewPrepaidOrDivider extends StatelessWidget {
  const EnterPasswordAutoRenewPrepaidOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width:23,
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFF8A8A8F),
          ),
        ),
        SizedBox(width: 4),
        Text(
          'Or Continue with',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF8A8A8F),
            fontSize: 13,
            fontFamily: 'Circular Pro',
            fontWeight: FontWeight.w500,
            height: 1.38,
            letterSpacing: -0.08,
          ),
        ),
        SizedBox(width: 4),
        SizedBox(
          width:23,
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFF8A8A8F),
          ),
        ),
      ],
    );
  }
}
