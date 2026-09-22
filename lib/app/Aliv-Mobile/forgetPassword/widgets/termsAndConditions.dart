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
    return Padding(
      padding: ForgetPasswordPaddings.termsHorizontal,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: ForgetPasswordTheme.termsBase,
          children: [
            const TextSpan(
              text: "by pressing the 'send' button you agree to our ",
              style: ForgetPasswordTheme.termsIntro,
            ),

            // ---- Terms & Conditions ----
            TextSpan(
              text: isTermsLoading ? "loading..." : "terms & conditions",
              style: isTermsLoading
                  ? ForgetPasswordTheme.termsLinkDisabled
                  : ForgetPasswordTheme.termsAndConditionsLink,
              recognizer: (!isTermsLoading && onTermsTap != null)
                  ? (TapGestureRecognizer()..onTap = onTermsTap)
                  : null,
            ),

            const TextSpan(text: " and "),

            // ---- Privacy Policy ----
            TextSpan(
              text: isPrivacyLoading ? "loading..." : "privacy policy",
              style: isPrivacyLoading
                  ? ForgetPasswordTheme.termsLinkDisabled
                  : ForgetPasswordTheme.privacyPolicyLink,
              recognizer: (!isPrivacyLoading && onPrivacyTap != null)
                  ? (TapGestureRecognizer()..onTap = onPrivacyTap)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
