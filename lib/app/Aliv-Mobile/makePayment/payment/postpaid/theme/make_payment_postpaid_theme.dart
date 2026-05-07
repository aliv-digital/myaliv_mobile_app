import 'package:flutter/material.dart';

class MakePaymentPostPaidTheme {
  MakePaymentPostPaidTheme._();

  static const String fontFamily = 'CircularPro';

  static const Color bg = Color(0xFFF2F3FA);
  static const Color appBarBg = Color(0xFF655C9A);
  static const Color cardBg = Colors.white;

  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textMuted = Color(0xFF7E7E8A);

  static const Color border = Color(0xFFE6E6F2);
  static const Color primary = appBarBg;
  static const Color radioBorder = Color(0xFFCACACA);
  static const Color radioFill = Color(0xFFE0E0E0);
  static const Color radioSelectedBorder = Color(0xFF7F56D9);
  static const Color radioSelectedFill = Color(0xFF645D9C);
  static const double amountOptionIndicatorSize = 16;
  static const double amountOptionIndicatorBorderWidth = 1;

  static const Color optionSelectedBg = Color(0xFFF2F0FA);
  static const Color optionSelectedBorder = Color(0xFF8B84C8);

  static const Color amountFieldBg = Color(0xFFF1F1F1);
  static const Color customAmountBg = Color(0xFFF1F1F5);
  static const double customAmountBorderRadius = 8;
  static const double customAmountBorderWidth = 1;

  // Focused input border gradient (copied from login input focus style).
  static const Color focusedInputBorderYellow = Color(0xFFFFC627);
  static const Color focusedInputBorderBlue = Color(0xFF00B3E3);
  static const Color focusedInputBorderPurple = Color(0xFF4B298C);
  static const Color focusedInputBorderPink = Color(0xFFFF9BB1);
  static const Color focusedInputBorderOrange = Color(0xFFFF6C36);
  static const LinearGradient focusedInputBorderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      focusedInputBorderYellow,
      focusedInputBorderBlue,
      focusedInputBorderPurple,
      focusedInputBorderPink,
      focusedInputBorderOrange,
    ],
  );

  static const Color bottomBarBg = Colors.white;
  static const Color payButtonDisabled = Color(0xFFD3D1E8);

  // Payment method section (mirrors rev payment method design).
  static const Color paymentMethodBorder = Color(0xFFE5E7EB);
  static const Color paymentMethodSelectedBorder = Color(0xFF8B84C8);
  static const Color paymentMethodSelectedCardBg = Color(0xFFF2F1F9);
  static const Color paymentMethodSelectedIndicatorBorderColor =
      Color(0xFF7F56D9);
  static const Color paymentMethodSelectedIndicatorFillColor =
      Color(0xFF645D9C);
  static const Color paymentMethodUnselectedIndicatorColor = Color(0xFFE0E0E0);
  static const Color paymentMethodUnselectedIndicatorBorderColor =
      Color(0xFFCACACA);
  static const Color paymentMethodAccent = Color(0xFF645D9C);

  static const double appBarHeight = 56;

  // Payment due card spacing (Figma-aligned).
  static const EdgeInsets paymentDueCardPadding =
      EdgeInsets.fromLTRB(16, 20, 16, 20);
  static const double paymentDueTitleToAmountGap = 16;
  static const double paymentDueAmountToOptionsGap = 16;
  static const double paymentDueOptionsBetweenGap = 8;
  static const EdgeInsets paymentDueAmountFieldPadding =
      EdgeInsets.symmetric(horizontal: 16);
  static const double paymentDueAmountValueHorizontalPadding = 8;
  static const double paymentDueCurrencyToValueGap = 8;
  static const EdgeInsets paymentDueOptionTilePadding = EdgeInsets.all(16);
  static const double paymentDueOptionTextToIndicatorGap = 12;

  static const EdgeInsets paymentMethodSectionPadding =
      EdgeInsets.fromLTRB(12, 12, 12, 12);
  static const double paymentMethodSectionTitleToFirstCardGap = 16;
  static const double paymentMethodBetweenCardsGap = 8;
  static const double paymentMethodLastCardToPayWithCardGap = 16;
  static const EdgeInsets paymentMethodPayWithCardRowPadding = EdgeInsets.zero;
  static const double paymentMethodPayWithCardChevronSize = 16;

  static const EdgeInsets paymentMethodTilePadding = EdgeInsets.all(16);
  static const double paymentMethodLogoWidth = 46;
  static const double paymentMethodLogoHeight = 32;
  static const double paymentMethodLogoToTextGap = 16;
  static const double paymentMethodTextToIndicatorGap = 4;
  static const double paymentMethodIndicatorSize = 16;
  static const double paymentMethodIndicatorCheckSize = 12;

  static TextStyle get title => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get sectionLabel => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1C1C1C),
      );

  static TextStyle get amountText => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w400, // Closest supported weight to Figma w450.
        color: Color(0xFF101828),
      );

  static TextStyle get optionText => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w700,
        color: Color(0xFF222222),
      );

  static TextStyle get optionTextSelected => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w700,
        color: Color(0xFF645D9C),
      );

  static TextStyle get helperLabel => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get customAmountText => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get customAmountHint => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle get termsText => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w400, // Closest supported weight to Figma w450.
        color: Colors.black,
      );

  static TextStyle get termsLink => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w700,
        color: Color(0xFF645D9C),
        decoration: TextDecoration.underline,
        decorationColor: Color(0xFF645D9C),
      );

  static TextStyle get paymentMethodSectionTitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400, // Closest supported weight to Figma w450.
        color: Colors.black,
      );

  static TextStyle get paymentMethodName => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      );

  static TextStyle get paymentMethodSelectedName => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w700,
        color: paymentMethodAccent,
      );

  static TextStyle get paymentMethodExpiry => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle get paymentMethodSelectedExpiry => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w400, // Closest supported weight to Figma w450.
        color: Color(0xCC5146A8),
      );

  static TextStyle get addCard => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: paymentMethodAccent,
      );

  static TextStyle get bottomAmount => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      );

  static TextStyle get bottomSubtitle => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle get payNow => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );
}
