import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../../../../resources/widgets/defaultBackButton.dart';
import '../../login/theme/login_theme.dart';


class ForgetPasswordHeader extends StatelessWidget {
  const ForgetPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DefaultBackButton(
          padding: EdgeInsets.only(left: 16,top: 53),
          onPressed: () {
            // custom logic
          },
        ),
        SizedBox(height: 64),
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
        SizedBox(height: 44),
        Text(
          'verify your number',
          style: TextStyle(
            fontSize: 17,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            color: AuthModuleColors.textBlack,
          ),
        ),
        SizedBox(height: 5),
        SizedBox(
          width: 294,
          child: Text('please enter your mobile to create your new password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.47,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w400,
              color: ColorManager.otpScreenTxtGray,
            ),
          ),
        )
      ],
    );
  }
}
