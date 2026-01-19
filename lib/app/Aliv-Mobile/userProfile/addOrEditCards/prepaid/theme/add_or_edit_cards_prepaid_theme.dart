import 'package:flutter/material.dart';

class AddOrEditCardsPrepaidTheme {
  static const Color primary = Color(0xFF5B5A8F); // purple-ish
  static const Color pageBg = Color(0xFFF3F4F8);

  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1F1F1F);
  static const Color textMuted = Color(0xFF6B7280);
  static const String myFontFamily = 'CircularPro';

  static const Color dashedBorder = Color(0xFF8E8CC9);

  static const double radius = 10;

  static TextStyle sectionTitle() => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textDark,
  );

  static TextStyle cardTitle() => const TextStyle(
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w700,
    fontFamily: 'CircularPro',
    color: textDark,
  );

  static TextStyle cardSubTitle() => const TextStyle(
    fontSize: 14,
    fontFamily: 'CircularPro',
    height: 1.43,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );
}
