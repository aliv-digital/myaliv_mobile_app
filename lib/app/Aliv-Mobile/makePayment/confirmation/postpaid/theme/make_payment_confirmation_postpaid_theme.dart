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

  static const Color amountPillText = Color(0xFF222222);
  static const Color amountPillBg = Color(0xFFF4F4F6);

  static const Color dashedDivider = Color(0xB3FFFFFF);

  static const Color continueBtnBg = appBarBg;

  static const double appBarHeight = 63;
  static const double cardRadius = 12;
  static const double pillRadius = 5;
  static const EdgeInsets amountPillPadding =
      EdgeInsets.symmetric(horizontal: 10, vertical: 4);

  // Header card spacing (Figma-aligned).
  static const EdgeInsets headerTopSectionPadding =
      EdgeInsets.fromLTRB(16, 14, 16, 14);
  static const double headerNameToAccountGap = 0;
  static const EdgeInsets headerBottomSectionPadding =
      EdgeInsets.fromLTRB(16, 10, 16, 20);
  static const Color headerDividerColor = Color(0xFFE6E6F2);
  static const double headerDividerThickness = 1;

  static TextStyle get title => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get name => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        height: 1,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      );

  static TextStyle get accountNumber => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 1,
        fontWeight: FontWeight.w400, // Closest supported weight to Figma w450.
        color: Color(0xFF121212),
      );

  static TextStyle get headerLabel => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      );

  static TextStyle get amountPill => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
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
