import 'package:flutter/material.dart';
import '../theme/enter_password_prepaid_theme.dart';

class EnterPasswordPrepaidTermsText extends StatelessWidget {
  const EnterPasswordPrepaidTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: EnterPasswordPrepaidTheme.legalIntro,
        children: const [
          TextSpan(text: 'By pressing ‘Continue’ button you agree\n'),
          TextSpan(text: 'to the '),
          TextSpan(
            text: 'Terms & Conditions',
            style: EnterPasswordPrepaidTheme.legalLink,
          ),
          TextSpan(text: ' & '),
          TextSpan(
            text: 'Privacy Policy',
            style: EnterPasswordPrepaidTheme.legalLink,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
