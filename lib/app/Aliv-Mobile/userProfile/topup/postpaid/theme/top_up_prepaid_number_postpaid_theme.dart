import 'package:flutter/material.dart';

class TopUpPrepaidNumberPostPaidTheme {
  static const String fontFamily = 'CircularPro';

  static const Color primary = Color(0xFF645D9C);
  static const Color pageBg = Color(0xFFF4F5F9);

  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color fieldBg = Color(0xFFEFF0F7);

  static const double radius = 10;

  static const List<Color> amountBorderGradient = [
    Color(0xFFFFC107),
    Color(0xFF00C2FF),
    Color(0xFF4F46E5),
    Color(0xFFFF7043),
  ];

  static TextStyle label() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  static TextStyle hint() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: textMuted,
  );

  static InputDecoration fieldDecoration({required String hintText}) => InputDecoration(
    hintText: hintText,
    hintStyle: hint(),
    filled: true,
    fillColor: fieldBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

  static TextStyle amountText() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: primary,
    height: 1.0,
  );

  static TextStyle amountHint() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textDark,
  );
}
