import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class TopUpConfirmTheme{
  static Color boxColor = HexColor.fromHex('#EDEBF7');
  static Color textNumberColor = HexColor.fromHex('#FF121212');

  // Summary card title (top section)
  static final TextStyle summaryTitle = TextStyle(
    fontSize: 18,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1.05,
    color: Colors.black,
  );

  // Summary card phone number
  static final TextStyle summaryPhone = TextStyle(
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: textNumberColor,
  );

  // Summary card action label (bottom left)
  static final TextStyle summaryAction = TextStyle(
    fontSize: 18,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // Summary card amount pill text
  static final TextStyle summaryAmountPill = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w800,
    color: const Color(0xFF6B63A7),
  );

  // Amount pill text (generic)
  static final TextStyle amountPillText = TextStyle(
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
  );

  // Payment breakdown row text (label/value)
  static final TextStyle breakdownText = TextStyle(
    fontSize: 15,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    height: 1.1,
    color: Colors.white,
  );

  // Terms base text
  static final TextStyle termsBase = TextStyle(
    fontSize: 12.5,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    height: 1.25,
    color: const Color(0xFF111111),
  );

  // Terms link text
  static final TextStyle termsLink = TextStyle(
    fontSize: 12.5,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w800,
    height: 1.25,
    color: const Color(0xFF111111),
    decoration: TextDecoration.underline,
    decorationThickness: 1.5,
  );

  // Bottom pay bar amount text
  static final TextStyle payBarAmount = TextStyle(
    fontSize: 22,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF111111),
    height: 1.0,
  );

  // Bottom pay bar VAT label
  static final TextStyle payBarVat = TextStyle(
    fontSize: 12,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w200,
    color: const Color(0xFF6D6D6D),
    height: 1.0,
  );

  // Bottom pay bar button text
  static final TextStyle payBarButton = TextStyle(
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // SnackBar text
  static final TextStyle snackBarText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
  );

  // Custom card title text
  static final TextStyle customCardTitle = TextStyle(
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Custom card phone text
  static final TextStyle customCardPhone = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  // Custom card label text
  static final TextStyle customCardLabel = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  // Custom card amount text
  static final TextStyle customCardAmount = TextStyle(
    fontSize: 16,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

}
