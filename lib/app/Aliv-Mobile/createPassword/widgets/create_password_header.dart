import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultBackButton.dart';
import '../theme/create_password_theme.dart';

class CreatePasswordHeader extends StatelessWidget {
  const CreatePasswordHeader({
    super.key,
    this.title = 'create password',
    this.subtitle =
        'Set the new password for your account so you can login and access myaliv app',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultBackButton(
          padding: const EdgeInsets.only(left: 16, top: 28),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(height: 62),
        Padding(
          padding: const EdgeInsets.only(left: 41.0, right: 40),
          child: Column(
            children: [
              SvgPicture.asset(
                AssetConstant.alivBlackLogoSVG,
                width: 95.42,
                height: 48.86,
              ),
              const SizedBox(height: 46),
              Text(title, style: CreatePasswordTheme.title),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: CreatePasswordTheme.subtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
