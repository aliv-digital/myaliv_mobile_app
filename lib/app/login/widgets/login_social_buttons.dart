import 'package:flutter/material.dart';

import '../theme/login_theme.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Row(
          children:  [
            Expanded(
              child: Divider(
                thickness: 0.6,
                color: AuthModuleColors.lightGreyBorder,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'or sign in with',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AuthModuleColors.hintGrey,
                height: 1.38,
                letterSpacing: -0.08,
                fontFamily: 'CircularPro'
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Divider(
                thickness: 0.6,
                color: AuthModuleColors.lightGreyBorder,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AuthModuleColors.alivPurple, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'face id',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.43,
                      fontWeight: FontWeight.w700,
                      color: AuthModuleColors.alivPurple,
                      fontFamily: 'CircularPro'
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
                    side: BorderSide(color: AuthModuleColors.alivPurple, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: () {},
                  child: Text(
                    'fingerprint',
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.43,
                        fontWeight: FontWeight.w700,
                        color: AuthModuleColors.alivPurple,
                        fontFamily: 'CircularPro'
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
