import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/forget_password_theme.dart';

class TermsAndPrivacyText extends StatelessWidget {
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  /// jei link ta load hocche setar jonno flag
  final bool isTermsLoading;
  final bool isPrivacyLoading;

  const TermsAndPrivacyText({
    super.key,
    this.onTermsTap,
    this.onPrivacyTap,
    this.isTermsLoading = false,
    this.isPrivacyLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: ForgetPasswordTheme.termsBase.fontSize,
            //height: 1.5,
            fontWeight: ForgetPasswordTheme.termsBase.fontWeight,
            fontFamily: ForgetPasswordTheme.termsBase.fontFamily,
            color: ForgetPasswordTheme.termsBase.color,
          ),
          children: [
            const TextSpan(
              text: "By pressing the ‘send’ button above you agree to the ",
            ),

            // ---- Terms & Conditions ----
            TextSpan(
              text: isTermsLoading ? "Loading..." : "Terms & Conditions",
              style: isTermsLoading
                  ? ForgetPasswordTheme.termsLinkDisabled
                  : ForgetPasswordTheme.termsLink,
              recognizer: (!isTermsLoading && onTermsTap != null) ? (TapGestureRecognizer()..onTap = onTermsTap) : null,
            ),

            const TextSpan(text: " & "),

            // ---- Privacy Policy ----
            TextSpan(
              text: isPrivacyLoading ? "Loading..." : "Privacy Policy",
              style: isPrivacyLoading
                  ? ForgetPasswordTheme.termsLinkDisabled
                  : ForgetPasswordTheme.termsLink,
              recognizer: (!isPrivacyLoading && onPrivacyTap != null) ? (TapGestureRecognizer()..onTap = onPrivacyTap) : null,
            ),
          ],
        ),
      ),
    );
  }
}
