import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import '../../login/theme/login_theme.dart';

class ForgetPasswordOtpTheme {
  // Header title: "verification code"
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: AuthModuleColors.textBlack,
  );

  // Header subtitle: "we have sent a verification code..."
  static final TextStyle subtitle = TextStyle(
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: ColorManager.otpScreenTxtGray,
  );

  // OTP input digits style inside code boxes
  static const TextStyle otpInput = TextStyle(
    fontSize: 20,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w600,
    color: AuthModuleColors.textBlack,
  );

  // Helper text before resend action: "didn't receive a code?"
  static const TextStyle helperText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    height: 1.43,
    color: AuthModuleColors.textBlack,
  );

  // Resend action text: "resend code" / "sending..."
  static TextStyle resendText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    height: 1.43,
    color: ColorManager.textLinkColor,
  );

  // Fixed bottom action: "change phone number"
  static TextStyle changePhoneText = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontFamily: AppConstants.defaultFontFamily,
    color: ColorManager.orangeColor,
    fontWeight: FontWeight.w500,
  );

  // SnackBar message text for OTP errors
  static const TextStyle snackBarText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
  );
}
