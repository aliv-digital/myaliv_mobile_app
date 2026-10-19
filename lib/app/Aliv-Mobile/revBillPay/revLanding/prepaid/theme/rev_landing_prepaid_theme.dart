import 'package:flutter/material.dart';

class RevLandingPrepaidTheme {
  RevLandingPrepaidTheme._();

  static const String fontFamily = 'CircularPro';

  static const Color background = Color(0xFFBC343D);
  static const Color buttonBg = Color(0xFFF2F1F8);
  static const Color buttonText = Color(0xFF100F10);
  static const Color backIconColor = Color(0xFF655C9A);
  static const Color backButtonBg = Color(0xFFF6F6F7);

  static const double buttonHeight = 52;
  static const double buttonRadius = 26;
  static const double horizontalGutter = 32;
  static const double buttonWidthFactor = 0.6;
  static const double buttonMaxWidth = 240;
  static const double buttonMinWidth = 200;

  static const double backButtonSize = 40;
  static const double backButtonTop = 12;
  static const double backButtonLeft = 16;

  static const double heroToQuestionGap = 28;
  static const double questionToFirstButtonGap = 28;
  static const double betweenButtonsGap = 16;

  static const double bottomDecorationWidthFactor = 0.85;
  static const double bottomDecorationMaxWidth = 520;

  static TextStyle get question => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get buttonLabel => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: buttonText,
  );
}
