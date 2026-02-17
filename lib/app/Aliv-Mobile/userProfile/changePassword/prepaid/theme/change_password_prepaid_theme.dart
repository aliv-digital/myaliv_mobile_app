import 'package:flutter/material.dart';

class ChangePasswordPrepaidTheme {
  static const Color bg = Color(0xFFF3F4FB); // screenshot-like light lavender
  static const Color brand = Color(0xFF5D5A8B);
  static const Color hint = Color(0xFFB1B1B1);
  static const Color inputBg = Color(0xFFF7F7FB);
  static const Color inputBorder = Color(0xFFE6E6EC);
  static const Color mutedText = Color(0xFF58677D);

  // Figma requests w450; Flutter closest named weight is w500.
  static const TextStyle helper = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: mutedText,
  );
}
