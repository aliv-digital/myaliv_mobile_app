import 'package:flutter/material.dart';

class HelpTheme {
  static const String fontFamily = 'CircularPro';

  static const Color bg = Color(0xFFF2F3F7);
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  static const double appBarHeight = 56;
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(24, 24, 24, 24);

  // ✅ Note: Title casing differs in screenshot (first header is Capitalized)
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

  static const TextStyle sectionHeader = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: 'Circular Pro',
    fontWeight: FontWeight.w700,
  );
}
