import 'package:flutter/material.dart';
import '../theme/enter_password_postpaid_theme.dart';

class EnterPasswordPostpaidTermsText extends StatelessWidget {
  const EnterPasswordPostpaidTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 11.5,
          height: 1.35,
          fontWeight: FontWeight.w400,
          color: EnterPasswordPostpaidTheme.muted,
        ),
        children: const [
          TextSpan(text: 'By pressing “Continue” button you agree\n'),
          TextSpan(text: 'to the '),
          TextSpan(
            text: 'Terms & Conditions',
            style: TextStyle(
              color: EnterPasswordPostpaidTheme.link,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: ' & '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: EnterPasswordPostpaidTheme.link,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
