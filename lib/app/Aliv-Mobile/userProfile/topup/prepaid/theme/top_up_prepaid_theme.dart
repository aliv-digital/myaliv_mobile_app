import 'package:flutter/material.dart';

class TopUpPrepaidTheme {
  TopUpPrepaidTheme._();

  // ✅ Global font
  static const String fontFamily = 'CircularPro';

  // ✅ Colors (match your design tone)
  static const Color primary = Color(0xFF645D9C); // purple appbar/button
  static const Color pageBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F1F1F);
  static const Color textMuted = Color(0xFF7C7C7C);

  static const Color pillBg = Color(0xFFF1F2F4);
  static const Color divider = Color(0xFFE6E6EA);
  static const Color purple = Color(0xFF645D9C);
  static const Color purple4 = Color(0xFF5045A7);
  static const Color lightBg = Color(0xFFF1F1F8);

  static const double radius = 14;

  // ✅ Gradient border colors (approx from screenshot)
  static const List<Color> amountBorderGradient = [
    Color(0xFF2ECC71), // green
    Color(0xFFF1C40F), // yellow
    Color(0xFF8E44AD), // purple
    Color(0xFFFF6B6B), // coral
  ];

  // -----------------------
  // Text styles
  // -----------------------
  static TextStyle appBarTitle() => const TextStyle(
    fontFamily: fontFamily,
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle tabSelected() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: primary,
  );

  static TextStyle tabUnselected() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textMuted,
  );

  static TextStyle balanceLabel() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: primary,
  );

  static TextStyle pillText() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static TextStyle amountText() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: primary,
    height: 1.0,
  );

  static TextStyle amountHint() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textDark,
  );

  static TextStyle buttonText() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
