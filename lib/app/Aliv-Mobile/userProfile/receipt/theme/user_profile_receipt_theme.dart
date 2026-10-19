import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class UserProfileReceiptTheme {
  static final Color screenBackground = HexColor.fromHex('#F1F2FA');
  static final Color appBarColor = HexColor.fromHex('#645D9C');
  static final Color circleBackground = HexColor.fromHex('#FCE8E1');

  static final Color successIconOuter = HexColor.fromHex('#E6F4EC');
  static final Color successIconInner = HexColor.fromHex('#2E9E5B');
  static final Color successTitleColor = HexColor.fromHex('#111111');
  static final Color successBodyColor = HexColor.fromHex('#707070');
  static final Color successCardBackgroundColor = HexColor.fromHex('#FFFFFF');
  static const Color successCardShadowColor = Colors.transparent;
  static final Color successCardBottomDividerColor = HexColor.fromHex(
    '#E9E9EE',
  );
  static final Color defaultDashColor = HexColor.fromHex('#DDDDDD');
  static final Color successButtonTextColor = HexColor.fromHex('#645D9C');
  static final Color valueTextBlack = HexColor.fromHex('#121212');

  static const double cardCornerRadius = 12;
  static const double cardElevation = 0;
  static const EdgeInsets cardPadding = EdgeInsets.fromLTRB(24, 32, 24, 32);
  static const double cardNotchRadius = 10;
  static const double cardNotchTopOffset = 164;

  static const double successIconOuterSize = 56;
  static const double successIconInnerSize = 30;
  static const double successIconCheckSize = 18;
  static const double cardContentWidth = 297;

  static const double gapAfterIcon = 16;
  static const double gapAfterTitle = 32;
  static const double gapAfterMessage = 16;
  static const double gapBeforeAmount = 16;
  static const double gapAfterAmount = 32;
  static const double gapAfterBottomDivider = 32;
  static const double gapAfterButton = 56;

  static const double dashedDividerStrokeWidth = 1;
  static const double dashedDividerHorizontalInset = 6;
  static const double bottomDividerThickness = 1;
  static const double detailRowVerticalPadding = 7;

  static final TextStyle successTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: successTitleColor,
  );

  static final TextStyle successBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: successBodyColor,
  );

  static final TextStyle detailLabel = TextStyle(
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: HexColor.fromHex('#7A7A7A'),
  );

  static final TextStyle detailValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: valueTextBlack,
  );

  static final TextStyle detailValueBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: valueTextBlack,
  );

  static final TextStyle backButtonText = TextStyle(
    color: successButtonTextColor,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
  );

  static const Color backButtonBackgroundColor = Colors.white;
  static final Color backButtonBorderColor = HexColor.fromHex('#F2F1F9');
  static const double backButtonWidth = 156;
  static const double backButtonHeight = 48;
  static const double backButtonRadius = 100;
  static const EdgeInsets backButtonPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 12,
  );
}
