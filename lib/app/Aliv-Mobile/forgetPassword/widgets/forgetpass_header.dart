import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultBackButton.dart';
import '../theme/forget_password_theme.dart';

class ForgetPasswordHeader extends StatelessWidget {
  const ForgetPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultBackButton(
          padding: EdgeInsets.only(
            left: ForgetPasswordSizes.backLeft,
            top: 28,
          ),
          iconWidth: ForgetPasswordSizes.backIconWidth,
          iconHeight: ForgetPasswordSizes.backIconHeight,
          onPressed: () {
            context.pop();
            // custom logic
          },
        ),
        SizedBox(height: 64),
        const _LogoTitle(),
      ],
    );
  }
}

class _LogoTitle extends StatelessWidget {
  const _LogoTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SvgPicture.asset(
          AssetConstant.alivBlackLogoSVG,
          width: ForgetPasswordSizes.logoWidth,
          height: ForgetPasswordSizes.logoHeight,
        ),
        const SizedBox(height: ForgetPasswordSizes.logoToTitleGap),
        Text(
          'verify your number',
          style: ForgetPasswordTheme.title,
        ),
        const SizedBox(height: ForgetPasswordSizes.titleToSubtitleGap),
        SizedBox(
          width: ForgetPasswordSizes.subtitleWidth,
          child: Text(
            'please enter your mobile to create your new password',
            textAlign: TextAlign.center,
            style: ForgetPasswordTheme.subtitle,
          ),
        ),
        SizedBox(height: 9.61)
      ],
    );
  }
}
