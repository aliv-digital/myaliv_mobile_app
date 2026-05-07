import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class TopUpConfirmTheme {
  // Screen-level colors.
  static const Color screenBackgroundColor = Color(0xFFF1F2FA);
  static const Color appBarColor = Color(0xFF645D9C);
  static const Color cardBackgroundColor = Color(0xFFFFFFFF);
  static const Color cardShadowColor = Color(0x18000000);

  // Summary card accent colors.
  static const Color boxColor = Color(0xFFF1F2FA);
  static const Color textNumberColor = Color(0xFF121212);
  static const Color summaryDividerColor = Color(0xFFB7B2DA);
  static const Color summaryAmountPillTextColor = Color(0xFF222222);
  static const Color summaryAmountPillBackgroundColor = Color(0xFFF1F2FA);

  // Terms and bottom bar colors.
  static const Color termsTextColor = Colors.black;
  static const Color termsLinkColor = Color(0xFF645D9C);
  static const Color termsCheckboxColor = Color(0xFF5146A8);
  static const Color termsCheckboxUncheckedBackgroundColor = Color(0xFFFFFFFF);
  static const Color termsCheckboxBorderColor = Color(0xFF645D9C);
  static const Color termsCheckboxCheckIconColor = Color(0xFFFFFFFF);
  static const Color payBarBackgroundColor = Color(0xFFFFFFFF);
  static const Color payBarShadowColor = Color(0x22000000);
  static const Color payBarAmountColor = Color(0xFF111111);
  static const Color payBarVatColor = Color(0xFF6D6D6D);
  static const Color payBarButtonColor = Color(0xFF655C9A);

  // Payment breakdown card colors.
  static const Color breakdownBackgroundColor = Color(0xFF645D9C);
  static const Color breakdownTextColor = Color(0xFFFFFFFF);
  static const Color breakdownDashColor = Color(0xB3FFFFFF);

  // Shared page spacing.
  static const double pageHorizontalPadding = 29;
  static const double summaryTopPadding = 31;
  static const double termsTopPadding = 17;
  static const double termsBottomPadding = 17;
  static const double bottomScrollSpacing = 16;
  static const EdgeInsets summaryWrapperPadding = EdgeInsets.only(
    left: pageHorizontalPadding,
    right: pageHorizontalPadding,
    top: summaryTopPadding,
  );
  static const EdgeInsets termsWrapperPadding = EdgeInsets.only(
    left: pageHorizontalPadding,
    right: pageHorizontalPadding,
    top: termsTopPadding,
    bottom: termsBottomPadding,
  );

  // Summary card geometry.
  static const double summaryCardMinHeight = 120;
  static const double summaryCardRadius = 8;
  static const double summaryCardShadowBlur = 12;
  static const double summaryCardShadowOffsetY = 6;
  static const double summaryHorizontalInset = 16;
  static const double summaryTopSectionVerticalPadding = 14;
  static const double summaryBottomSectionVerticalPadding = 24;
  static const double summaryTitleToPhoneGap = 2;
  static const double summaryDividerHeight = 1;
  static const double summaryAmountPillRadius = 5;
  static const double summaryAmountPillHorizontalPadding = 10;
  static const double summaryAmountPillVerticalPadding = 4;

  // Terms text layout.
  static const double termsTopInset = 0;
  static const double termsCheckboxSize = 15;
  static const double termsCheckboxRadius = 2;
  static const double termsCheckboxToTextGap = 10;
  static const double termsCheckboxTopOffset = 5;
  static const double termsCheckboxBorderWidth = 1;
  static const double termsCheckboxIconSize = 11;
  static const String termsLeadText = 'By checking this box, I agree to the ';
  static const String termsLinkText = 'Terms & Conditions.';

  // Breakdown card layout and shape.
  static const EdgeInsets breakdownWrapperPadding =
      EdgeInsets.symmetric(horizontal: pageHorizontalPadding);
  static const EdgeInsets breakdownCardPadding =
      EdgeInsets.fromLTRB(16, 20, 16, 20);
  // Top-left and top-right corner radius of the breakdown card.
  static const double breakdownCardRadius = 20;
  static const double breakdownScallopRadius = 10;
  static const int breakdownScallopCount = 12;
  static const double breakdownScallopGap = 4;
  static const double breakdownScallopDepth = 6;
  // Use a flatter vertical oval instead of a perfect circle for each scallop.
  static const double breakdownScallopOvalHeightFactor = 0.72;
  // Keep left/right ends flat while scallops stay in the middle (Figma-like).
  static const double breakdownScallopSideInset = 10;
  static const double breakdownElevation = 10;
  static const double breakdownRowGap = 14;
  static const double breakdownGapBeforeDivider = 16;
  static const double breakdownGapAfterDivider = 16;
  static const double breakdownBottomInnerGap = 20;
  static const double breakdownDashHeight = 1;
  static const double breakdownDashWidth = 6;
  static const double breakdownDashGap = 5;
  static const double legacyScallopRadius = 8;
  static const double legacyScallopCornerRadius = 12;

  // Bottom pay bar layout.
  static const double payBarHeight = 75;
  static const double payBarElevation = 10;
  static const EdgeInsets payBarPadding = EdgeInsets.fromLTRB(24, 16, 24, 16);
  static const double payBarAmountToVatGap = 2;
  static const double payBarSectionGap = 16;
  static const double payBarButtonHeight = 44;
  static const double payBarButtonWidth = 180;
  static const double payBarButtonRadius = 22;
  static const double payBarLoadingSize = 22;
  static const double payBarLoadingStroke = 2.4;
  static const double payBarDisabledOpacity = 0.7;
  static const String payNowLabel = 'pay now';
  static const String vatInclusiveLabel = 'vat inclusive';
  static const String vatExclusiveLabel = 'vat exclusive';

  // Generic amount-pill token set.
  static const Color amountPillBackgroundColor = Color(0xFFFFFFFF);
  static const double amountPillRadius = 14;
  static const double amountPillBorderWidth = 2;
  static const double amountPillHorizontalPadding = 12;
  static const double amountPillVerticalPadding = 6;

  // Optional custom card token set.
  static const EdgeInsets customCardMargin =
      EdgeInsets.symmetric(vertical: 10, horizontal: 20);
  static const double customCardRadius = 12;
  static const double customCardElevation = 4;
  static const EdgeInsets customCardPadding = EdgeInsets.all(16);
  static const double customCardGap = 8;
  static const Color customCardDividerColor = Colors.grey;
  static const Color customCardAmountBackground = Colors.blueAccent;
  static const double customCardAmountRadius = 8;
  static const double customCardAmountHorizontalPadding = 16;
  static const double customCardAmountVerticalPadding = 8;

  // Summary card title (top section).
  static final TextStyle summaryTitle = TextStyle(
    fontSize: 18,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1.05,
    color: Colors.black,
  );

  // Summary card phone number.
  static final TextStyle summaryPhone = TextStyle(
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: textNumberColor,
  );

  // Summary card action label (bottom left).
  static final TextStyle summaryAction = TextStyle(
    fontSize: 18,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // Summary card amount pill text.
  static final TextStyle summaryAmountPill = TextStyle(
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: summaryAmountPillTextColor,
  );

  // Amount pill text (generic).
  static final TextStyle amountPillText = TextStyle(
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  // Payment breakdown row text (label/value).
  static final TextStyle breakdownText = TextStyle(
    fontSize: 15,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    height: 1.1,
    color: breakdownTextColor,
  );

  // Emphasized text style for important breakdown rows.
  static final TextStyle breakdownEmphasizedText = breakdownText.copyWith(
    fontWeight: FontWeight.w800,
  );

  // Terms leading sentence style.
  static final TextStyle termsLead = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    height: 1.43,
    // Flutter has no exact w450; w400 is the closest available weight.
    fontWeight: FontWeight.w400,
    color: termsTextColor,
  );

  // Terms link text.
  static final TextStyle termsLink = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1.43,
    color: termsLinkColor,
    decoration: TextDecoration.underline,
    decorationColor: Color(0xFF645D9C),
  );

  // Bottom pay bar amount text.
  static final TextStyle payBarAmount = TextStyle(
    fontSize: 22,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: payBarAmountColor,
    height: 1.0,
  );

  // Bottom pay bar currency symbol style.
  static final TextStyle payBarCurrency = payBarAmount.copyWith(
    fontWeight: FontWeight.w400,
  );

  // Bottom pay bar VAT label.
  static final TextStyle payBarVat = TextStyle(
    fontSize: 12,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: payBarVatColor,
    height: 1.0,
  );

  // Bottom pay bar button text.
  static final TextStyle payBarButton = TextStyle(
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // SnackBar text.
  static final TextStyle snackBarText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
  );

  // Custom card title text.
  static final TextStyle customCardTitle = TextStyle(
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Custom card phone text.
  static final TextStyle customCardPhone = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  // Custom card label text.
  static final TextStyle customCardLabel = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  // Custom card amount text.
  static final TextStyle customCardAmount = TextStyle(
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
