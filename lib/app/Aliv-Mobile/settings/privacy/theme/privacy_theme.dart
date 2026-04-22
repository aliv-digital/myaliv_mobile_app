import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class PrivacyTheme {
  static const String fontFamily = AppConstants.defaultFontFamily;

  static const Color bg = Color(0xFFF2F3F7);
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  static const double appBarHeight = 56;
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(16, 24, 16, 24);

  static const TextStyle title = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle body = TextStyle(
    color: Color(0xFF707070),
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  static const TextStyle sectionHeader = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );
}