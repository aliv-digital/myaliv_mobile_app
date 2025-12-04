import 'package:flutter/material.dart';

import '../theme/login_theme.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: Divider(
                thickness: 0.6,
                color: LoginColors.lightGreyBorder,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'or sign in with',
              style: TextStyle(
                fontSize: 12,
                color: LoginColors.hintGrey,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Divider(
                thickness: 0.6,
                color: LoginColors.lightGreyBorder,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side:
                    const BorderSide(color: LoginColors.alivPurple, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'face id',
                    style: TextStyle(
                      fontSize: 14,
                      color: LoginColors.alivPurple,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side:
                    const BorderSide(color: LoginColors.alivPurple, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'fingerprint',
                    style: TextStyle(
                      fontSize: 14,
                      color: LoginColors.alivPurple,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
