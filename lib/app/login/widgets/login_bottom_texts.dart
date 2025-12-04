import 'package:flutter/material.dart';

import '../theme/login_theme.dart';

class LoginBottomTexts extends StatelessWidget {
  const LoginBottomTexts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'still need to activate your account?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: LoginColors.textBlack,
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {},
          child: const Text(
            'manage my password',
            style: TextStyle(
              fontSize: 14,
              color: LoginColors.linkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
