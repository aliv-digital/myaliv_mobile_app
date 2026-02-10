import 'package:flutter/material.dart';
import '../theme/login_theme.dart';

class LoginBottomTexts extends StatelessWidget {
  const LoginBottomTexts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: AuthModuleSizes.activatePromptWidth,
          child: Text(
            'still need to activate your account?',
            textAlign: TextAlign.center,
            style: AuthModuleTextStyles.activateAccountPrompt,
          ),
        ),
        const SizedBox(height: AuthModuleSizes.activatePromptToLinkGap),
        TextButton(
          style: AuthModuleButtonStyles.inlineTextLink,
          onPressed: () {},
          child: const Text(
            'manage my password',
            style: AuthModuleTextStyles.manageMyPassword,
          ),
        ),
      ],
    );
  }
}
