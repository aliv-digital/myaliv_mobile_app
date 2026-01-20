import 'package:flutter/material.dart';

class TopUpPaymentPrepaidTheme {
  // Colors tuned for Figma look
  static const Color primary = Color(0xFF5E5A8F);
  static const Color background = Color(0xFFF3F4F8);
  static const Color card = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color tileBg = Color(0xFFF4F3FA);

  static const String fontFamily = 'CircularPro';

  static TextStyle titleMd(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle bodyMd(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.43
  );

  static TextStyle bodySm(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.43
  );

  static TextStyle labelSm(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle bottomPrice(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static TextStyle buttonText(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
}
