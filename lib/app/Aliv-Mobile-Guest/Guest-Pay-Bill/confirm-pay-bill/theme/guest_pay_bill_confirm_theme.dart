import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class GuestPayBillConfirmTheme {
  // ===== Strings =====
  static const String appBarTitle = 'confirmation and payment';
  static const String payNowLabel = 'pay now';
  static const String vatExclusiveLabel = 'vat exclusive';
  static const String termsPrefix = 'By checking this box, I agree to the ';
  static const String termsLinkText = 'Terms & Conditions.';
  static const String termsValidationMessage =
      'Please check Terms & Conditions first.';
  static const String subTotalLabel = 'sub total';
  static const String vatLabel = 'vat';
  static const String totalLabel = 'total';

  // ===== Colors =====
  static const Color primary = Color(0xFF5A5796);
  static const Color pageBg = Color(0xFFF2F3FA);
  static const Color cardWhite = Colors.white;
  static const Color receiptBg = Color(0xFF5A5796);
  static const Color textDark = Color(0xFF1C1C1E);
  static const Color textLight = Colors.white;
  static const Color hint = Color(0xFF707070);
  static const Color amountBackground = Color(0xFFF4F4F6);
  static const Color amountText = Color(0xFF222222);
  static const Color paymentBreakDownCardColor = Color(0xFF645D9C);
  static const Color snackBarBackground = Color(0xFF323232);
  static const Color termsLinkColor = Color(0xFF645D9C);
  static const Color termsCheckboxFillColor = Color(0xFF645D9C);
  static const Color termsCheckboxBorderColor = Color(0xFF645D9C);
  static const Color termsCheckboxUncheckedColor = Colors.white;

  // ===== Layout =====
  static const EdgeInsets contentPadding = EdgeInsets.only(
    left: 29,
    right: 29,
    top: 21,
  );
  static const double headerTopGap = 20;
  static const double sectionGap = 17;
  static const double breakdownBottomGap = 18;
  static const double termsCheckboxSize = 24;
  static const double termsCheckboxRadius = 4;
  static const double termsCheckboxTopInset = 5;
  static const double termsCheckboxBorderWidth = 1;
  static const double termsCheckboxToTextGap = 10;
  static const double termsTextWidth = 307;

  // Header summary card inner spacing from Figma:
  // top/bottom = 24, left/right = 16.
  static const EdgeInsets headerCardPadding = EdgeInsets.only(
    top: 24,
    bottom: 24,
    left: 16,
    right: 16,
  );
  // Rounded corner radius for summary card container.
  static const double headerCardRadius = 12;
  static const double headerToSubtitleGap = 4;
  static const double headerTextToAmountPillGap = 10;

  // Amount chip spacing from Figma:
  // left/right = 10, top/bottom = 4.
  static const EdgeInsets amountPillPadding = EdgeInsets.only(
    left: 10,
    right: 10,
    top: 4,
    bottom: 4,
  );
  // Amount chip corner radius from Figma.
  static const double amountPillRadius = 5;

  // Bottom bar layout
  static const EdgeInsets bottomBarPadding =
      EdgeInsets.fromLTRB(18, 12, 18, 14);
  static const double bottomBarAmountToCaptionGap = 2;
  static const double bottomBarButtonHeight = 40;
  static const double bottomBarButtonWidth = 150;
  static const double bottomBarButtonRadius = 22;
  static const double bottomBarLoadingSize = 18;
  static const double bottomBarLoadingStroke = 2;

  // Payment breakdown layout
  static const double breakdownTopCornerRadius = 18;
  static const double breakdownElevation = 8;
  static const double breakdownOvalHeight = 15;
  static const double breakdownScallopGap = 8;
  static const double breakdownEdgeInset = 0;
  static const int breakdownTargetScallopCount = 12;
  static const EdgeInsets breakdownPadding = EdgeInsets.only(
    top: 20,
    bottom: 20,
    left: 16,
    right: 16,
  );
  static const double breakdownRowGap = 14;
  static const double breakdownGapBeforeDivider = 24;
  static const double breakdownGapAfterDivider = 24;
  static const double breakdownBottomInnerGap = 18;
  static const Color breakdownDividerColor = Color(0xB3FFFFFF);
  static const double breakdownDividerHeight = 1;
  static const double breakdownDividerDashWidth = 6;
  static const double breakdownDividerDashGap = 5;

  // ===== Text styles =====
  static const TextStyle snackBarText = TextStyle(
    color: Colors.white,
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle headerTitle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headerSub = TextStyle(
    color: Color(0xFF121212),
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    // Figma asks w450; w400 is the closest Flutter weight.
    fontWeight: FontWeight.w400,
  );

  static const TextStyle amountPill = TextStyle(
    color: amountText,
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle termsBase = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    color: Colors.black,
    fontSize: 14,
    height: 1.43,
    // Design asks for w450; Flutter uses 100-step named weights.
    // w500 is the closest stable option.
    fontWeight: FontWeight.w500,
  );

  static const TextStyle termsLink = TextStyle(
    color: termsLinkColor,
    fontSize: 14,
    height: 1.43,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    decorationThickness: 1.2,
  );

  static const TextStyle breakdownRow = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    color: textLight,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.1,
  );

  static const TextStyle breakdownRowEmphasis = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    color: textLight,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static TextStyle receiptLabel() => const TextStyle(
        color: textLight,
        fontSize: 12,
        fontFamily: AppConstants.defaultFontFamily,
        fontWeight: FontWeight.w500,
      );

  static TextStyle receiptValue() => const TextStyle(
        color: textLight,
        fontSize: 12,
        fontFamily: AppConstants.defaultFontFamily,
        fontWeight: FontWeight.w600,
      );

  static const TextStyle bottomAmount = TextStyle(
    color: textDark,
    fontSize: 22,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle bottomCaption = TextStyle(
    color: hint,
    fontSize: 12,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bottomButton = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );
}
