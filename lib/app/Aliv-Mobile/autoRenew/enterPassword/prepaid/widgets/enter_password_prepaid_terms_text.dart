import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/enter_password_autoRenew_prepaid_theme.dart';

class EnterPasswordAutoRenewPrepaidTermsText extends StatefulWidget {
  const EnterPasswordAutoRenewPrepaidTermsText({super.key});

  @override
  State<EnterPasswordAutoRenewPrepaidTermsText> createState() =>
      _EnterPasswordAutoRenewPrepaidTermsTextState();
}

class _EnterPasswordAutoRenewPrepaidTermsTextState
    extends State<EnterPasswordAutoRenewPrepaidTermsText> {
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;
  @override
  void initState() {
    super.initState();

    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        // ✅ Navigate to Terms
        final uri = Uri.parse('https://www.bealiv.com/terms-of-use/');

        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw 'Could not open store locator';
        }
      };

    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        // ✅ Navigate to Privacy
        final uri = Uri.parse('https://www.bealiv.com/privacy-policy/');

        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw 'Could not open store locator';
        }
      };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'By pressing ‘Continue’ button you agree',
          style: TextStyle(
            color: const Color(0xFF58677D),
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
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
                recognizer: _termsRecognizer,
                style: TextStyle(
                  color: const Color(0xFF645D9C),
                  fontSize: 13,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,

                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF645D9C),
                ),
              ),

              TextSpan(
                text: ' & ',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF58677D),
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: 'Privacy Policy',
                recognizer: _privacyRecognizer,
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
        ),
      ],
    );
    //  Text.rich(
    //   TextSpan(
    //     children: [
    //       TextSpan(
    //         text: 'By pressing ‘Continue’ button you agree\nto the ',
    //         style: TextStyle(
    //           color: const Color(0xFF58677D),
    //           fontSize: 12,
    //           fontFamily: 'CircularPro',
    //           fontWeight: FontWeight.w500,
    //         ),
    //       ),
    //       TextSpan(
    //         text: 'Terms & Conditionss',
    //         style: TextStyle(
    //           color: const Color(0xFF1CACE3),
    //           fontSize: 12,
    //           fontFamily: 'CircularPro',
    //           fontWeight: FontWeight.w500,
    //           decoration: TextDecoration.underline,
    //         ),
    //       ),
    //       TextSpan(
    //         text: ' ',
    //         style: TextStyle(
    //           color: const Color(0xFF1CACE3),
    //           fontSize: 12,
    //           fontFamily: 'CircularPro',
    //           fontWeight: FontWeight.w500,
    //         ),
    //       ),
    //       TextSpan(
    //         text: '& ',
    //         style: TextStyle(
    //           color: const Color(0xFF58677D),
    //           fontSize: 12,
    //           fontFamily: 'CircularPro',
    //           fontWeight: FontWeight.w500,
    //         ),
    //       ),
    //       TextSpan(
    //         text: 'Privacy Policy',
    //         style: TextStyle(
    //           color: const Color(0xFF1CACE3),
    //           fontSize: 12,
    //           fontFamily: 'CircularPro',
    //           fontWeight: FontWeight.w500,
    //           decoration: TextDecoration.underline,
    //         ),
    //       ),
    //     ],
    //   ),
    //   textAlign: TextAlign.center,
    // );
  }
}
