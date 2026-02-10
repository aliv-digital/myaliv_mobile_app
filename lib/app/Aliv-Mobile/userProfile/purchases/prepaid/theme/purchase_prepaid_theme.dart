import 'package:flutter/material.dart';

class PurchasePrepaidTheme {
  static const Color primary = Color(0xFF645D9C); // screenshot-like purple
  static const Color pageBg = Color(0xFFF7F7F7);
  static const Color tileBg = Colors.white;
  static const Color divider = Color(0xFFE6E6E6);
  static const Color text = Color(0xFF2B2B2B);
  static const Color chevron = Color(0xFF2B2B2B);

  static const double horizontalPad = 16;

  static TextStyle itemTextStyle() => const TextStyle(
    color: text,
    fontFamily: 'CircularPro',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.26
  );
}
