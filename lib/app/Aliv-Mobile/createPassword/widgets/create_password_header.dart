
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../resources/color_manager.dart';
import '../../../../resources/constants/asset_constants.dart';
import '../../../../resources/widgets/defaultBackButton.dart';
import '../../login/theme/login_theme.dart';

class CreatePasswordHeader extends StatelessWidget {
  const CreatePasswordHeader({super.key});

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
        SizedBox(height: 62),
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
        SizedBox(height: 46),
        Text(
          'create password',
          style: TextStyle(
            fontSize: 17,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            color: AuthModuleColors.textBlack,
          ),
        ),
        SizedBox(height: 5),
        SizedBox(
          width: 307,
          child: Text('Set the new password for your account so you can login and access MyALIV App',
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
