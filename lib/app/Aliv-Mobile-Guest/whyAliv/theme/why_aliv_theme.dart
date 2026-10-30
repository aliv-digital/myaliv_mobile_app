import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class WhyAlivTheme {
  static Color appBarColor = HexColor.fromHex('#645D9C');
  static Color headingColor = ColorManager.primaryPurple;
  static Color bodyTextColor = HexColor.fromHex('#707070');

  static const Color backgroundColor = Colors.white;
  static const Color alternateSectionColor = Color(0xFFF1F2FA);
  static const EdgeInsets heroPadding = EdgeInsets.fromLTRB(24, 24, 24, 32);
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 24,
  );
  static const double heroImageWidth = 311;
  static const double heroImageHeight = 280;
  static const double imageToHeadingGap = 32;
  static const double headingToBodyGap = 16;
  static const double sectionNumberGap = 8;

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
    fontSize: 40,
    height: 1.3,
    letterSpacing: 0,
    fontFamily: 'CircularProBold',
    fontWeight: FontWeight.w700,
    color: headingColor,
  );

  // Heading 2 style
  static final TextStyle headingTwo = TextStyle(
    fontSize: 18,
    height: 1.25,
    letterSpacing: 0,
    fontFamily: 'CircularProBold',
    fontWeight: FontWeight.w700,
    color: headingColor,
  );

  // Body text style
  static final TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0,
    fontFamily: 'CircularProBook',
    fontWeight: FontWeight.w400,
    color: Color(0xFF707070),
  );

  // SnackBar message text
  static final TextStyle snackBarText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
  );
}
