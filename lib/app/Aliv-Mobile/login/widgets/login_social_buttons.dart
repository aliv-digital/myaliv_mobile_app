import 'package:flutter/material.dart';

import '../theme/login_theme.dart';

class LoginSocialButtons extends StatelessWidget {
  const LoginSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        const _OrDividerRow(),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
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
                      fontSize: 13,
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
                height: 40,
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
                        fontSize: 13,
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

class _OrDividerRow extends StatelessWidget {
  const _OrDividerRow();

  static const double _dividerWidth = 32;
  static const double _dividerHeight = 1;
  static const double _labelGap = 12;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _ShortDivider(),
        SizedBox(width: _labelGap),
        Text(
          'or sign in with',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AuthModuleColors.hintGrey,
            height: 1.38,
            letterSpacing: -0.08,
            fontFamily: 'CircularPro',
          ),
        ),
        SizedBox(width: _labelGap),
        _ShortDivider(),
      ],
    );
  }
}

class _ShortDivider extends StatelessWidget {
  const _ShortDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _OrDividerRow._dividerWidth,
      height: _OrDividerRow._dividerHeight,
      color: AuthModuleColors.lightGreyBorder,
    );
  }
}
