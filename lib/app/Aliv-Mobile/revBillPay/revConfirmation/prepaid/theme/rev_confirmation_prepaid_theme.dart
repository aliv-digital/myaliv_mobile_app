import 'package:flutter/material.dart';

class RevConfirmationPrepaidTheme {
  RevConfirmationPrepaidTheme._();

  static const String fontFamily = 'CircularPro';

  static const Color bg = Color(0xFFF2F3FA);
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color cardBg = Colors.white;

  static const Color text = Color(0xFF1F1F1F);
  static const Color muted = Color(0xFF7E7E8A);

  static const Color receiptBg = appBarBg;
  static const Color fieldBg = Colors.white;

  static const Color amountPillBorder = Color(0xFF8B84C8);
  static const Color amountPillBackground = Color(0xFFF4F4F6);
  static const Color amountPillText = Color(0xFF222222);
  static const double amountPillRadius = 8;
  static const double amountPillHorizontalPadding = 10;
  static const double amountPillVerticalPadding = 4;

  static const Color continueBtnBg = appBarBg;

  // Terms checkbox styling (from Figma)
  static const Color checkboxBorder = Color(0xFF645D9C);
  static const Color checkboxActive = Color(0xFF5146A8);
  static const Color checkboxCheckColor = Colors.white;
  static const double checkboxSize = 15;
  static const double checkboxCornerRadius = 2;
  static const double checkboxToTextGap = 10;

  static const double appBarHeight = 63;
  // Main content horizontal gutters in confirmation screen.
  static const double contentHorizontalPadding = 29;
  // Space from app bar to header card.
  static const double contentTopPadding = 24;
  // Space below main content before the scroll end/bottom bar area.
  static const double contentBottomPadding = 22;
  // Shared vertical gap between header->terms and terms->breakdown sections.
  static const double sectionGap = 17;

  // Header card spacing (from Figma)
  static const double headerCardHorizontalPadding = 16;
  static const double headerCardNameVerticalPadding = 14;
  static const double headerCardDetailsVerticalPadding = 20;

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
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static TextStyle get service => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // Figma requests w450; Flutter closest named weight is w500.
  static TextStyle get smallMuted => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    color: Color(0xFF707070),
  );

  // Figma requests w450; Flutter closest named weight is w500.
  static TextStyle get terms => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static TextStyle get link => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w700,
    color: Color(0xFF645D9C),
    decoration: TextDecoration.underline,
    decorationColor: Color(0xFF645D9C),
  );

  static TextStyle get amountPill => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: amountPillText,
  );

  static TextStyle get receiptLabel => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get receiptValue => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get promoHint => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: Color(0xFFB8B6D9),
  );

  static TextStyle get promoApply => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: appBarBg,
  );

  static TextStyle get bottomAmount => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: text,
  );

  static TextStyle get bottomVat => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  static TextStyle get continueText => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
