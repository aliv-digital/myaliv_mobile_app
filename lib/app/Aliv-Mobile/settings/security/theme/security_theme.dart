import 'package:flutter/material.dart';

class SecurityTheme {
  static const String fontFamily = 'CircularPro';

  // Colors
  static const Color bg = Color(0xFFF1F2FA);
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  // Layout
  static const double appBarHeight = 63;
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(16, 18, 16, 24);

  // Typography (match screenshot feel)
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
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

  static const TextStyle sectionHeader = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    height: 1.3,
  );
}
