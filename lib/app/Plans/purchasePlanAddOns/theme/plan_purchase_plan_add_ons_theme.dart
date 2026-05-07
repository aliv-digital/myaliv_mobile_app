import 'package:flutter/material.dart';

class PlanPurchasePlanAddOnsTheme {
  // Keep colors centralized so later UI changes are easy.
  static const Color bg = Color(0xFFF1F2FA);
  static const Color appBarPurple = Color(0xFF655C9A);

  static const Color cardWhite = Colors.white;

  // Red plan header card
  static const Color planRed = Color(0xFFE62B2F);
  static const Color planRedDark = Color(0xFFD81E23);

  // Borders
  static const Color outlinePurple = Color(0xFF655C9A);
  static const Color shadow = Color(0x14000000);

  // Text
  static const Color textBlack = Color(0xFF121212);
  static const Color textGrey = Color(0xFF707070);
  static const Color textMuted = Color(0xFF8D8D8D);
  static const Color white = Colors.white;
  static const Color addOnHelperColor = Color(0xFF222222);
  static const Color addOnLabelColor = Color(0xFFFF6C36);

  // Controls
  static const Color checkboxBorder = Color(0xFFB6B2D6);
  static const Color checkboxFill = Color(0xFF655C9A);

  static const Color proceedButton = Color(0xFF655C9A);
  static const Color proceedText = Colors.white;

  // Bottom checkout bar
  static const Color bottomBarShadow = Color(0x22000000);
  static const Color bottomBarAmount = Color(0xFF111111);
  static const Color bottomBarVat = Color(0xFF6D6D6D);
  static const Color bottomBarButton = Color(0xFF6B63A7);

  // Auto-renew toggle
  static const Color toggleOffCircle = Color(0xFFEDECF6);

  static const String font = 'CircularPro';

  static TextStyle t(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: font,
      fontSize: size,
      fontWeight: weight,
      color: color ?? textBlack,
      height: height,
    );
  }

  // Bottom bar text styles
  static final TextStyle bottomBarAmountText = t(
    22,
    weight: FontWeight.w700,
    color: bottomBarAmount,
    height: 1.0,
  );

  static final TextStyle bottomBarVatText = t(
    12,
    weight: FontWeight.w200,
    color: bottomBarVat,
    height: 1.0,
  );

  static final TextStyle bottomBarButtonText = t(
    15,
    weight: FontWeight.w700,
    color: Colors.white,
  );

  // Fair use policy description text:
  // "add-ons can only be added to your active primary plan..."
  static final TextStyle fairUsePolicyDescription = const TextStyle(
    color: Color(0xFF222222),
    fontSize: 12,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  // "fair use policy" link text shown on top-right of PlanPurchasePlanPurchaseFairUsePolicyCard.
  static final TextStyle fairUsePolicyLink = const TextStyle(
    color: Color(0xFF645D9C),
    fontSize: 13,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    decorationColor: Color(0xFF645D9C),
  );

  // ---------------- Add-on Card Layout Tokens ----------------
  // Main add-on card corner radius.
  static const double addOnCardRadius = 8;

  // Internal card spacing: left, top, right, bottom.
  static const EdgeInsets addOnCardPadding =
      EdgeInsets.fromLTRB(16, 16, 16, 16);

  // Gap between title row and details row.
  static const double addOnCardTitleToDetailsGap = 16;

  // Details row icon/text spacing.
  static const double addOnCardIconToLabelGap = 2;
  static const double addOnCardLabelToValueGap = 6;

  // Amount chip visual style.
  static const Color addOnAmountChipColor = Color(0xFFF4F4F6);
  static const double addOnAmountChipRadius = 5;
  static const EdgeInsets addOnAmountChipPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );

  // Checkbox visual style.
  static const double addOnCheckboxSize = 15;
  static const double addOnCheckboxRadius = 2;
  static const double addOnCheckboxIconSize = 11;

  // Add-on card title ("liberty data 1")
  static const TextStyle addOnTitle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  // Add-on label text ("data balance")
  static const TextStyle addOnLabel = TextStyle(
    color: Color(0xFFFF6C36),
    fontSize: 18,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w400,
  );

  // Add-on value text ("1gb", "2gb")
  static const TextStyle addOnValue = TextStyle(
    color: Color(0xFF222222),
    fontSize: 24,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  // Add-on price text
  static const TextStyle addOnPrice = TextStyle(
    color: Color(0xFF222222),
    fontSize: 16,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  // ---------------- Red Plan Card Layout Tokens ----------------
  // Top gap from card edge to "active plan" text.
  static const double planRedCardTopTextGap = 13;
  // Bottom gap from card edge to active/expire date row.
  static const double planRedCardBottomRowGap = 26;
  // Horizontal padding inside red plan card.
  static const double planRedCardHorizontalPadding = 16;
  static const EdgeInsets planRedCardContentPadding = EdgeInsets.fromLTRB(
    planRedCardHorizontalPadding,
    planRedCardTopTextGap,
    planRedCardHorizontalPadding,
    planRedCardBottomRowGap,
  );
}
