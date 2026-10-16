import 'package:flutter/material.dart';

import '../theme/login_theme.dart';
import 'login_privacy_policy_modal.dart';
import 'login_terms_of_use_modal.dart';

class LoginPrivacyPolicyLink extends StatelessWidget {
  const LoginPrivacyPolicyLink({super.key, this.separatorGap});

  /// Opts into separately underlined links with spacing around the divider.
  /// The existing login footer keeps its continuous underline by default.
  final double? separatorGap;

  static final _linkStyle = AuthModuleTextStyles.privacyPolicyFooter.copyWith(
    decoration: TextDecoration.none,
  );

  @override
  Widget build(BuildContext context) {
    final linkStyle = separatorGap == null
        ? _linkStyle
        : AuthModuleTextStyles.privacyPolicyFooter;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: separatorGap == null
            ? const Border(
                bottom: BorderSide(color: AuthModuleColors.managePassword),
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          TextButton(
            style: AuthModuleButtonStyles.inlineTextLink,
            onPressed: () => showLoginPrivacyPolicyModal(context),
            child: Text('Privacy Policy', style: linkStyle),
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
            child: Text('Terms of Use', style: linkStyle),
          ),
        ],
      ),
    );
  }
}
