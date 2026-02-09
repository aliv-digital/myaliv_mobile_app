import 'package:flutter/material.dart';

class ReferFriendPrepaidTheme {
  static const bg = Colors.white;

  // matches your existing purple tone family
  static const brand = Color(0xFF645D9C);
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
    color: const Color(0xFF707070),
    fontSize: 14,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    height: 1,
  );

  static const tabActive = TextStyle(
    color: const Color(0xFF645D9C),
    fontSize: 14,
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    height: 1,
  );

  static const label = TextStyle(
    color: const Color(0xFF1C1C1C) /* Black-100% */,
    fontSize: 14,
    fontFamily: 'Circular Pro',
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
    color: const Color(0xFFF1F1F8),
    fontSize: 13,
    fontFamily: 'Circular Pro',
    fontWeight: FontWeight.w500,
  );
}
