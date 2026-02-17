import 'package:flutter/material.dart';
import '../theme/enter_password_prepaid_theme.dart';

class EnterPasswordPrepaidHeader extends StatelessWidget {
  const EnterPasswordPrepaidHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 90),
        Text(
          'Enter Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF010101),
            fontSize: 17,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'For security reasons, please enter your password to continue.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF58677D),
            fontSize: 15,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
            height: 1.47,
          ),
        ),
      ],
    );
  }
}
