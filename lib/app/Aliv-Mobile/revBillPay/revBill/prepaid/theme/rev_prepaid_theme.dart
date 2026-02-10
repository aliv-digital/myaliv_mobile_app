import 'package:flutter/material.dart';

class RevPrepaidTheme {
  RevPrepaidTheme._();

  static const String fontFamily = 'CircularPro';

  // Design colors (match your screenshot)
  static const Color bg = Colors.white;
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color fieldBg = Color(0xFFF3F2FB);
  static const Color hint = Color(0xFF8E8E98);
  static const Color text = Color(0xFF1F1F1F);
  static const Color proceedDisabled = Color(0xFFD6D5E6);

  static const double appBarHeight = 56;

  static TextStyle get label => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static TextStyle get input => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    color: text,
  );

  static TextStyle get hintText => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: hint,
  );

  static TextStyle get value => input;

  static TextStyle get button => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get submit => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}
