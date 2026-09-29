import 'package:flutter/material.dart';

import '../theme/login_theme.dart';
import 'login_privacy_policy_modal.dart';
import 'login_terms_of_use_modal.dart';

class LoginPrivacyPolicyLink extends StatelessWidget {
  const LoginPrivacyPolicyLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          style: AuthModuleButtonStyles.inlineTextLink,
          onPressed: () => showLoginPrivacyPolicyModal(context),
          child: const Text(
            'Privacy Policy',
            style: AuthModuleTextStyles.privacyPolicyFooter,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Text(
            '|',
            style: AuthModuleTextStyles.privacyPolicyFooterSeparator,
          ),
        ),
        TextButton(
          style: AuthModuleButtonStyles.inlineTextLink,
          onPressed: () => showLoginTermsOfUseModal(context),
          child: const Text(
            'Terms of Use',
            style: AuthModuleTextStyles.privacyPolicyFooter,
          ),
        ),
      ],
    );
  }
}
