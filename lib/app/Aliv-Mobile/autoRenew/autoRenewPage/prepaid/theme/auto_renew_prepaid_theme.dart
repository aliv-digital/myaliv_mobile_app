import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class AutoRenewPrepaidTheme {
  // Typography
  static const String fontFamily = AppConstants.defaultFontFamily;

  // Color tokens
  static const Color primary = Color(0xFF645D9C);
  static const Color pageBg = Color(0xFFF3F4F8);
  static const Color cardBg = Colors.white;
  static const Color cardBgSelected = Color(0xFFF1F1F8);
  static const Color sheetBg = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF222222);
  static const Color textOnPrimary = Color(0xFFF1F1F8);
  static const Color dashedBorder = Color(0xFF8E8CC9);
  static const Color dragHandle = Color(0xFFE5E7EB);
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Layout and sizing
  static const double appBarHeight = 56.0;
  static const double primaryButtonHeight = 50.0;
  static const double bottomSheetActionHeight = 52.0;
  static const double loaderSize = 22.0;
  static const double loaderStrokeWidth = 2.0;
  static const double selectionIndicatorSize = 20.0;
  static const double selectionIndicatorBorderWidth = 2.0;
  static const double selectionCheckIconSize = 14.0;
  static const double addCardIconSize = 20.0;
  static const double tileBorderWidth = 1.0;
  static const double cardLogoWidth = 52.0;
  static const double cardLogoHeight = 38.0;
  static const double cardTileRadius = 8.0;
  static const double cardTileTapRadius = 12.0;
  static const double sectionRadius = 8.0;
  static const double sheetTopRadius = 18.0;
  static const double pillRadius = 100.0;
  static const double dragHandleRadius = 999.0;
  static const double dragHandleWidth = 42.0;
  static const double dragHandleHeight = 5.0;
  static const double dashedStrokeWidth = 1.2;
  static const double dashedDashLength = 6.0;
  static const double dashedGapLength = 5.0;
  static const double buttonElevation = 0.0;

  // Spacing
  static const EdgeInsets bodyPadding = EdgeInsets.fromLTRB(24, 32, 24, 18);
  static const EdgeInsets sectionPadding = EdgeInsets.all(14);
  static const EdgeInsets cardTilePadding = EdgeInsets.all(16);
  static const EdgeInsets addCardButtonPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets addCardBottomSheetPadding = EdgeInsets.fromLTRB(18, 14, 18, 18);
  static const double addCardBottomSheetBottomBase = 18.0;
  static const EdgeInsets addCardInputPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);

  static const double sectionItemGap = 10.0;
  static const double sectionTitleGap = 16.0;
  static const double sectionToDashedGap = 24.0;
  static const double dashedToActionGap = 24.0;
  static const double tileLogoGap = 12.0;
  static const double tileSelectionGap = 10.0;
  static const double tileTitleSubtitleGap = 4.0;
  static const double addCardIconTextGap = 8.0;
  static const double bottomSheetTitleGap = 14.0;
  static const double bottomSheetFieldsGap = 12.0;
  static const double bottomSheetButtonTopGap = 16.0;

  // Text styles
  static const TextStyle sectionTitleStyle = TextStyle(
    color: black,
    fontSize: 13,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
  );

  static TextStyle tileTitle({required bool selected}) => TextStyle(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
        color: selected ? primary : textSecondary,
        fontSize: 14,
        fontFamily: fontFamily,
        height: 1.43,
      );

  static TextStyle tileSubtitle({required bool selected}) => TextStyle(
        color: selected ? primary : textSecondary,
        fontSize: 14,
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        height: 1.43,
      );

  static const TextStyle addCardButtonTextStyle = TextStyle(
    color: primary,
    fontSize: 13,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
    height: 1.54,
  );

  static const TextStyle primaryButtonTextStyle = TextStyle(
    color: textOnPrimary,
    fontSize: 13,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle addCardSheetTitleStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const TextStyle addCardSheetSaveStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: white,
  );

  static const TextStyle dropdownItemStyle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  // Reusable helpers
  static Color primaryActionColor({required bool enabled}) {
    return primary.withValues(alpha: enabled ? 1 : 0.45);
  }

  static Color selectedTileBorderColor() {
    return primary.withValues(alpha: 0.55);
  }

  static RoundedRectangleBorder pillShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(pillRadius),
    );
  }

  static RoundedRectangleBorder sheetShape() {
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(sheetTopRadius)),
    );
  }

  static InputDecoration dropdownInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardTileTapRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardTileTapRadius),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardTileTapRadius),
        borderSide: const BorderSide(color: primary),
      ),
      contentPadding: addCardInputPadding,
    );
  }

  static ButtonStyle primaryPillButtonStyle({required Color backgroundColor}) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      shape: pillShape(),
      elevation: buttonElevation,
    );
  }
}
