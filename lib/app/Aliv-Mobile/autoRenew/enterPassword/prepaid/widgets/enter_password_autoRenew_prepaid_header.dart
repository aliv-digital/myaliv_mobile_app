import 'package:flutter/material.dart';
import '../theme/enter_password_autoRenew_prepaid_theme.dart';

class EnterPasswordAutoRenewPrepaidHeader extends StatelessWidget {
  const EnterPasswordAutoRenewPrepaidHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Enter Password',
          style: TextStyle(
            color: const Color(0xFF010101),
            fontSize: 17,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 3),
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
