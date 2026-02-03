import 'package:flutter/material.dart';

class FingerPrintSecurityTheme {
  static const String fontFamily = 'CircularPro';

  static const Color bg = Color(0xFFF2F3F7);
  static const Color appBarBg = Color(0xFF655C9A);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  static const double appBarHeight = 56;

  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(16, 18, 16, 24);

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.43,
  );

  // Bottom button
  static const double bottomButtonHeight = 48;
  static const double bottomButtonRadius = 24;
  static const Color bottomButtonBg = Color(0xFF655C9A);
  static const TextStyle bottomButtonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.1,
  );
}
