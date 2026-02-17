import 'package:flutter/material.dart';

class GuestPurchasePlanConfirmationTheme {
  static const bg = Color(0xFFF1F2FA);

  static const purple = Color(0xFF655C9A);
  static const purpleDark = Color(0xFF5B548E);
  static const outlinePurple = Color(0xFF655C9A);

  static const cardWhite = Color(0xFFFFFFFF);
  static const textBlack = Color(0xFF121212);
  static const textGrey = Color(0xFF707070);

  static const shadow = Color(0x14000000);

  /// Common text style helper (CircularPro everywhere)
  static TextStyle t(
      double size, {
        FontWeight weight = FontWeight.w400,
        Color color = textBlack,
        double height = 1.2,
        TextDecoration? decoration,
      }) {
    return TextStyle(
      fontFamily: 'CircularPro',
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      decoration: decoration,
    );
  }
}
