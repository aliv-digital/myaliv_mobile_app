import 'package:flutter/material.dart';

class EnterPasswordPrepaidOrDivider extends StatelessWidget {
  const EnterPasswordPrepaidOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(
          width: 23,
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE6E6EC)),
        ),
        SizedBox(width: 10),
        Text(
          'Or Continue with',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF8B8B8B),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 23,
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE6E6EC)),
        ),
      ],
    );
  }
}
