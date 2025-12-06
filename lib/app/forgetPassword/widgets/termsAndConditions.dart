import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/login/theme/login_theme.dart';

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
            fontSize: 12,
            //height: 1.5,
            fontWeight: FontWeight.w400,
            fontFamily: 'CircularPro',
            color: const Color(0xFF8A8FA6), // main text color
          ),
          children: [
            const TextSpan(
              text: "By pressing the ‘send’ button above you agree to the ",
            ),

            // ---- Terms & Conditions ----
            TextSpan(
              text: isTermsLoading ? "Loading..." : "Terms & Conditions",
              style: TextStyle(
                color: isTermsLoading
                    ? AuthModuleColors.hintGrey // loading → normal grey
                    : AuthModuleColors.linkBlue, // clickable link color
                fontWeight: FontWeight.w500,
              ),
              recognizer: (!isTermsLoading && onTermsTap != null) ? (TapGestureRecognizer()..onTap = onTermsTap) : null,
            ),

            const TextSpan(text: " & "),

            // ---- Privacy Policy ----
            TextSpan(
              text: isPrivacyLoading ? "Loading..." : "Privacy Policy",
              style: TextStyle(
                color: isPrivacyLoading ? AuthModuleColors.hintGrey : AuthModuleColors.linkBlue,
                fontWeight: FontWeight.w500,
              ),
              recognizer: (!isPrivacyLoading && onPrivacyTap != null) ? (TapGestureRecognizer()..onTap = onPrivacyTap) : null,
            ),
          ],
        ),
      ),
    );
  }
}
