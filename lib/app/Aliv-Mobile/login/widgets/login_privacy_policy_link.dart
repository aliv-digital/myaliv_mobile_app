import 'package:flutter/material.dart';

import '../theme/login_theme.dart';
import 'login_privacy_policy_modal.dart';
import 'login_terms_of_use_modal.dart';

class LoginPrivacyPolicyLink extends StatelessWidget {
  const LoginPrivacyPolicyLink({super.key});

  static final _linkStyle = AuthModuleTextStyles.privacyPolicyFooter.copyWith(
    decoration: TextDecoration.none,
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // A continuous underline matches the reference across both links and gaps.
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AuthModuleColors.managePassword),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          TextButton(
            style: AuthModuleButtonStyles.inlineTextLink,
            onPressed: () => showLoginPrivacyPolicyModal(context),
            child: Text('Privacy Policy', style: _linkStyle),
          ),
          const Text(
            ' | ',
            style: AuthModuleTextStyles.privacyPolicyFooterSeparator,
          ),
          TextButton(
            style: AuthModuleButtonStyles.inlineTextLink,
            onPressed: () => showLoginTermsOfUseModal(context),
            child: Text('Terms of Use', style: _linkStyle),
          ),
        ],
      ),
    );
  }
}
