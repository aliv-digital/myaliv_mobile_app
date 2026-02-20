import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../../../../../../resources/widgets/defaultBackButton.dart';
import '../theme/otp_prepaid_theme.dart';

class OtpAutoRenewPrepaidHeader extends StatelessWidget {
  const OtpAutoRenewPrepaidHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultBackButton(
          padding: OtpAutoRenewPrepaidTheme.headerBackButtonPadding,
          onPressed: () {
            context.pop();
          },
        ),
        const SizedBox(height: OtpAutoRenewPrepaidTheme.headerBackToIllustrationGap),
        SvgPicture.asset(
          AssetConstant.otpPhoneSVG,
          width: OtpAutoRenewPrepaidTheme.headerIllustrationWidth,
          height: OtpAutoRenewPrepaidTheme.headerIllustrationHeight,
        ),
        const SizedBox(height: OtpAutoRenewPrepaidTheme.headerIllustrationToTitleGap),
        const Text(
          'verification code',
          style: OtpAutoRenewPrepaidTheme.verificationTitleTextStyle,
        ),
        const SizedBox(height: OtpAutoRenewPrepaidTheme.headerTitleToSubtitleGap),
        Text(
          'we have sent a verification code to your email\nand via sms',
          textAlign: TextAlign.center,
          style: OtpAutoRenewPrepaidTheme.verificationSubtitleTextStyle(),
        ),
      ],
    );
  }
}
