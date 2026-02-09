import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class GuestTopUpTheme {
  static Color appBarColor = HexColor.fromHex('#645D9C');
  static Color headingColor = HexColor.fromHex('#000000');
  static Color bodyTextColor = HexColor.fromHex('#707070');
  static Color inputFieldBackgroundColor = HexColor.fromHex('#F2F1F9');

  // Gradient border colors (Figma)
  static Color yellow = HexColor.fromHex('#FFC627');
  static Color blue = HexColor.fromHex('#00B3E3');
  static Color purple = HexColor.fromHex('#4B298C');
  static Color lightPink = HexColor.fromHex('#FF9BB1');
  static Color orange = HexColor.fromHex('#FF6C36');

  // Selection color (Figma)
  static Color selection = HexColor.fromHex('#5146A8');


  static Color amountTextColor = HexColor.fromHex('#5146A8');
  static Color simpleTxt = HexColor.fromHex('#222222');

  static final Color amountValueColor = HexColor.fromHex('#5A4FB6');

  // Input label text above phone fields
  static final TextStyle inputLabel = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // Phone input text
  static final TextStyle phoneInput = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: Color(0xFF000000),
  );

  // Phone input hint
  static final TextStyle phoneHint = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    color: HexColor.fromHex('#B0B0B5'),
  );

  // Country dial code text inside picker
  static final TextStyle dialCode = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: Color(0xFF111111),
  );

  // Top-up amount input text
  static final TextStyle amountInput = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: amountValueColor,
  );

  // Top-up amount prefix ($)
  static final TextStyle amountPrefix = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: amountValueColor,
  );

  // Top-up amount hint
  static final TextStyle amountHint = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: amountValueColor,
  );

  // Helper text below amount field
  static final TextStyle amountHelper = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: simpleTxt,
  );

  // SnackBar message text
  static final TextStyle snackBarText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
  );
}
