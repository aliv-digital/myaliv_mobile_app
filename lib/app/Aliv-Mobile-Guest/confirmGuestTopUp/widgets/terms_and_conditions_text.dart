import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class TermsAndConditionsText extends StatelessWidget {
  const TermsAndConditionsText({
    super.key,
    required this.onTapTerms,
  });

  final VoidCallback onTapTerms;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          style: TopUpConfirmTheme.termsBase,
          children: [
            const TextSpan(
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'CircularPro',
                height: 1.43,
                fontWeight: FontWeight.w400,
              ),
              text: 'By pressing “pay now” you agree to the ',
            ),
            TextSpan(
              text: 'Terms &\nConditions.',
              style: TopUpConfirmTheme.termsLink,
              recognizer: TapGestureRecognizer()..onTap = onTapTerms,
            ),
          ],
        ),
      ),
    );
  }
}
