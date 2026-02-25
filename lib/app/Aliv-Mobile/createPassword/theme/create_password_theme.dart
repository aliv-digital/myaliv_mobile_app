import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class CreatePasswordTheme {
  // Colors
  static const Color titleColor = Color(0xFF000000);
  static const Color subtitleColor = Color(0xFF58677D);
  static const Color helperColor = Color(0xFF58677D);
  static const Color inputTextColor = Color(0xFF1A1A1A);
  static const Color inputHintColor = Color(0xFFB7B7C2);
  static const Color inputBackgroundColor = Colors.white;
  static const Color inputBorderColor = Color(0xFFE0E0E0);
  static const Color inputIconColor = Color(0xFF707070);

  // Focused input gradient colors (same behavior as login)
  static const Color focusedInputBorderYellow = Color(0xFFFFC627);
  static const Color focusedInputBorderBlue = Color(0xFF00B3E3);
  static const Color focusedInputBorderPurple = Color(0xFF4B298C);
  static const Color focusedInputBorderPink = Color(0xFFFF9BB1);
  static const Color focusedInputBorderOrange = Color(0xFFFF6C36);

  // Sizes
  static const double inputHeight = 50;
  static const double inputRadius = 6;
  static const double inputBorderWidth = 1;
  static const EdgeInsets inputHorizontalPadding = EdgeInsets.symmetric(horizontal: 20);
  static const double inputIconSize = 18;
  static const double iconToFieldGap = 10;
  static const double suffixIconTapSize = 24;

  static const LinearGradient focusedInputBorderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      focusedInputBorderYellow,
      focusedInputBorderBlue,
      focusedInputBorderPurple,
      focusedInputBorderPink,
      focusedInputBorderOrange,
    ],
  );

  // Header title: "create password"
  static const TextStyle title = TextStyle(
    fontSize: 17,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: titleColor,
  );

  // Header subtitle: "Set the new password..."
  static TextStyle subtitle = const TextStyle(
    fontSize: 15,
    height: 1.47,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: subtitleColor,
  );

  // Password input text style
  static const TextStyle inputText = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: inputTextColor,
  );

  // Password input hint style
  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: inputHintColor,
  );

  // Password helper text under inputs
  static TextStyle helperText = const TextStyle(
    fontSize: 14,
    height: 1.35,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: helperColor,
  );
}
