import 'package:flutter/material.dart';

class AutoRenewPrepaidTheme {
  static const Color primary = Color(0xFF5B5A8F);
  static const Color pageBg = Color(0xFFF3F4F8);

  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color textDark = Color(0xFF1F1F1F);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color dashedBorder = Color(0xFF8E8CC9);

  static const String fontFamily = 'CircularPro';

  static TextStyle sectionTitle() => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textDark,
    fontFamily: fontFamily,
  );

  static TextStyle tileTitle({bool selected = false}) => TextStyle(
    fontSize: 14,
    height: 1.3,
    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
    color: textDark,
    fontFamily: fontFamily,
  );

  static TextStyle tileSubtitle() => const TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: textMuted,
    fontFamily: fontFamily,
  );
}
