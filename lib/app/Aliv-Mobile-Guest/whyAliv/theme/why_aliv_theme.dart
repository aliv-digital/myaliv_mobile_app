import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class WhyAlivTheme {
  static Color appBarColor = HexColor.fromHex('#645D9C');
  static Color headingColor = HexColor.fromHex('#000000');
  static Color bodyTextColor = HexColor.fromHex('#707070');

  // App bar title text
  static final TextStyle appBarTitle = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w600,
    color: Color(0xFFFFFFFF),
  );

  // Heading 1 style
  static final TextStyle headingOne = TextStyle(
    fontSize: 18,
    fontFamily: 'Circular Pro',
    fontWeight: FontWeight.w700,
    color: Color(0xFF000000),
  );

  // Heading 2 style
  static final TextStyle headingTwo = TextStyle(
    fontSize: 18,
    fontFamily: 'Circular Pro',
    fontWeight: FontWeight.w700,
    color: Color(0xFF000000),
  );

  // Body text style
  static final TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontFamily: 'Circular Pro',
    fontWeight: FontWeight.w400,
    color: Color(0xFF707070),
  );

  // SnackBar message text
  static final TextStyle snackBarText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
  );

}
