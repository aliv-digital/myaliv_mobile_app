import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

/// Single source of truth for the gift-data flow colors / typography / spacing.
/// Pixel values trace back to the Figma spec screens
/// (Profile_Gift data, Profile_Gift data_Confirmation, Success).
class GiftDataTheme {
  // Palette
  static const Color pageBg = Color(0xFFFFFFFF);
  static const Color appBarBg = Color(0xFF645D9C);
  static const Color primaryPurple = Color(0xFF645D9C);
  static const Color fieldBg = Color(0xFFF2F1F9);
  static const Color chipBg = Color(0xFFF2F1F9);
  static const Color chipSelectedBorder = primaryPurple;
  static const Color chipRadioEmpty = Color(0xFFC9C7D7);
  static const Color bannerBorder = Color(0xFFE4E4EC);
  static const Color sheetBg = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEDEDF3);
  static const Color textPrimary = Color(0xFF121212);
  static const Color textMuted = Color(0xFF7A7A7A);
  static const Color textLightGrey = Color(0xFFF9FAFB);
  static const Color textGreyLabel = Color(0xFF565661);
  static const Color accentOrange = Color(0xFFFA762C);
  static const Color accentGreenData = Color(0xFF2E9E5B);
  static const Color receiptBg = Color(0xFFF1F2FA);
  static const Color receiptIconHalo = Color(0xFFE6F4EC);
  static const Color receiptIconFill = Color(0xFF2E9E5B);

  // Horizontal page gutter.
  static const double pageHGap = 24;
  // Vertical gap after the app bar before the first section.
  static const double topGap = 16;
  // Gap between section groups.
  static const double sectionGap = 20;
  // Gap between a section label and its input.
  static const double labelToInputGap = 8;
  // Standard input / chip height.
  static const double fieldHeight = 48;
  // Phone-input country picker width.
  static const double countryPickerWidth = 60;
  // Standard border radius for inputs / chips.
  static const double fieldRadius = 8;
  // CTA button height.
  static const double ctaHeight = 52;
  // Confirmation sheet corner radius.
  static const double sheetRadius = 22;
  // Receipt ticket corner radius + notch.
  static const double receiptCardRadius = 12;
  static const double receiptNotchRadius = 10;
  // Vertical offset of the ticket notch from the top of the card.
  static const double receiptNotchTopOffset = 184;

  // Section label (14 / w700 / black)
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.43,
  );

  // Available-data chip base copy.
  static const TextStyle availableText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.3,
  );

  // Amount shown orange inside the available-data chip.
  static const TextStyle availableAmount = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: accentOrange,
    height: 1.3,
  );

  // Chip label ("500 mb", "1 gb", "2 gb").
  static const TextStyle chipLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.25,
  );

  static const TextStyle chipLabelSelected = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: primaryPurple,
    height: 1.25,
  );

  // Info banner body copy.
  static const TextStyle bannerText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.5,
  );

  // CTA primary label.
  static const TextStyle ctaLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1,
  );

  // Confirmation sheet row label ("gift amount", "recipient" ...).
  static const TextStyle sheetRowLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textGreyLabel,
    height: 1.43,
  );

  static const TextStyle sheetRowValue = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.43,
  );

  static const TextStyle sheetTitle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.5,
  );
}
