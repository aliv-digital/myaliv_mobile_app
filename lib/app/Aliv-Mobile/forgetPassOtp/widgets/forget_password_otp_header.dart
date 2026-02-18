import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../../../../resources/widgets/defaultBackButton.dart';
import '../theme/forget_password_otp_theme.dart';

class ForgetPasswordOtpHeader extends StatelessWidget {
  const ForgetPasswordOtpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    final backTop = (ForgetPasswordOtpSizes.backTopFromScreen - topInset)
        .clamp(0.0, double.infinity)
        .toDouble();
    final imageGapFromBackIcon = ForgetPasswordOtpSizes.otpImageTopFromScreen -
        ForgetPasswordOtpSizes.backTopFromScreen -
        ForgetPasswordOtpSizes.backIconHeight;

    return Column(
      children: [
        DefaultBackButton(
          padding: EdgeInsets.only(
            left: ForgetPasswordOtpSizes.backLeft,
            top: 28,
          ),
          iconWidth: ForgetPasswordOtpSizes.backIconWidth,
          iconHeight: ForgetPasswordOtpSizes.backIconHeight,
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        SizedBox(height: imageGapFromBackIcon),
        SvgPicture.asset(
          AssetConstant.otpPhoneSVG,
          width: ForgetPasswordOtpSizes.otpImageWidth,
          height: ForgetPasswordOtpSizes.otpImageHeight,
        ),
        const SizedBox(height: ForgetPasswordOtpSizes.otpImageToTitleGap),
        const Text(
          'verification code',
          style: ForgetPasswordOtpTheme.title,
        ),
        const SizedBox(height: ForgetPasswordOtpSizes.titleToSubtitleGap),
        Text(
          'we have sent a verification code to your email\nand via sms',
          textAlign: TextAlign.center,
          style: ForgetPasswordOtpTheme.subtitle,
        ),
      ],
    );
  }
}
