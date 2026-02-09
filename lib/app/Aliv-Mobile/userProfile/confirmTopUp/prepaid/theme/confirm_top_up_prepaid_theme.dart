import 'package:flutter/material.dart';

class ConfirmTopUpPrepaidTheme {
  // Colors (tuned to match screenshot)
  static const Color primary = Color(0xFF645D9C);
  static const Color background = Color(0xFFF3F4F8);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color ticket = Color(0xFF645D9C);
  static const Color ticketText = Colors.white;
  static const Color border = Color(0xFFE5E7EB);

  static const String fontFamily = 'CircularPro';

  // Text Styles
  static TextStyle titleLg(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle titleMd(BuildContext context) => const TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: 'Circular Pro',
    fontWeight: FontWeight.w700,
  );

  static TextStyle bodyMd(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle bodySm(BuildContext context) => const TextStyle(
    color: const Color(0xFF121212),
    fontSize: 16,
    fontFamily: 'Circular Pro',
    fontWeight: FontWeight.w500,

  );

  static TextStyle link(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    decoration: TextDecoration.underline,
  );

  static TextStyle pillAmount(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: primary,
  );

  static TextStyle ticketLabel(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ticketText,

  );

  static TextStyle ticketValue(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ticketText,
  );

  static TextStyle bottomPrice(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle buttonText(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
