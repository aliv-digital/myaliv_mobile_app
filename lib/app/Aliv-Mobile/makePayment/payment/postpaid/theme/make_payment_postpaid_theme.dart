import 'package:flutter/material.dart';

class MakePaymentPostPaidTheme {
  MakePaymentPostPaidTheme._();

  static const String fontFamily = 'CircularPro';

  static const Color bg = Color(0xFFF2F3FA);
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color cardBg = Colors.white;

  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textMuted = Color(0xFF7E7E8A);

  static const Color border = Color(0xFFE6E6F2);
  static const Color primary = appBarBg;
  static const Color radioBorder = Color(0xFFD3D1E8);

  static const Color optionSelectedBg = Color(0xFFF2F0FA);
  static const Color optionSelectedBorder = Color(0xFF8B84C8);

  static const Color amountFieldBg = Color(0xFFF1F1F1);
  static const Color customAmountBg = Color(0xFFF1F1F5);

  static const Color bottomBarBg = Colors.white;
  static const Color payButtonDisabled = Color(0xFFD3D1E8);

  static const double appBarHeight = 56;

  static TextStyle get title => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get sectionLabel => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get amountText => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get optionText => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get optionTextSelected => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: primary,
      );

  static TextStyle get helperLabel => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get customAmountText => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get customAmountHint => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle get termsText => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );

  static TextStyle get termsLink => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        decoration: TextDecoration.underline,
      );

  static TextStyle get methodTitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get methodName => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get methodSelectedName => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: primary,
      );

  static TextStyle get methodExpiry => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle get addCard => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: primary,
      );

  static TextStyle get bottomAmount => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get bottomSubtitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle get payNow => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );
}
