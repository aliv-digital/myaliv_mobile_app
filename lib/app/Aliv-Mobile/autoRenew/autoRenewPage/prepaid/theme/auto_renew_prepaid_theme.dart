import 'package:flutter/material.dart';

class AutoRenewPrepaidTheme {
  static const Color primary = Color(0xFF645D9C);
  static const Color pageBg = Color(0xFFF3F4F8);

  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color textDark = Color(0xFF1F1F1F);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color dashedBorder = Color(0xFF8E8CC9);

  static const String fontFamily = 'CircularPro';

  static TextStyle sectionTitle() => const TextStyle(
    color: Colors.black,
    fontSize: 13,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
  );

  static TextStyle tileTitle({bool selected = false}) => TextStyle(
       fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
    color: selected ? const Color(0xFF645D9C):Color(0xFF222222),
    fontSize: 14,
    fontFamily: 'CircularPro',
    height: 1.43,
  );

  static TextStyle tileSubtitle({bool selected = false}) => TextStyle(
    // color: selected ? const Color(0xFF645D9C): const Color(0xCC5146A8),
    color: selected ? const Color(0xFF645D9C):Color(0xFF222222),

    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
    height: 1.43,
  );
}
