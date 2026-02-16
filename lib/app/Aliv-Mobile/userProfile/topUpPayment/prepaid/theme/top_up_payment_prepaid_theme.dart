import 'package:flutter/material.dart';

class TopUpPaymentPrepaidTheme {
  // Colors tuned for Figma look
  static const Color primary = Color(0xFF645D9C);
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
    color: Colors.black,
    fontSize: 13,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
  );

  static TextStyle bottomPrice(BuildContext context) => const TextStyle(
      color: const Color(0xFF222222),
      fontSize: 22,
      fontFamily: 'CircularPro',
      fontWeight: FontWeight.w700,
  );

  static TextStyle buttonText(BuildContext context) => const TextStyle(
    color: const Color(0xFFF1F1F8),
    fontSize: 13,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
  );
}
