import 'package:flutter/material.dart';

class HomePlansPaymentMethodTheme {
  HomePlansPaymentMethodTheme._();

  static const String fontFamily = 'CircularPro';

  static const Color bg = Color(0xFFF2F3FA);
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color cardBg = Colors.white;

  static const Color text = Color(0xFF1F1F1F);
  static const Color muted = Color(0xFF7E7E8A);

  static const Color border = Color(0xFFE5E7EB);
  static const Color selectedCardBorder = Color(0xFF8B84C8);
  static const Color selectedIndicatorBorderColor = Color(0xFF7F56D9);
  static const Color selectedIndicatorFillColor = Color(0xFF645D9C);
  static const Color selectedCardBg = Color(0xFFF2F1F9);
  static const Color unselectedIndicatorColor = Color(0xFFE0E0E0);
  static const Color unselectedIndicatorBorderColor = Color(0xFFCACACA);
  static const double selectedIndicatorSize = 16;
  static const double selectedIndicatorCheckSize = 12;

  static const Color plus = Color(0xFF5045A7);
  static const Color payBtnBg = appBarBg;

  static const double appBarHeight = 56;

  // Payment method section spacing (Figma aligned).
  static const EdgeInsets sectionContentPadding = EdgeInsets.fromLTRB(
    16,
    12,
    16,
    12,
  );
  static const double sectionTitleToFirstCardGap = 16;
  static const double firstToSecondCardGap = 8;
  static const double secondToThirdCardGap = 16;
  static const double thirdCardToPayWithCardGap = 16;
  static const double payWithCardToWalletGap = 22;
  static const EdgeInsets payWithCardRowPadding = EdgeInsets.zero;
  static const double payWithCardChevronSize = 16;
  static const double paymentActionIconSize = 20;
  static const double walletChipHorizontalPadding = 8;
  static const double walletChipVerticalPadding = 2;
  static const double walletChipCornerRadius = 100;
  static const Color walletChipBackground = Color(0xFFE6E6E6);

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

  static TextStyle get selectedMethodTitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w700,
    color: Color(0xFF645D9C),
  );

  static TextStyle get methodSubtitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  // Figma uses w450; Flutter closest supported weight is w400.
  static TextStyle get selectedMethodSubtitle => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w400,
    color: Color(0xCC5146A8),
  );

  static TextStyle get addCard => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w400,
    color: Color(0xFF5146A8),
  );

  static TextStyle get walletAmount => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static TextStyle get chargeToAccount => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w700,
    color: Color(0xFF645D9C),
  );

  // Special spacing for "charge to my account" row.
  static const EdgeInsets chargeToAccountTilePadding = EdgeInsets.all(16);
  static const double chargeToAccountIndicatorSize = 16;

  // Regular saved card rows (visa/mastercard) spacing.
  static const EdgeInsets savedCardTilePadding = EdgeInsets.all(22);
  static const double savedCardTextToIndicatorGap = 4;
  static const double savedCardLogoWidth = 46;
  static const double savedCardLogoHeight = 32;

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
