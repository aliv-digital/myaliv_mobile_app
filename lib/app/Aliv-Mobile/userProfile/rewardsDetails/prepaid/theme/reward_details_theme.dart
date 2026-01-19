import 'package:flutter/material.dart';

class RewardDetailsTheme {
  static const bg = Color(0xFFF1F2FA);

  static const purple = Color(0xFF655C9A);

  static const textBlack = Color(0xFF121212);
  static const textGrey = Color(0xFF707070);

  static TextStyle t(
      double size, {
        FontWeight weight = FontWeight.w400,
        Color color = textBlack,
        double height = 1.2,
      }) {
    return TextStyle(
      fontFamily: 'CircularPro',
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }
}
