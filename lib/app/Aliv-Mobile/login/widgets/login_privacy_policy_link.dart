import 'package:flutter/material.dart';

import '../theme/login_theme.dart';
import 'login_privacy_policy_modal.dart';

class LoginPrivacyPolicyLink extends StatelessWidget {
  const LoginPrivacyPolicyLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: AuthModuleButtonStyles.inlineTextLink,
      onPressed: () => showLoginPrivacyPolicyModal(context),
      child: const Text(
        'Privacy Policy | Terms of Use',
        style: AuthModuleTextStyles.privacyPolicyFooter,
      ),
    );
  }
}
