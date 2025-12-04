import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/login_theme.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        SizedBox(height: 45),
        _BackButtonRow(),
        //SizedBox(height: 24),
        _LogoTitle(),
      ],
    );
  }
}

class _BackButtonRow extends StatelessWidget {
  const _BackButtonRow();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        padding: EdgeInsets.only(left: 16),
        constraints: const BoxConstraints(),
        icon: SvgPicture.asset(
          AssetConstant.backButtonSVG,
          width: 16,
          height: 14,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
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
            color: LoginColors.textBlack,
          ),
        ),
      ],
    );
  }
}
