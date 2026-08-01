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
  static const Color inputBorder = Color(0xFFE0E0E0);

  static const double radius = 14;

  // ✅ Gradient border colors (approx from screenshot)
  static const List<Color> amountBorderGradient = [
    Color(0xFF2ECC71), // green
    Color(0xFFF1C40F), // yellow
    Color(0xFF8E44AD), // purple
    Color(0xFFFF6B6B), // coral
    Color.fromRGBO(0, 179, 227, 1),
  ];

  // Amount box layout + border behavior
  static const double amountFieldWidth = 280;
  static const double amountFieldHeight = 92;
  static const double amountFieldRadius = 10;
  static const double amountFieldBorderWidth = 2;
  static const double amountFieldMinInputWidth = 80;
  static const double amountFieldMaxInputWidth = 200;
  static const double amountFieldCurrencyGap = 6;
  static const Color amountFieldBackground = Colors.white;

  static const LinearGradient amountFieldFocusedBorderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: amountBorderGradient,
  );

  // Focused input border gradient palette (login-like)
  static const Color focusedInputBorderYellow = Color(0xFFFFC627);
  static const Color focusedInputBorderBlue = Color(0xFF00B3E3);
  static const Color focusedInputBorderPurple = Color(0xFF4B298C);
  static const Color focusedInputBorderPink = Color(0xFFFF9BB1);
  static const Color focusedInputBorderOrange = Color(0xFFFF6C36);

  static const LinearGradient focusedInputBorderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      focusedInputBorderYellow,
      focusedInputBorderBlue,
      focusedInputBorderPurple,
      focusedInputBorderPink,
      focusedInputBorderOrange,
    ],
  );

  // Shared form input field sizing
  static const double formInputHeight = 52;
  static const double formInputRadius = 8;
  static const double formInputBorderWidth = 1;
  static const EdgeInsets formInputHorizontalPadding =
      EdgeInsets.symmetric(horizontal: 16);

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
    color: const Color(0xFF5045A7),
    fontSize: 13,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
  );

  static TextStyle pillText() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static TextStyle amountText() => const TextStyle(
    color: const Color(0xFF5045A7),
    fontSize: 40,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,

  );

  static TextStyle amountHint() => TextStyle(
    color: const Color(0xFF5045A7).withValues(alpha: 0.35),
    fontSize: 40,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  static TextStyle buttonText() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: const Color(0xFFF1F1F8),
  );
}
