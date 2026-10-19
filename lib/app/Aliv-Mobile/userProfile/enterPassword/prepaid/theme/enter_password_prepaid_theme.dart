import 'package:flutter/material.dart';

class EnterPasswordPrepaidTheme {
  static const Color bg = Colors.white;
  static const Color brand = Color(0xFF5D5A8B);
  static const Color biometricButtonBorder = Color(0xFFF2F1F9);
  static const Color muted = Color(0xFF6B7280);
  static const Color termsBase = Color(0xFF58677D);
  static const Color inputBorder = Color(0xFFE6E6EC);
  static const Color link = Color(0xFF645D9C);
  static const Color biometricButtonTextColor = Color(0xCC5146A8);

  static const TextStyle title = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: muted,
  );

  // Figma requests w450; Flutter closest named weight is w500.
  static const TextStyle legalIntro = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: termsBase,
  );

  static const TextStyle legalLink = TextStyle(
    color: link,
    fontSize: 13,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    decorationColor: link,
  );

  static const TextStyle biometricButtonText = TextStyle(
    color: biometricButtonTextColor,
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    height: 1.43,
  );
}
