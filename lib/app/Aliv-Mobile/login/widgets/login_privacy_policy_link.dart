import 'package:flutter/material.dart';

import '../theme/login_theme.dart';
import 'login_privacy_policy_modal.dart';
import 'login_terms_of_use_modal.dart';

class LoginPrivacyPolicyLink extends StatelessWidget {
  const LoginPrivacyPolicyLink({super.key, this.separatorGap});

  /// Opts into spacing around the divider.
  final double? separatorGap;

  static const _linkStyle = AuthModuleTextStyles.privacyPolicyFooter;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        TextButton(
          style: AuthModuleButtonStyles.inlineTextLink,
          onPressed: () => showLoginPrivacyPolicyModal(context),
          child: const Text('Privacy Policy', style: _linkStyle),
        ),
        if (separatorGap != null) SizedBox(width: separatorGap),
        Text(
          separatorGap == null ? ' | ' : '|',
          style: AuthModuleTextStyles.privacyPolicyFooterSeparator,
        ),
        if (separatorGap != null) SizedBox(width: separatorGap),
        TextButton(
          style: AuthModuleButtonStyles.inlineTextLink,
          onPressed: () => showLoginTermsOfUseModal(context),
          child: const Text('Terms of Use', style: _linkStyle),
        ),
      ],
    );
  }
}
