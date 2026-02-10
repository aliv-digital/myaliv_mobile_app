import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../../../../../../resources/widgets/defaultBackButton.dart';
import '../../../../login/theme/login_theme.dart';


class OtpProfilePrepaidHeader extends StatelessWidget {
  const OtpProfilePrepaidHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen body already uses SafeArea. Keep back icon exactly 53px
    // from physical top (including status bar) by subtracting top inset.
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    final topFromSafeArea = (53 - statusBarHeight).clamp(0.0, 53.0);

    return Column(
      children: [
        DefaultBackButton(
          padding: EdgeInsets.only(left: 16, top: topFromSafeArea),
          onPressed: () {
            context.pop();
          },
        ),
        const SizedBox(height: 56),
        SvgPicture.asset(
          AssetConstant.otpPhoneSVG,
          width: 162,
          height: 170,
        ),
        const SizedBox(height: 21),
        const Text(
          'verification code',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            color: AuthModuleColors.textBlack,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'we have sent a verification code to your email\nand via sms',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: ColorManager.otpScreenTxtGray,
            height: 1.4,
            fontWeight: FontWeight.w400,
            fontFamily: 'CircularPro',
          ),
        ),
      ],
    );
  }
}
