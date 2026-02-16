import 'package:flutter/material.dart';

class RevPaymentMethodPrepaidTheme {
  RevPaymentMethodPrepaidTheme._();

  static const String fontFamily = 'CircularPro';

  static const Color bg = Color(0xFFF2F3FA);
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color cardBg = Colors.white;

  static const Color text = Color(0xFF1F1F1F);
  static const Color muted = Color(0xFF7E7E8A);

  static const Color border = Color(0xFFE5E7EB);
  static const Color selectedBorder = Color(0xFF8B84C8);

  static const Color plus = appBarBg;
  static const Color payBtnBg = appBarBg;

  static const double appBarHeight = 56;

  static TextStyle get sectionTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: muted,
  );

  static TextStyle get methodTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: text,
  );

  static TextStyle get methodSubtitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  static TextStyle get addCard => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: plus,
  );

  static TextStyle get bottomAmount => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static TextStyle get bottomVat => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  static TextStyle get payNow => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
