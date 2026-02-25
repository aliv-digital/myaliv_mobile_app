import 'package:flutter/material.dart';

class EditEmailPrepaidTheme {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color brand = Color(0xFF645D9C);
  static const Color textMuted = Color(0xFF8B8B8B);

  static const Color inputBg = Color(0xFFF1F2FA);
  static const Color inputBorder = Color(0xFFDFDFDF);

  static const double inputBorderWidth = 1;
  static const double editEmailInputRadius = 10;
  static const double updateEmailInputRadius = 8;

  // Focused input border gradient palette (login-like behavior).
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

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w700,
    color: Color(0xFF1C1C1C),
  );

  static const TextStyle fieldValue = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 14,
    height: 1.43,
    // Closest available Flutter weight for requested w450.
    fontWeight: FontWeight.w500,
    color: Color(0xFF707070),
  );
}
