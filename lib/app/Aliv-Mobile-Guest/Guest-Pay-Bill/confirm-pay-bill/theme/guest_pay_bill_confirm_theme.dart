import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class GuestPayBillConfirmTheme {
  static const Color primary = Color(0xFF5A5796);
  static const Color pageBg = Color(0xFFF2F3FA);
  static const Color cardWhite = Colors.white;

  static const Color receiptBg = Color(0xFF5A5796);
  static const Color textDark = Color(0xFF1C1C1E);
  static const Color textLight = Colors.white;
  static  Color hint = HexColor.fromHex('#707070');
  static const Color border = Color(0xFF5A5796);
  static Color paymentBreakDownCardColor = HexColor.fromHex('#645D9C');
  static const String myFontFamily = 'CircularPro';


  static Color amountBackground = HexColor.fromHex('#EDEBF7');
  static Color amountText = HexColor.fromHex('#5146A8');

  static TextStyle appBarTitle() => const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle headerTitle() => const TextStyle(
    color: textDark,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: 'CircularPro'
  );

  static TextStyle headerSub() => const TextStyle(
    color: Color(0xFF121212),
    fontSize: 16,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w400,
    // Circular Pro requested at 450; Flutter font weight constants are 100 steps.
    // This keeps visual weight close to 450 when variable font data is available.
    fontVariations: [FontVariation('wght', 450)],
  );

  static TextStyle terms() => const TextStyle(
    color: textDark,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle receiptLabel() => const TextStyle(
    color: textLight,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle receiptValue() => const TextStyle(
    color: textLight,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bottomAmount() => const TextStyle(
    color: textDark,
    fontSize: 22,
    fontFamily: GuestPayBillConfirmTheme.myFontFamily,
    fontWeight: FontWeight.w700,
  );

  static TextStyle bottomCaption() => TextStyle(
    color: hint,
    fontSize: 12,
    fontFamily: GuestPayBillConfirmTheme.myFontFamily,
    fontWeight: FontWeight.w500,
  );
}
