import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import '../../login/theme/login_theme.dart';

class CreatePasswordTheme {
  // Header title: "create password"
  static const TextStyle title = TextStyle(
    fontSize: 17,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: AuthModuleColors.textBlack,
  );

  // Header subtitle: "Set the new password..."
  static  TextStyle subtitle = TextStyle(
    fontSize: 15,
    height: 1.47,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: ColorManager.otpScreenTxtGray,
  );

  // Password input text style
  static const TextStyle inputText = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: Color(0xFF1A1A1A),
  );

  // Password input hint style
  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: Color(0xFFB7B7C2),
  );

  // Password helper text under inputs
  static TextStyle helperText = TextStyle(
    fontSize: 14,
    height: 1.35,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: ColorManager.otpScreenTxtGray,
  );
}
