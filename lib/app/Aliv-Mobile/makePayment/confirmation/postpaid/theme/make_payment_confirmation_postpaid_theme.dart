import 'package:flutter/material.dart';

class MakePaymentConfirmationPostPaidTheme {
  MakePaymentConfirmationPostPaidTheme._();

  static const String fontFamily = 'CircularPro';

  static const Color bg = Color(0xFFF2F3FA);
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color cardBg = Colors.white;
  static const Color receiptBg = appBarBg;

  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textMuted = Color(0xFF7E7E8A);

  static const Color amountPillBorder = Color(0xFF8B84C8);
  static const Color amountPillText = appBarBg;
  static const Color amountPillBg = Color(0xFFEDEBF7);

  static const Color dashedDivider = Color(0xB3FFFFFF);

  static const Color continueBtnBg = appBarBg;

  static const double appBarHeight = 56;
  static const double cardRadius = 12;
  static const double pillRadius = 8;

  static TextStyle get title => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get name => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get accountNumber => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      );

  static TextStyle get headerLabel => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get amountPill => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: amountPillText,
      );

  static TextStyle get promoInput => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: appBarBg,
      );

  static TextStyle get promoHint => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: Color(0xFFD0D0D0),
      );

  static TextStyle get promoApply => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: appBarBg,
      );

  static TextStyle get receiptLabel => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get receiptValue => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get receiptTotal => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.1,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      );

  static TextStyle get bottomAmount => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      );

  static TextStyle get bottomSubtitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle get continueText => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );
}
