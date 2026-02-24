import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class HomeRoamingConfirmationTheme {
  static const bg = Color(0xFFF1F2FA);

  static const purple = Color(0xFF655C9A);
  static const purpleDark = Color(0xFF5B548E);
  static const outlinePurple = Color(0xFF655C9A);

  static const cardWhite = Color(0xFFFFFFFF);
  static const textBlack = Color(0xFF121212);
  static const textGrey = Color(0xFF707070);

  static const shadow = Color(0x14000000);

  // ---------------- Screen Layout ----------------
  // Shared horizontal page padding used by summary, begins-on, and payment cards.
  static const double contentHorizontalPadding = 29;

  // Top spacing from app-bar bottom to the summary card.
  static const double purchaseSummaryCardTopSpacing = 24;

  // ---------------- Purchase Summary Card Spacing ----------------
  // Main card visual shape.
  static const double purchaseSummaryCardRadius = 10;

  // Header section (title + phone) padding:
  // Figma: left/right 16, top/bottom 14.
  static const EdgeInsets purchaseSummaryHeaderPadding = EdgeInsets.fromLTRB(
    16,
    14,
    16,
    14,
  );

  // Each item row section padding:
  // Figma: left/right 16, top/bottom 20.
  static const EdgeInsets purchaseSummaryItemSectionPadding =
      EdgeInsets.fromLTRB(
    16,
    20,
    16,
    20,
  );

  // Vertical text spacing inside header.
  static const double purchaseSummaryHeaderTitleToPhoneGap = 0;

  // Divider between sections (header/items/items).
  static const double purchaseSummaryDividerThickness = 1;
  static const double purchaseSummaryDividerHeight = 1;
  static const Color purchaseSummaryDividerColor = Color(0xFFE6E8F2);

  // Spacing inside each purchase row.
  static const double purchaseItemLabelToTitleGap = 2;
  static const double purchaseItemTitleToSubtitleGap = 2;
  static const double purchaseItemPriceToDeleteGap = 20;
  static const double purchaseItemDeleteTapPadding = 6;
  static const double purchaseItemDeleteIconSize = 16;

  // ---------------- Purchase Item Amount Chip ----------------
  // Amount chip container style (e.g. "$ 15.00")
  static const Color purchaseItemAmountChipColor = Color(0xFFF4F4F6);
  static const double purchaseItemAmountChipRadius = 5;
  static const EdgeInsets purchaseItemAmountChipPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );

  // Amount chip text style.
  static const TextStyle purchaseItemAmountChipTextStyle = TextStyle(
    color: Color(0xFF222222),
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  // ---------------- Purchase Summary Header Text Styles ----------------
  // Header title style: "purchase a plan"
  static const TextStyle purchaseSummaryHeaderTitleTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  // Header phone number style: "242-801-1616"
  // Figma uses w450; Flutter closest supported weight is w400.
  static const TextStyle purchaseSummaryHeaderPhoneTextStyle = TextStyle(
    color: Color(0xFF121212),
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  // ---------------- Purchase Item Row Text Styles ----------------
  // Row top label style: "primary plan", "add-on"
  static const TextStyle purchaseItemLabelTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 10,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  // Row main title style: "liberty70", "liberty data 1"
  static const TextStyle purchaseItemTitleTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  // Row subtitle style: "begins immediately"
  // Figma uses w450; Flutter closest supported weight is w400.
  static const TextStyle purchaseItemSubtitleTextStyle = TextStyle(
    color: Color(0xFF707070),
    fontSize: 10,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    height: 1,
  );

  // ---------------- Terms Row ----------------
  // Section spacing around the terms row (per Figma: 17 top, 17 bottom).
  static const double termsNoticeTopSpacing = 17;
  static const double termsNoticeBottomSpacing = 17;

  // Horizontal page padding used by the terms row section.
  static const double termsNoticeHorizontalPadding = 29;

  // Width of the terms sentence block in the confirmation screen.
  static const double termsNoticeTextWidth = 307;

  // Checkbox size and spacing to the terms sentence.
  static const double termsNoticeCheckboxSize = 15;
  static const double termsNoticeCheckboxRadius = 2;
  static const double termsNoticeCheckboxToTextGap = 10;
  static const double termsNoticeCheckboxIconSize = 12;

  // Fine alignment so checkbox lines up with first text line visually.
  // Figma alignment: checkbox starts slightly lower than the first text line.
  static const double termsNoticeCheckboxTopOffset = 5;

  // Checkbox visual colors.
  static const Color termsNoticeCheckboxBorderColor = Color(0xFF645D9C);
  static const Color termsNoticeCheckboxCheckedFillColor = Color(0xFF5146A8);

  // ---------------- Begins On Card ----------------
  // Spacing between purchase summary card and begins-on card.
  static const double beginsOnCardTopSpacing = 17;

  // Card container style.
  static const Color beginsOnCardBackgroundColor = Color(0xFFFFFFFF);
  static const double beginsOnCardRadius = 10;
  static const EdgeInsets beginsOnCardPadding = EdgeInsets.fromLTRB(
    16,
    14,
    16,
    14,
  );

  // Internal spacing and icon sizing.
  static const double beginsOnCardTextToIconGap = 12;
  static const double beginsOnCardCalendarIconSize = 20;

  // Text styles: "begins on | Aug 6th, 2025"
  static const TextStyle beginsOnLabelTextStyle = TextStyle(
    color: Color(0xFF707070),
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle beginsOnDateTextStyle = TextStyle(
    color: Color(0xFF9D9D9D),
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  // Figma uses w450 which is not available in Flutter.
  // Using w400 as the closest supported weight.
  static const TextStyle termsNoticeBodyTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  static const TextStyle termsNoticeLinkTextStyle = TextStyle(
    color: Color(0xFF645D9C),
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    height: 1.43,
  );

  /// Common text style helper (CircularPro everywhere)
  static TextStyle t(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = textBlack,
    double height = 1.2,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: AppConstants.defaultFontFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      decoration: decoration,
    );
  }
}
