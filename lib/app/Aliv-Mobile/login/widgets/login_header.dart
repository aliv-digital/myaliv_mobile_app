import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../../../../resources/widgets/defaultBackButton.dart';
import '../theme/login_theme.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultBackButton(
          onPressed: () {
            context.pop();
            // custom logic
          },
        ),
        //SizedBox(height: 24),
        _LogoTitle(),
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
        SizedBox(height: 30),
        Text(
          'welcome back',
          style: TextStyle(
            fontSize: 17,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            color: AuthModuleColors.textBlack,
          ),
        ),
      ],
    );
  }
}
