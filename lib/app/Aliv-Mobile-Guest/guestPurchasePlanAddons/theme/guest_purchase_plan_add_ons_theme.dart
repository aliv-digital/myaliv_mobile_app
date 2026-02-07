import 'package:flutter/material.dart';

class GuestPurchasePlanAddOnsTheme {
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

  static TextStyle t(double size, {
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
    13,
    weight: FontWeight.w500,
    color: Colors.white,
  );

  // Add-ons helper text
  static final TextStyle addOnHelper = t(
    12,
    weight: FontWeight.w700,
    color: addOnHelperColor,
    height: 1.35,
  );

  // Add-on card title
  static final TextStyle addOnTitle = t(
    18,
    weight: FontWeight.w700,
    color: textBlack,
  );

  // Add-on label (data balance)
  static final TextStyle addOnLabel = t(
    18,
    weight: FontWeight.w500,
    color: addOnLabelColor,
  );

  // Add-on value (1gb)
  static final TextStyle addOnValue = t(
    24,
    weight: FontWeight.w700,
    color: textBlack,
  );

  // Add-on price text
  static final TextStyle addOnPrice = t(
    16,
    weight: FontWeight.w700,
    color: outlinePurple,
  );
}
