
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../resources/constants/asset_constants.dart';
import '../../../../resources/widgets/defaultBackButton.dart';
import '../theme/create_password_theme.dart';

class CreatePasswordHeader extends StatelessWidget {
  const CreatePasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultBackButton(
          padding: EdgeInsets.only(left: 16, top: 28),
          onPressed: () {
            context.pop();
            // custom logic
          },
        ),
        const SizedBox(height: 62),
        const _LogoTitle(),
      ],
    );
  }
}


class _LogoTitle extends StatelessWidget {
  const _LogoTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 41.0,right: 40),
      child: Column(
        children: [
          SvgPicture.asset(
            AssetConstant.alivBlackLogoSVG,
            width: 95.42,
            height: 48.86,
          ),
          const SizedBox(height: 46),
          Text(
            'create password',
            style: CreatePasswordTheme.title,
          ),
          const SizedBox(height: 5),
          Text(
            'Set the new password for your account so you can login and access myaliv app',
            textAlign: TextAlign.center,
            style: CreatePasswordTheme.subtitle,
          )
        ],
      ),
    );
  }
}
