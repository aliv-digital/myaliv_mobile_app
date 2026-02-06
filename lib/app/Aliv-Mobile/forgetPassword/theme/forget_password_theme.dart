import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import '../../login/theme/login_theme.dart';

class ForgetPasswordTheme {
  // Header title: "verify your number"
  static const TextStyle title = TextStyle(
    fontSize: 17,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: AuthModuleColors.textBlack,
  );

  // Header subtitle: "please enter your mobile..."
  static TextStyle subtitle = TextStyle(
    fontSize: 15,
    height: 1.47,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: ColorManager.otpScreenTxtGray,
  );

  // Country dial code text inside the picker box
  static const TextStyle dialCode = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: AuthModuleColors.textBlack,
  );

  // Phone input text style
  static const TextStyle phoneInput = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: AuthModuleColors.textBlack,
  );

  // Phone input hint text
  static const TextStyle phoneHint = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    color: AuthModuleColors.hintGrey,
  );

  // Terms & privacy base text
  static const TextStyle termsBase = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: Color(0xFF8A8FA6),
  );

  // Terms & privacy clickable links
  static TextStyle termsLink = TextStyle(
    fontWeight: FontWeight.w500,
    color: AuthModuleColors.linkBlue,
  );

  // Terms & privacy loading/disabled link color
  static const TextStyle termsLinkDisabled = TextStyle(
    fontWeight: FontWeight.w500,
    color: AuthModuleColors.hintGrey,
  );
}
