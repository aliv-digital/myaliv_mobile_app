import 'package:flutter/material.dart';

class GuestPurchasePlanAddOnsTheme {
  // Keep colors centralized so later UI changes are easy.
  static const Color bg = Color(0xFFF1F2FA);
  static const Color appBarPurple = Color(0xFF655C9A);

  static const Color cardWhite = Colors.white;

  // Red plan header card
  static const Color planRed = Color(0xFFE62B2F);
  static const Color planRedDark = Color(0xFFD81E23);

  // Borders
  static const Color outlinePurple = Color(0xFF655C9A);
  static const Color shadow = Color(0x14000000);

  // Text
  static const Color textBlack = Color(0xFF121212);
  static const Color textGrey = Color(0xFF707070);
  static const Color textMuted = Color(0xFF8D8D8D);
  static const Color white = Colors.white;

  // Controls
  static const Color checkboxBorder = Color(0xFFB6B2D6);
  static const Color checkboxFill = Color(0xFF655C9A);

  static const Color proceedButton = Color(0xFF655C9A);
  static const Color proceedText = Colors.white;

  static const String font = 'CircularPro';

  static TextStyle t(double size, {
        FontWeight weight = FontWeight.w400,
        Color? color,
        double? height,
      }) {
    return TextStyle(
      fontFamily: font,
      fontSize: size,
      fontWeight: weight,
      color: color ?? textBlack,
      height: height,
    );
  }
}
