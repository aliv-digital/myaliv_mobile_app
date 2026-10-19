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
          TextSpan(
            text: 'By pressing ‘Continue’ button you agree',
            style: TextStyle(
              color: const Color(0xFF58677D),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: 'to the ',
            style: TextStyle(
              color: const Color(0xFF58677D),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: 'Terms & Conditions',
            style: TextStyle(
              color: const Color(0xFF645D9C),
              fontSize: 13,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF645D9C),
            ),

            // style: TextStyle(
            //   color: EnterPasswordPostpaidTheme.link,
            //   decoration: TextDecoration.underline,
            // ),
          ),
          TextSpan(
            text: ' & ',
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
              color: const Color(0xFF645D9C),
              fontSize: 13,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF645D9C),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
