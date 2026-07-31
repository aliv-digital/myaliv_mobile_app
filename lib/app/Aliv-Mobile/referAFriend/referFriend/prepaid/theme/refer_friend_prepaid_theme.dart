import 'package:flutter/material.dart';

class ReferFriendPrepaidTheme {
  static const bg = Colors.white;

  // matches your existing purple tone family
  static const brand = Color(0xFF645D9C);
  static const text = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE6E6EC);
  static const error = Color(0xFFFF3B30);
  static const fieldBg = Color(0xFFF1F1F8);
  static const fieldHeight = 50.0;
  static const countryWidth = 60.0;
  static const countryToPhoneGap = 10.0;
  static const fieldRadius = 8.0;
  static const fieldBorderWidth = 1.0;
  static const fieldHorizontalPadding = 14.0;
  static const countryPickerHorizontalPadding = 8.0;
  static const countryFlagToCodeGap = 6.0;
  static const countryCodeToArrowGap = 4.0;
  static const countryArrowSize = 16.0;

  // Focused input border gradient palette (login-like).
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

  static const title = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static const tab = TextStyle(
    color: Color(0xFF707070),
    fontSize: 14,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    height: 1,
  );

  static const tabActive = TextStyle(
    color: Color(0xFF645D9C),
    fontSize: 14,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    height: 1,
  );

  static const label = TextStyle(
    color: Color(0xFF1C1C1C) /* Black-100% */,
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    height: 1.43,
  );

  static const helper = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 12.5,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: muted,
  );

  static const button = TextStyle(
    color: Color(0xFFF1F1F8),
    fontSize: 15,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  static const fieldHint = TextStyle(
    color: Color(0xFF707070),
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  static const fieldInput = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF344054),
  );

  static const countryFlag = TextStyle(
    fontSize: 20,
    fontFamily: 'CircularPro',
  );

  static const countryCode = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'CircularPro',
    color: Color(0xFF000000),
  );

  static const fieldError = TextStyle(
    fontSize: 12,
    fontFamily: 'CircularPro',
    color: error,
  );
}
