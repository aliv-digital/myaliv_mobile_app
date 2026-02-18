import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class RevPaymentMethodPrepaidTheme {
  RevPaymentMethodPrepaidTheme._();

  static const String fontFamily = 'CircularPro';

  static const Color bg = Color(0xFFF2F3FA);
  static  Color appBarBg = HexColor.fromHex('#645D9C');
  static const Color cardBg = Colors.white;

  static const Color text = Color(0xFF1F1F1F);
  static const Color muted = Color(0xFF7E7E8A);

  static const Color border = Color(0xFFE5E7EB);
  static const Color selectedBorder = Color(0xFF8B84C8);
  static const Color selectedCardBg = Color(0xFFF2F1F9);
  static const Color selectedIndicatorBorderColor = Color(0xFF7F56D9);
  static const Color selectedIndicatorFillColor = Color(0xFF645D9C);
  static const Color unselectedIndicatorColor = Color(0xFFE0E0E0);
  static const Color unselectedIndicatorBorderColor = Color(0xFFCACACA);
  static const double selectedIndicatorSize = 16;
  static const double selectedIndicatorCheckSize = 12;

  static  Color plus = appBarBg;
  static  Color payBtnBg = appBarBg;

  static const double appBarHeight = 56;

  // Screen content spacing.
  static const double screenHorizontalPadding = 29;
  static const double screenTopPadding = 24;
  static const double screenBottomPadding = 20;

  // Payment method container spacing.
  static const EdgeInsets sectionContentPadding =
      EdgeInsets.fromLTRB(12, 12, 12, 12);
  static const double sectionTitleToFirstCardGap = 16;
  static const double betweenMethodCardsGap = 8;
  static const double lastCardToPayWithCardGap = 16;
  static const EdgeInsets payWithCardRowPadding = EdgeInsets.zero;
  static const double payWithCardChevronSize = 16;

  // Saved card tile spacing.
  static const EdgeInsets paymentTilePadding = EdgeInsets.all(16);
  static const double paymentTileLogoWidth = 46;
  static const double paymentTileLogoHeight = 32;
  static const double paymentTileLogoToTextGap = 16;
  static const double paymentTileTextToIndicatorGap = 4;

  static TextStyle get sectionTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400, // Closest supported weight to Figma w450.
    color: Colors.black,
  );

  static TextStyle get methodTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: text,
  );

  static TextStyle get methodSubtitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  static TextStyle get selectedMethodTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w700,
    color: Color(0xFF645D9C),
  );

  // Figma uses w450; Flutter closest supported weight is w400.
  static TextStyle get selectedMethodSubtitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w400,
    color: Color(0xCC5146A8),
  );

  static TextStyle get addCard =>  TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: plus,
  );

  static TextStyle get bottomAmount => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: text,
  );

  static TextStyle get bottomVat => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  static TextStyle get payNow => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
