import 'package:flutter/material.dart';

class GuestPayBillTheme {
  // Colors (tune these if your app already has tokens)
  static const Color primary = Color(0xFF645D9C);
  static const Color pageBg = Colors.white;

  static const Color fieldBg = Color(0xFFF1F1F8);
  static const Color helperText = Color(0xFF2E57E8);

  static const Color labelText = Color(0xFF1C1C1C);
  static const Color placeholder = Color(0xFF9A9AA3);

  static const Color border = Color(0x00000000); // no border look
  static const Color disabledBtn = Color(0xFFCDCDDD);
  static const Color chipTextOnPrimary = Colors.white;

  static const double radius = 10;

  static TextStyle labelStyle() => const TextStyle(
        color: Color(0xFF1C1C1C),
        fontSize: 14,
        fontFamily: 'Circular Pro',
        fontWeight: FontWeight.w700,
        height: 1.43,
      );

  static TextStyle helperStyle() => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: helperText,
      );

  static InputDecoration fieldDecoration({
    required String hint,
    Widget? suffix,
    Widget? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: placeholder,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: border),
      ),
      suffixIcon: suffix,
      prefixIcon: prefix,
    );
  }
}
