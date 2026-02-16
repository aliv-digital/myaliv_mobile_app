import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class AutoRenewAuthPrepaidTheme {
  static const String fontFamily = 'CircularPro';

  static const Color primary = Color(0xFF655C9A); // close to your purple
  static const Color pageBg = Color(0xFFF3F4F6);
  static const Color cardBg = Colors.white;
  static const Color border = Color(0xFFE5E7EB);

  static const Color textDark = Color(0xFF111827);
  static final Color textMid = HexColor.fromHex('#707070');
  static final Color textInputFillColor = HexColor.fromHex('#F2F1F9');

  static TextStyle titleStyle() => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  static TextStyle paragraphStyle() =>  TextStyle(
    color: const Color(0xFF707070),
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  static TextStyle sectionHeaderStyle() => const TextStyle(
    color: const Color(0xFF707070),
    fontSize: 16,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static TextStyle signatureStyle() => const TextStyle(
    color: const Color(0xFF707070),
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    height: 1.43,
  );

  static TextStyle fieldLabelStyle() => const TextStyle(
    color: const Color(0xFF1C1C1C) /* Black-100% */,
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    height: 1.43,
  );
}
