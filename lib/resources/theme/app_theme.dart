import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class AppTheme {
  // Palette for universal payment breakdown card widgets.
  static const Color paymentBreakdownCardBackgroundColor = Color(0xFF645D9C);
  static const Color paymentBreakdownCardTextColor = Color(0xFFFFFFFF);
  static const Color paymentBreakdownCardDividerColor = Color(0xB3FFFFFF);
  static const Color paymentBreakdownCardShadowColor = Color(0x22000000);

  static Color defaultAppBarColor = HexColor.fromHex('#645D9C');

  // Card shape and shadow.
  static const double paymentBreakdownCardTopCornerRadius = 20;
  static const double paymentBreakdownCardElevation = 10;

  // Bottom scallop geometry.
  static const int paymentBreakdownScallopCount = 12;
  static const double paymentBreakdownScallopGap = 4;
  static const double paymentBreakdownScallopDepth = 6;
  static const double paymentBreakdownScallopSideInset = 10;
  static const double paymentBreakdownScallopOvalHeightFactor = 0.72;

  // Card content spacing.
  static const EdgeInsets paymentBreakdownCardPadding =
  EdgeInsets.fromLTRB(16, 20, 16, 20);
  static const double paymentBreakdownRowGap = 14;
  static const double paymentBreakdownGapBeforeDivider = 24;
  static const double paymentBreakdownGapAfterDivider = 24;
  static const double paymentBreakdownBottomInnerGap = 20;

  // Dashed divider style.
  static const double paymentBreakdownDividerHeight = 1;
  static const double paymentBreakdownDividerDashWidth = 6;
  static const double paymentBreakdownDividerDashGap = 5;

  // Optional promo input row style.
  static const Color paymentBreakdownPromoBackgroundColor = Color(0xFFFFFFFF);
  static const double paymentBreakdownPromoHeight = 52;
  static const double paymentBreakdownPromoRadius = 10;
  static const EdgeInsets paymentBreakdownPromoPadding =
  EdgeInsets.symmetric(horizontal: 16);
  static const double paymentBreakdownPromoActionGap = 6;
  static const double paymentBreakdownPromoBottomGap = 24;
  static const double paymentBreakdownPromoDisabledOpacity = 0.45;

  // Typography used by universal payment breakdown card widgets.
  static final TextStyle paymentBreakdownRowText = TextStyle(
    color: paymentBreakdownCardTextColor,
    fontSize: 15,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    height: 1.1,
  );

  static final TextStyle paymentBreakdownEmphasizedRowText = TextStyle(
    color: paymentBreakdownCardTextColor,
    fontSize: 15,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  static final TextStyle paymentBreakdownPromoText = TextStyle(
    color: const Color(0xFF202020),
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle paymentBreakdownPromoHint = TextStyle(
    color: const Color(0xFFC5C5C8),
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle paymentBreakdownPromoAction = TextStyle(
    color: paymentBreakdownCardBackgroundColor,
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );
}
