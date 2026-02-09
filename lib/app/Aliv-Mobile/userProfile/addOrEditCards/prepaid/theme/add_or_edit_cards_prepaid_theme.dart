import 'package:flutter/material.dart';

class AddOrEditCardsPrepaidTheme {
  static const Color primary = Color(0xFF645D9C); // purple-ish
  static const Color pageBg = Color(0xFFF3F4F8);

  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1F1F1F);
  static const Color textMuted = Color(0xFF707070);
  static const String myFontFamily = 'CircularPro';

  static const Color dashedBorder = Color(0xFF645D9C);

  static const double radius = 8;

  static TextStyle sectionTitle() => const TextStyle(
    color: Colors.black,
    fontSize: 13,
    fontFamily: 'Circular Pro',
    fontWeight: FontWeight.w500,
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
