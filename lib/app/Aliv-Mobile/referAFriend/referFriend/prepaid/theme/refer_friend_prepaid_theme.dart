import 'package:flutter/material.dart';

class ReferFriendPrepaidTheme {
  static const bg = Colors.white;

  // matches your existing purple tone family
  static const brand = Color(0xFF5D5A8B);
  static const text = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const border = Color(0xFFE6E6EC);
  static const fieldBg = Color(0xFFF3F4F6);

  static const title = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static const tab = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  static const tabActive = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: brand,
  );

  static const label = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: text,
  );

  static const helper = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 12.5,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: muted,
  );

  static const button = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
