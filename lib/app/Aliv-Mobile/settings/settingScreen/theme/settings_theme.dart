import 'package:flutter/material.dart';

class SettingsTheme {
  static const String fontFamily = 'CircularPro';

  // Colors
  static const Color bg = Color(0xFFF2F3F7);
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color cardBg = Colors.white;
  static const Color divider = Color(0xFFE8E9EE);
  static const Color iconCircleBg = Color(0xFFF6F8F9);
  static const Color chevron = Color(0xFF1F1F1F);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  // Layout
  static const double appBarHeight = 56;
  static const double cardRadius = 8;
  static const double tileHeight = 56;
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(16, 16, 16, 16);

  // Typography
  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.1,
  );

  static const TextStyle tileText = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    // letterSpacing: -0.32,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.1,
  );
}
