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
  static const Color amountPillText = appBarBg;

  static const Color continueBtnBg = appBarBg;

  static const double appBarHeight = 56;

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
    color: text,
  );

  static TextStyle get service => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static TextStyle get smallMuted => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  static TextStyle get terms => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: text,
  );

  static TextStyle get link => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: text,
    decoration: TextDecoration.underline,
  );

  static TextStyle get amountPill => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.2,
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
