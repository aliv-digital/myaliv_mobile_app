import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class EnterPasswordAutoRenewPrepaidTheme {
  // Screen colors.
  static const Color bg = Colors.white;
  static Color brand = HexColor.fromHex('#F2F1F9');
  static Color continueButtonColor = HexColor.fromHex('#645D9C');
  static const Color muted = Color(0xFF6B7280);
  static const Color inputBorder = Color(0xFFE6E6EC);
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color link = Color(0xFF00A3FF);

  // Password field dimensions.
  static const double passwordInputHeight = 48;
  static const double passwordInputBorderRadius = 8;
  static const double passwordInputBorderWidth = 1;
  static const double passwordInputHorizontalPadding = 12;
  static const double passwordInputIconGap = 8;
  static const double passwordInputSuffixIconPadding = 6;

  // Focused input gradient border colors (matches loginOtp focused border).
  static const Color focusedInputBorderYellow = Color(0xFFFFC627);
  static const Color focusedInputBorderBlue = Color(0xFF00B3E3);
  static const Color focusedInputBorderPurple = Color(0xFF4B298C);
  static const Color focusedInputBorderPink = Color(0xFFFF9BB1);
  static const Color focusedInputBorderOrange = Color(0xFFFF6C36);

  // Focused input gradient border.
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

  // Password hint text style.
  static const TextStyle passwordHintTextStyle = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: Color(0xFFB1B1B1),
  );

  // Password input text style.
  static const TextStyle passwordInputTextStyle = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: muted,
  );
}
