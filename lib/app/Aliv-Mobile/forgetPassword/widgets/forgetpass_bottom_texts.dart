import 'package:flutter/material.dart';
import '../theme/forget_password_theme.dart';

class LoginBottomTexts extends StatelessWidget {
  const LoginBottomTexts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'still need to activate your account?',
          textAlign: TextAlign.center,
          style: ForgetPasswordTheme.accountActivationPrompt,
        ),
        const SizedBox(height: ForgetPasswordSizes.bottomPromptToActionGap),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {},
          child: Text(
            'manage my password',
            style: ForgetPasswordTheme.managePasswordLink,
          ),
        ),
      ],
    );
  }
}
