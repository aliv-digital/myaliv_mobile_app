import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsText extends StatelessWidget {
  const TermsAndConditionsText({
    super.key,
    required this.onTapTerms,
  });

  final VoidCallback onTapTerms;

  static const _textColor = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          style: const TextStyle(
            color: _textColor,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
          children: [
            const TextSpan(text: 'By pressing “pay now” you agree to the '),
            TextSpan(
              text: 'Terms &\nConditions.',
              style: const TextStyle(
                color: _textColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
                decorationThickness: 1.5,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTapTerms,
            ),
          ],
        ),
      ),
    );
  }
}
