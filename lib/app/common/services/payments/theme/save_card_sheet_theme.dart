import 'package:flutter/material.dart';

class SaveCardSheetTheme {
  SaveCardSheetTheme._();

  static const primary = Color(0xFF645D9C);
  static const fieldBackground = Color(0xFFF2F1F9);
  static const textPrimary = Color(0xFF222222);
  static const textMuted = Color(0xFF707070);

  static const horizontalPadding = 16.0;
  static const topPadding = 24.0;
  static const bottomPadding = 24.0;
  static const radius = 24.0;
  static const headerSize = 48.0;
  static const featuredIconSize = 56.0;
  static const closeIconSize = 26.0;
  static const headerToTitleGap = 24.0;
  static const titleToDescriptionGap = 8.0;
  static const descriptionToFieldsGap = 18.0;
  static const fieldsGap = 16.0;
  static const fieldHeight = 48.0;
  static const fieldRadius = 8.0;
  static const fieldHorizontalPadding = 16.0;
  static const fieldsToButtonGap = 20.0;
  static const buttonHeight = 50.0;

  static const title = TextStyle(
    fontFamily: 'CircularProBold',
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static const fieldText = TextStyle(
    fontFamily: 'CircularProBook',
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );

  static const buttonText = TextStyle(
    fontFamily: 'CircularProBold',
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
