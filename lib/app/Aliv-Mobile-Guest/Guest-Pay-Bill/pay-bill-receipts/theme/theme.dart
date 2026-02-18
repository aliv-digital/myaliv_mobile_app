import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class GuestPayBillReceiptTheme {
  // Page/app bar colors used by GuestPayBillReceiptScreen.
  static final Color screenBackground = HexColor.fromHex('#F1F2FA');
  static final Color appBarColor = HexColor.fromHex('#645D9C');

  // Main receipt card colors used by ReceiptSuccessCard.
  static final Color successIconOuter = HexColor.fromHex('#E6F4EC');
  static final Color successIconInner = HexColor.fromHex('#2E9E5B');
  static final Color successTitleColor = HexColor.fromHex('#111111');
  static final Color successBodyColor = HexColor.fromHex('#707070');
  static final Color cardValueTextColor = HexColor.fromHex('#121212');

  // Shared dashed divider colors used by ReceiptTicketDivider.
  static final Color defaultDashColor = HexColor.fromHex('#DDDDDD');
  static final Color redDashColor = HexColor.fromHex('#FDA29B');

  // Back button colors used by ReceiptBackButton.
  static final Color backButtonBackgroundColor = HexColor.fromHex('#EDEDF3');
  static final Color backButtonTextColor = HexColor.fromHex('#645D9C');
  static final Color successButtonTextColor = backButtonTextColor;

  // Optional failure-mode colors for receipt failure widgets.
  static final Color circleBackground = HexColor.fromHex('#FCE8E1');
  static final Color failedButtonBackgroundColor = HexColor.fromHex('#F2F1F9');
  static final Color textGrey = HexColor.fromHex('#707070');

  // Root content padding used by GuestPayBillReceiptScreen.
  static const EdgeInsets contentPadding = EdgeInsets.only(
    left: 24,
    right: 24,
    top: 29,
    bottom: 30,
  );

  // ReceiptSuccessCard title text style ("Payment Success!").
  static final TextStyle successTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: successTitleColor,
  );

  // ReceiptSuccessCard helper text style below the first divider.
  static final TextStyle successBody = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: successBodyColor,
  );

  // ReceiptDetailRow left label style (e.g., service/date/time).
  static final TextStyle detailLabel = TextStyle(
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: HexColor.fromHex('#7A7A7A'),
  );

  // ReceiptDetailRow right value style for regular rows.
  static final TextStyle detailValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: cardValueTextColor,
  );

  // ReceiptDetailRow right value style for emphasized amount row.
  static final TextStyle detailValueBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: cardValueTextColor,
  );

  // ReceiptBackButton text style.
  static final TextStyle backButtonText = TextStyle(
    color: backButtonTextColor,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
  );
}
