import 'package:flutter/material.dart';

class EditEmailPrepaidTheme {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color brand = Color(0xFF645D9C);
  static const Color textMuted = Color(0xFF8B8B8B);

  static const Color inputBg = Color(0xFFF1F2FA);

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
