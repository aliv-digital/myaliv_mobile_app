import 'package:flutter/material.dart';

class RevPrepaidTheme {
  RevPrepaidTheme._();

  static const String fontFamily = 'CircularPro';

  // Design colors (match your screenshot)
  static const Color bg = Colors.white;
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color fieldBg = Color(0xFFF3F2FB);
  static const Color hint = Color(0xFF8E8E98);
  static const Color text = Color(0xFF1C1C1C);
  static const Color proceedDisabled = Color(0xFFD6D5E6);

  static const double appBarHeight = 63;
  // Shared height for all form input containers in this screen.
  static const double inputFieldHeight = 48;
  // Shared border radius for all input containers.
  static const double inputFieldRadius = 10;
  // Border width used by the focused-gradient wrapper.
  static const double inputFieldBorderWidth = 1;
  // Keep input border invisible in neutral/unfocused mode.
  static const Color inputFieldBorderColor = Colors.transparent;

  // Main content horizontal gutters.
  static const double contentHorizontalPadding = 24;
  // Gap from app bar bottom to first section label ("service") from Figma.
  static const double contentTopPadding = 17.49;
  // Bottom breathing room after the CTA inside the scroll content.
  static const double contentBottomPadding = 20;

  // Vertical gap between stacked form sections/cards.
  static const double sectionVerticalGap = 16;
  // Gap between a section label and its field/card.
  static const double labelToFieldGap = 8;
  // Space above the bottom "proceed" button.
  static const double proceedButtonTopGap = 30;

  // Shared style for every title shown directly above an input field.
  static TextStyle get fieldTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w700,
    color: text,
  );

  // Backward-compatible alias.
  static TextStyle get label => fieldTitle;

  static TextStyle get input => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w500,
    color: text,
  );

  static TextStyle get hintText => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: hint,
  );

  static TextStyle get value => input;

  static TextStyle get button => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get submit => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.25,
    // Figma requests w450; Flutter closest named weight is w500.
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}
