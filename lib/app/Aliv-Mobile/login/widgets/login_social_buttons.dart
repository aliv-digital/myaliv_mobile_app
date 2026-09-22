import 'package:flutter/material.dart';

import '../theme/login_theme.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({
    required this.onFaceIdPressed,
    required this.onFingerprintPressed,
    super.key,
  });

  final VoidCallback? onFaceIdPressed;
  final VoidCallback? onFingerprintPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _OrDividerRow(),
        const SizedBox(height: AuthModuleSizes.dividerToButtonsGap),
        // social buttons ------------------
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'face id',
                onPressed: onFaceIdPressed,
              ),
            ),
            const SizedBox(width: AuthModuleSizes.socialButtonsGap),
            Expanded(
              child: _SocialButton(
                label: 'fingerprint',
                onPressed: onFingerprintPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuthModuleSizes.socialButtonHeight,
      child: OutlinedButton(
        style: AuthModuleButtonStyles.socialOutlined,
        onPressed: onPressed,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AuthModuleTextStyles.socialMediaButton,
        ),
      ),
    );
  }
}

class _OrDividerRow extends StatelessWidget {
  const _OrDividerRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ShortDivider(),
        const SizedBox(width: AuthModuleSizes.dividerLabelGap),
        const Text(
          'or sign in with',
          textAlign: TextAlign.center,
          style: AuthModuleTextStyles.orSignInWith,
        ),
        const SizedBox(width: AuthModuleSizes.dividerLabelGap),
        _ShortDivider(),
      ],
    );
  }
}

class _ShortDivider extends StatelessWidget {
  const _ShortDivider();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AuthModuleColors.lightGreyBorder,
      child: SizedBox(
        width: AuthModuleSizes.dividerWidth,
        height: AuthModuleSizes.dividerHeight,
      ),
    );
  }
}
