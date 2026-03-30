import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../../../../resources/widgets/defaultBackButton.dart';
import '../theme/login_otp_theme.dart';

class OtpHeader extends StatelessWidget {
  const OtpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultBackButton(
          padding: EdgeInsets.only(
            left: LoginOtpSizes.backLeft,
            top: 28,
          ),
          iconWidth: LoginOtpSizes.backIconWidth,
          iconHeight: LoginOtpSizes.backIconHeight,
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        SizedBox(height: 55),
        SvgPicture.asset(
          AssetConstant.otpPhoneSVG,
          width: LoginOtpSizes.otpImageWidth,
          height: LoginOtpSizes.otpImageHeight,
        ),
        const SizedBox(height: LoginOtpSizes.otpImageToTitleGap),
        const Text(
          'verification code',
          style: LoginOtpTheme.title,
        ),
        const SizedBox(height: LoginOtpSizes.titleToSubtitleGap),
        Text(
          'we have sent a verification code to your email\nand via sms',
          textAlign: TextAlign.center,
          style: LoginOtpTheme.subtitle,
        ),
      ],
    );
  }
}
