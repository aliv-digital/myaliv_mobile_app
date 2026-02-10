import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class FaceIdSecurityTheme {
  static const String fontFamily = AppConstants.defaultFontFamily;

  static const Color bg = Color(0xFFF2F3F7);
  static const Color appBarBg = Color(0xFF655C9A);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  static const double appBarHeight = 56;

  // Body content padding from design (left/right 16, top 24).
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(16, 24, 16, 24);

  // Vertical gap between body text and CTA button.
  static const double bodyToButtonGap = 24;

  static const TextStyle title = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: 'Circular Pro',
    fontWeight: FontWeight.w700,

  );

  static const TextStyle body = TextStyle(
    color: const Color(0xFF707070),
    fontSize: 14,
    fontFamily: 'Circular Pro',
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  // Bottom button
  static const double bottomButtonHeight = 48;
  static const double bottomButtonRadius = 24;
  static const Color bottomButtonBg = Color(0xFF655C9A);
  static const TextStyle bottomButtonText = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontFamily: 'Circular Pro',
    fontWeight: FontWeight.w700,
    height: 1.80,
  );
}
