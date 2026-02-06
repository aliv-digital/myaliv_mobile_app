import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../../../../resources/widgets/defaultBackButton.dart';
import '../theme/forget_password_otp_theme.dart';

class ForgetPasswordOtpHeader extends StatelessWidget {
  const ForgetPasswordOtpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultBackButton(
          padding: EdgeInsets.only(left: 16, top: 12),
          onPressed: () {
            context.pop();
          },
        ),
        const SizedBox(height: 22),
        SvgPicture.asset(
          AssetConstant.otpPhoneSVG,
          width: 162,
          height: 170,
        ),
        const SizedBox(height: 21),
        const Text(
          'verification code',
          style: ForgetPasswordOtpTheme.title,
        ),
        const SizedBox(height: 16),
        Text(
          'we have sent a verification code to your email\nand via sms',
          textAlign: TextAlign.center,
          style: ForgetPasswordOtpTheme.subtitle,
        ),
      ],
    );
  }
}
