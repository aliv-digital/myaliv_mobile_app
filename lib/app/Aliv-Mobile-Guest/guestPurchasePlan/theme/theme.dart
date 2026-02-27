import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class GuestPurchasePlanTheme {
  // Screen background and app bar
  static final Color screenBackground = HexColor.fromHex('#F1F2FA');
  static final Color appBarColor = HexColor.fromHex('#5D5A8B');

  // Brand + shared colors
  static final Color brandPurple = HexColor.fromHex('#5D5A8B');
  static final Color dividerColor = HexColor.fromHex('#707070');
  static final Color subtitleColor = HexColor.fromHex('#707070');
  static final Color scrollBarBackgroundColor = HexColor.fromHex('#F2F2F7');
  static final Color scrollBarThumbColor = HexColor.fromHex('#645D9C');
  static const Color scrollBarThumbShadowColor = Color(0x19000000);
  static final Color addOnCardBackground = HexColor.fromHex('#F6F6FB');
  // Add-on amount pill background (e.g., "$ 5.00" box) from Figma.
  static final Color addOnPricePillBackground = HexColor.fromHex('#F4F4F6');

  // Add-on card spacing tokens (used in add_on_card.dart).
  // Keep these centralized so card spacing can be updated from theme only.
  static const EdgeInsets addOnCardOuterMargin = EdgeInsets.symmetric(
    horizontal: 15,
    vertical: 10,
  );
  static const double addOnCardBorderRadius = 8;
  static const EdgeInsets addOnCardInnerPadding = EdgeInsets.all(16);
  static const double addOnCardTitleToDetailsGap = 20;
  static const double addOnCardInfoIconSize = 16;
  static const double addOnCardIconToLabelGap = 6;
  static const double addOnCardLabelToValueGap = 6;
  static const double addOnCardValueToPriceGap = 12;

  // Add-on checkbox style (selected state in Figma).
  // Used in: add_on_card.dart -> _CheckBoxSquare
  static const double addOnCheckboxSize = 15;
  static const double addOnCheckboxRadius = 2;
  static const double addOnCheckboxBorderWidth = 1;
  static final Color addOnCheckboxCheckedFillColor = HexColor.fromHex(
    '#5045A7',
  );
  static final Color addOnCheckboxBorderColor = HexColor.fromHex('#645D9C');
  static const double addOnCheckboxCheckIconSize = 12;
  static const Color addOnCheckboxCheckIconColor = Colors.white;

  // Plan-card horizontal scroll indicator style.
  static const double scrollBarThumbWidth = 60;
  static const double scrollBarThumbHeight = 4;
  static const double scrollBarThumbRadius = 50;
  static const double scrollBarShadowBlur = 10;
  static const double scrollBarShadowOffsetX = 1;
  static const double scrollBarShadowOffsetY = 0;
  static const double scrollBarShadowSpread = 0;
  static const double scrollBarRenderBoxHeight = 16;

  // Metric label colors
  static final Color talkMinsColor = HexColor.fromHex('#00B3E3');
  static final Color smsColor = HexColor.fromHex('#5146A8');
  static final Color dataColor = HexColor.fromHex('#FF6C36');
  static final Color bonusDataColor = HexColor.fromHex('#00C4B3');
  static final Color intlTalkTextColor = HexColor.fromHex('#FF6C36');
  static final Color mmsColor = HexColor.fromHex('#00C4B3');

  // Section title above plan list
  static final TextStyle sectionTitle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // Error message in screen
  static final TextStyle errorText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  // Add-on card title
  static final TextStyle addOnTitle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // Add-ons helper copy under the title
  static final TextStyle addOnHelper = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  // Add-on label (e.g., data balance)
  static final TextStyle addOnLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 18,
    // Flutter doesn't support w450 directly; w400 is the nearest available.
    fontWeight: FontWeight.w400,
    color: HexColor.fromHex('#FF6C36'),
  );

  // Add-on value (e.g., 1gb)
  static final TextStyle addOnValue = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: HexColor.fromHex('#222222'),
  );

  // Add-on price pill
  static final TextStyle addOnPrice = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: HexColor.fromHex('#222222'),
  );

  // Plan tabs label
  static final TextStyle tabLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // Plan tabs bar colors
  static final Color tabBarBackground = Colors.white;
  static final Color tabTextInactive = HexColor.fromHex('#8B8B8B');
  static final Color tabDivider = HexColor.fromHex('#E6E6EC');

  // Vertical distance between app bar bottom and the top of tab title text.
  static const double tabTopGapFromAppBar = 10;

  // Selected plan tab label style (e.g., "monthly")
  // Used in: plan_tabs.dart for the currently selected tab text.
  static final TextStyle tabLabelActive = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1,
    color: HexColor.fromHex('#707070'),
  );

  // Plan tab label (inactive)
  static final TextStyle tabLabelInactive = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: tabTextInactive,
  );

  // Unselected tab label bottom gap from the tab bar baseline.
  static const double tabUnselectedLabelBottomGap = 5;

  // Selected tab keeps the same text-to-bar gap, then indicator adds 2px under
  // it, which makes the selected label appear 2px higher than unselected.
  static const double tabSelectedLabelToIndicatorGap = 7;

  // Selected-tab indicator dimensions from Figma.
  static const double tabIndicatorHeight = 2;
  static const double tabIndicatorRadius = 0.4;

  // Plan metric title (e.g., mins/data)
  static final TextStyle metricTitle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: brandPurple,
  );

  // Plan metric value (main number)
  static final TextStyle metricValue = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );

  // Plan metric sub text
  static final TextStyle metricSub = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w400,
    color: HexColor.fromHex('#8B8B8B'),
  );

  // Vertical separator between benefit items inside daily plan card.
  static final Color planBenefitDividerColor = HexColor.fromHex('#707070');
  static const double planBenefitDividerWidth = 1;
  static const double planBenefitDividerHeight = 21;
  static const EdgeInsets planBenefitDividerHorizontalMargin =
      EdgeInsets.symmetric(horizontal: 12);

  // Bottom-sheet shared colors
  static final Color bottomSheetBackground = HexColor.fromHex('#F1F2FA');
  static final Color warningBackground = HexColor.fromHex('#F0DDDD');
  static final Color warningBorder = HexColor.fromHex('#FCA19B');
  static final Color warningText = HexColor.fromHex('#F40F0F');
  static final Color planSummaryBackground = HexColor.fromHex('#FFFFFF');
  static final Color planPriceBorder = HexColor.fromHex('#6258B8');
  static final Color planPriceText = HexColor.fromHex('#6258B8');
  static final Color planPricePillBackground = HexColor.fromHex('#F4F4F6');
  static final Color planPricePillTextColor = HexColor.fromHex('#222222');
  static const EdgeInsets planPricePillPadding =
      EdgeInsets.symmetric(horizontal: 10, vertical: 4);
  static const double planPricePillRadius = 5;
  static final Color activateNowButton = HexColor.fromHex('#645D9C');

  // Bottom-sheet shared text styles
  static final TextStyle bottomSheetWarning = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: warningText,
    height: 1.45,
  );

  static final TextStyle bottomSheetPlanName = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static final TextStyle bottomSheetPlanDuration = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 10,
    // Flutter doesn't support w450 directly; w400 is the nearest available.
    fontWeight: FontWeight.w400,
    color: HexColor.fromHex('#707070'),
  );

  static final TextStyle bottomSheetPrice = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: planPriceText,
    height: 1.0,
  );

  // Plan-card top-right price text (e.g., "$ 8.00").
  static final TextStyle planPricePillTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: planPricePillTextColor,
  );

  static final TextStyle bottomSheetPrimaryAction = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.0,
  );

  static final TextStyle bottomSheetSecondaryAction = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: planPriceBorder,
    height: 1.0,
  );

  // ---------------------------------------------------------------------------
  // Plan Card Tokens (Daily/Weekly/Monthly/Roaming/RoamEasy/Mifi/Liberty Global)
  // Change values in this section to update all plan-card UI consistently.
  // Used in:
  // - daily_plan_card.dart
  // - weekly_plan_card.dart
  // - monthly_plan_card.dart
  // - roaming_plan_card.dart
  // - roameasy_plan_card.dart
  // - mifi_plan_card.dart
  // - liberty_global_plan_card.dart
  // ---------------------------------------------------------------------------

  // Outer card spacing inside the plan list.
  static const EdgeInsets planCardOuterMargin = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );

  // Inner padding of each white plan card.
  static const EdgeInsets planCardInnerPadding = EdgeInsets.fromLTRB(
    12,
    12,
    12,
    12,
  );

  // Base color and shape for the plan card container.
  static const Color planCardBackgroundColor = Colors.white;
  static const double planCardRadius = 8;

  // Soft shadow under each plan card.
  static const Color planCardShadowColor = Color(0x0F000000);
  static const double planCardShadowBlur = 14;
  static const Offset planCardShadowOffset = Offset(0, 8);

  // Header tap target and spacing between major card sections.
  static const double planCardHeaderTapRadius = 10;
  static const double planCardTitleToArrowGap = 10;
  static const double planCardSectionSpacing = 16;
  static const double planCardDescriptionBottomSpacing = 16;

  // Expand/collapse arrow icon size used beside each plan title.
  // Used in all plan card headers when switching between up/down SVGs.
  static const double planCardToggleArrowWidth = 12;
  static const double planCardToggleArrowHeight = 6;

  // Header text styles (title + subtitle).
  static final TextStyle planCardTitleTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static final TextStyle planCardSubtitleTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: subtitleColor,
  );

  // Expanded description text style.
  static final TextStyle planCardDescriptionTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 10,
    height: 1.38,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF2C2C2C),
  );

  // Bottom action row (view details + purchase now) layout.
  static const double planCardActionButtonHeight = 40;
  static const double planCardActionButtonsGap = 12;
  static const double planCardActionButtonRadius = 100;
  static const EdgeInsets planCardActionButtonContentPadding =
      EdgeInsets.fromLTRB(0, 0, 0, 0);
  //EdgeInsets.fromLTRB(24, 16, 24, 16);

  // View details button visuals.
  static final Color planCardViewDetailsBorderColor = HexColor.fromHex(
    '#F2F1F9',
  );
  static final Color planCardViewDetailsBackgroundColor = HexColor.fromHex(
    '#FFFFFF',
  );

  static final Color planCardViewDetailsTextColor = HexColor.fromHex('#645D9C');

  static final TextStyle planCardViewDetailsTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 13,
    // Flutter does not support FontWeight.w450, so w400 is the closest.
    fontWeight: FontWeight.w400,
    color: planCardViewDetailsTextColor,
  );

  // Purchase now button visuals.
  static final Color planCardPurchaseNowBackgroundColor = HexColor.fromHex(
    '#645D9C',
  );
  static const Color planCardPurchaseNowTextColor = Colors.white;
  static final TextStyle planCardPurchaseNowTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: planCardPurchaseNowTextColor,
  );

  // Centralized button labels to keep wording consistent across all plan cards.
  static const String planCardViewDetailsLabel = 'view details';
  static const String planCardHideDetailsLabel = 'hide details';
  static const String planCardPurchaseNowLabel = 'purchase now';

  /// BOTTOM-SHEET STYLES
  // ---------------------------------------------------------------------------
  // Shared container and spacing
  // Used in:
  // - wallet_payment_activate_bottom_sheet.dart
  // - wallet_payment_activate_or_future_bottom_sheet.dart
  // ---------------------------------------------------------------------------
  static const double bottomSheetTopCornerRadius = 24;
  static const EdgeInsets bottomSheetContentPadding = EdgeInsets.fromLTRB(
    16,
    24,
    16,
    24,
  );
  static const double bottomSheetSectionGap = 20;

  // ---------------------------------------------------------------------------
  // Back button in bottom sheet header
  // ---------------------------------------------------------------------------
  static const double bottomSheetBackIconSize = 24;
  static const double bottomSheetBackTapRadius = 12;
  static const Color bottomSheetBackIconColor = Colors.black;

  // ---------------------------------------------------------------------------
  // Warning/alert box
  // ---------------------------------------------------------------------------
  static const EdgeInsets bottomSheetWarningPadding = EdgeInsets.all(10);
  static const double bottomSheetWarningRadius = 4;
  static const double bottomSheetWarningBorderWidth = 1;

  // ---------------------------------------------------------------------------
  // Selected plan summary card (name + duration + price pill)
  // ---------------------------------------------------------------------------
  // Inner padding for the selected-plan summary card in bottom sheets.
  // Figma spacing target: Left 16, Top 20, Right 16, Bottom 20.
  static const EdgeInsets bottomSheetSummaryCardInnerPadding =
      EdgeInsets.fromLTRB(16, 20, 16, 20);
  // Card height aligned with the above LTRB padding.
  // 84 keeps the exact padding while preventing text overflow on device.
  static const double bottomSheetSummaryCardHeight = 84;

  static const double bottomSheetSummaryCardRadius = 12;

  static const double bottomSheetSummaryNameToDurationGap = 0;

  static const double bottomSheetSummaryPricePillHeight = 40;

  static const EdgeInsets bottomSheetSummaryPricePillPadding =
      EdgeInsets.symmetric(horizontal: 16);

  static const double bottomSheetSummaryPricePillRadius = 5;

  static const double bottomSheetSummaryPricePillBorderWidth = 1;

  static final Color bottomSheetSummaryPricePillBackground =
      HexColor.fromHex('#F4F4F6');

  static final TextStyle bottomSheetSummaryPriceTextStyle = TextStyle(
    color: const Color(0xFF222222),
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  // ---------------------------------------------------------------------------
  // Bottom-sheet action buttons
  // ---------------------------------------------------------------------------
  static const double bottomSheetActionButtonHeight = 50;
  static const double bottomSheetActionButtonCornerRadius = 100;
  static const double bottomSheetDualActionButtonsGap = 12;
  static const double bottomSheetSecondaryButtonBorderWidth = 1.5;
  static final Color bottomSheetSecondaryButtonBackgroundColor =
      HexColor.fromHex('#FFFFFF');

  // Activate-only sheet action text style.
  static final TextStyle bottomSheetPrimaryActionSingleStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.0,
  );

  // Activate/Future dual-action sheet text styles (16px from current UI).
  static final TextStyle bottomSheetPrimaryActionDualStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
    height: 1.0,
  );
  static final TextStyle bottomSheetSecondaryActionDualStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: planPriceBorder,
    height: 1.0,
  );

  // Optional centralized labels for consistency.
  static const String bottomSheetActivateNowLabel = 'activate now';
  static const String bottomSheetFuturePlanLabel = 'future plan';

  // ---------------------------------------------------------------------------
  // Roam bottom sheet (when to start?)
  // Used in: roam_bottom_sheet.dart
  // ---------------------------------------------------------------------------
  static const Color roamBottomSheetBackgroundColor = Colors.white;

  static final TextStyle roamBottomSheetTitleTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF222222),
    height: 1.56,
  );

  // "start from" label (roam bottom sheet).
  static const double roamBottomSheetStartFromLabelWidth = 358;
  static final TextStyle roamBottomSheetStartFromLabelTextStyle = TextStyle(
    color: const Color(0xFF1C1C1C),
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1.43,
  );

  static final Color roamBottomSheetDateFieldBackgroundColor =
      HexColor.fromHex('#F2F1F9');
  static const double roamBottomSheetDateFieldHeight = 44;
  static const double roamBottomSheetDateFieldRadius = 8;
  static const EdgeInsets roamBottomSheetDateFieldPadding = EdgeInsets.only(left: 16,right: 8,top: 8,bottom: 8);

  static final TextStyle roamBottomSheetDateFieldTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    // Flutter does not support FontWeight.w450 directly; w400 is the closest.
    fontWeight: FontWeight.w400,
    color: HexColor.fromHex('#707070'),
    height: 1.43,
  );

  static final Color roamBottomSheetDateFieldIconColor = planPriceBorder;
  static const double roamBottomSheetDateFieldIconSize = 18;

  static final Color roamBottomSheetOrDividerColor = HexColor.fromHex('#DCDCEA');
  static final TextStyle roamBottomSheetOrTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: HexColor.fromHex('#707070'),
  );

  static const String roamBottomSheetTitle = 'when to start?';
  static const String roamBottomSheetStartFromLabel = 'start from';
  static const String roamBottomSheetWarningText =
      'your standalone plan can start immediately, or on a date of your choice.';

  // Roam warning box visual style (used only in roam_bottom_sheet.dart).
  static final Color roamBottomSheetWarningBackgroundColor = HexColor.fromHex(
    '#FCE9E1',
  );
  static const double roamBottomSheetWarningTextWidth = 338;
  static final TextStyle roamBottomSheetWarningTextStyle = TextStyle(
    // Flutter does not support FontWeight.w450 directly; w400 is the nearest.
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: HexColor.fromHex('#F30F0F'),
    height: 1.38,
  );

  // Roam bottom-sheet layout spacing (Figma-aligned).
  static const EdgeInsets roamBottomSheetContentPadding = EdgeInsets.fromLTRB(
    16,
    24,
    16,
    24,
  );
  static const double roamBottomSheetBackToTitleGap = 20;
  static const double roamBottomSheetTitleToWarningGap = 20;
  static const double roamBottomSheetWarningToStartFromGap = 20;
  static const double roamBottomSheetStartFromToDateFieldGap = 10;
  static const double roamBottomSheetDateFieldToOrGap = 20;
  static const double roamBottomSheetOrToActivateNowGap = 20;
  static const double roamBottomSheetOrTextHorizontalPadding = 16;

  // Roam bottom-sheet primary action ("activate now") text style.
  static final TextStyle roamBottomSheetActivateNowTextStyle = TextStyle(
    color: const Color(0xFFF1F1F8),
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    // Flutter does not support FontWeight.w450 directly; w400 is the closest.
    fontWeight: FontWeight.w400,
  );

  // Calendar picker bottom sheet styles for roam date selection.
  static final Color roamCalendarSheetBackgroundColor = bottomSheetBackground;
  static final Color roamCalendarSelectedDayBackgroundColor =
      HexColor.fromHex('#645D9C');
  static const Color roamCalendarSelectedDayTextColor = Colors.white;
  static final Color roamCalendarDayTextColor = HexColor.fromHex('#34465D');
  static final TextStyle roamCalendarHeaderTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.33,
    color: HexColor.fromHex('#304054'),
  );
  static final TextStyle roamCalendarWeekdayTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: roamCalendarDayTextColor,
  );
  static final TextStyle roamCalendarDayTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    color: roamCalendarDayTextColor,
  );
  // Calendar sheet outer spacing from container edge (Figma: 24 top/bottom, 16 sides).
  static const EdgeInsets roamCalendarContentPadding = EdgeInsets.fromLTRB(
    16,
    24,
    16,
    24,
  );
  // Visible calendar height to avoid excessive blank area below day grid.
  static const double roamCalendarPickerVisibleHeight = 300;
  static final Color roamCalendarDividerColor = HexColor.fromHex('#DCDCEA');
  static final Color roamCalendarCancelButtonBackgroundColor =
      HexColor.fromHex('#FFFFFF');
  static const double roamCalendarActionButtonsGap = 12;
  static const double roamCalendarActionButtonHeight = 42;
  // Vertical gap between divider and action buttons.
  static const double roamCalendarDividerToActionsGap = 20;

  static final TextStyle roamCalendarCancelTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 13,
    // Flutter does not support FontWeight.w450 directly; w400 is the closest.
    fontWeight: FontWeight.w400,
    color: HexColor.fromHex('#645D9C'),
  );

  static final TextStyle roamCalendarApplyTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: HexColor.fromHex('#F2F1F9'),
  );

  static const String roamCalendarCancelLabel = 'cancel';
  static const String roamCalendarApplyLabel = 'apply';
}
