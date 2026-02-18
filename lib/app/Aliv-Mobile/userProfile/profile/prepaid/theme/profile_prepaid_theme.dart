import 'package:flutter/material.dart';

class ProfilePrepaidTheme {
  static const bg = Color(0xFFFFFFFF);

  static const textBlack = Color(0xFF121212);
  static const textGrey = Color(0xFFB7B7C2);

  static const divider = Color(0xFFE9E9EE);
  static const chevron = Color(0xFFB7B7C2);

  static TextStyle t(
      double size, {
        FontWeight weight = FontWeight.w400,
        Color color = textBlack,
        double height = 1.25,
        double letterSpacing = 0,
      }) {
    return TextStyle(
      fontFamily: 'CircularPro',
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // Secuirity item label style from the approved Figma spec.
  static final TextStyle menuItemText = t(
    13,
    weight: FontWeight.w400,
    color: const Color(0xFF1C1C1C),
    letterSpacing: -0.26,
    height: 1.25,
  );
}
