import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class GuestPurchasePlanTheme {
  // Screen background and app bar
  static final Color screenBackground = HexColor.fromHex('#F6F6F8');
  static final Color appBarColor = HexColor.fromHex('#5D5A8B');

  // Brand + shared colors
  static final Color brandPurple = HexColor.fromHex('#5D5A8B');
  static final Color dividerColor = HexColor.fromHex('#707070');
  static final Color subtitleColor = HexColor.fromHex('#707070');
  static final Color scrollBarBackgroundColor = HexColor.fromHex('#F2F2F7');
  static final Color scrollBarThumbColor = HexColor.fromHex('#645D9C');
  static const Color scrollBarThumbShadowColor = Color(0x19000000);
  static final Color addOnCardBackground = HexColor.fromHex('#F6F6FB');

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
    color: Colors.black.withValues(alpha: 0.75),
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
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );

  // Add-ons helper copy under the title
  static final TextStyle addOnHelper = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  // Add-on label (e.g., data balance)
  static final TextStyle addOnLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: HexColor.fromHex('#FF6C36'),
  );

  // Add-on value (e.g., 1gb)
  static final TextStyle addOnValue = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // Add-on price pill
  static final TextStyle addOnPrice = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: brandPurple,
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

  // Plan tab label (active)
  static final TextStyle tabLabelActive = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: brandPurple,
  );

  // Plan tab label (inactive)
  static final TextStyle tabLabelInactive = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: tabTextInactive,
  );

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

  // Bottom-sheet shared colors
  static final Color bottomSheetBackground = HexColor.fromHex('#F1F2FA');
  static final Color warningBackground = HexColor.fromHex('#FFE8E8');
  static final Color warningBorder = HexColor.fromHex('#FF8F8F');
  static final Color warningText = HexColor.fromHex('#FF0000');
  static final Color planSummaryBackground = HexColor.fromHex('#FFFFFF');
  static final Color planPriceBorder = HexColor.fromHex('#6258B8');
  static final Color planPriceText = HexColor.fromHex('#6258B8');
  static final Color planPricePillBackground = HexColor.fromHex('#F4F4F6');
  static final Color planPricePillTextColor = HexColor.fromHex('#222222');
  static const EdgeInsets planPricePillPadding =
      EdgeInsets.symmetric(horizontal: 10, vertical: 4);
  static const double planPricePillRadius = 5;
  static final Color activateNowButton = HexColor.fromHex('#655D9C');

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
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.black,
    height: 1.0,
  );

  static final TextStyle bottomSheetPlanDuration = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: subtitleColor,
    height: 1.0,
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
  static const double planCardSectionSpacing = 16;
  static const double planCardDescriptionBottomSpacing = 16;

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
  static const double planCardActionButtonRadius = 22;
  static const EdgeInsets planCardActionButtonContentPadding =EdgeInsets.fromLTRB(0, 0, 0, 0);
      //EdgeInsets.fromLTRB(24, 16, 24, 16);

  // View details button visuals.
  static final Color planCardViewDetailsBorderColor = HexColor.fromHex(
    '#E0E0E0',
  );
  static final Color planCardViewDetailsBackgroundColor = HexColor.fromHex(
    '#F2F1F9',
  );
  static final TextStyle planCardViewDetailsTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: brandPurple,
  );

  // Purchase now button visuals.
  static final Color planCardPurchaseNowBackgroundColor = brandPurple;
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
}
