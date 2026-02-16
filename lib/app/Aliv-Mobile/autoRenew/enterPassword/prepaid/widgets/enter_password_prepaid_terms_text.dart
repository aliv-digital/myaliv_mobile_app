import 'package:flutter/material.dart';
import '../theme/enter_password_autoRenew_prepaid_theme.dart';

class EnterPasswordAutoRenewPrepaidTermsText extends StatelessWidget {
  const EnterPasswordAutoRenewPrepaidTermsText({super.key});

  @override
  Widget build(BuildContext context) {
   return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'By pressing ‘Continue’ button you agree\nto the ',
            style: TextStyle(
              color: const Color(0xFF58677D),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: 'Terms & Conditionss',
            style: TextStyle(
              color: const Color(0xFF1CACE3),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(
            text: ' ',
            style: TextStyle(
              color: const Color(0xFF1CACE3),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: '& ',
            style: TextStyle(
              color: const Color(0xFF58677D),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: const Color(0xFF1CACE3),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    ); }
}
