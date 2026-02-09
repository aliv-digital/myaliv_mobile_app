import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../../../../resources/widgets/defaultBackButton.dart';
import '../theme/forget_password_theme.dart';


class ForgetPasswordHeader extends StatelessWidget {
  const ForgetPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultBackButton(
          padding: EdgeInsets.only(left: 16, top: 12),
          onPressed: () {
            context.pop();
            // custom logic
          },
        ),
        const SizedBox(height: 22),
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
          width: 95.42,
          height: 48.86,
        ),
        const SizedBox(height: 44),
        Text(
          'verify your number',
          style: ForgetPasswordTheme.title,
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 294,
          child: Text(
            'please enter your mobile to create your new password',
            textAlign: TextAlign.center,
            style: ForgetPasswordTheme.subtitle,
          ),
        )
      ],
    );
  }
}
