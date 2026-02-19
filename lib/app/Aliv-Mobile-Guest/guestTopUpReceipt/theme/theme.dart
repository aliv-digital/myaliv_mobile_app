import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class ReceiptTheme {
  // Screen/background colors (GuestTopUpReceiptScreen)
  static final Color screenBackground = HexColor.fromHex('#F1F2FA');
  static final Color appBarColor = HexColor.fromHex('#655C9A');

  // Success card colors (ReceiptSuccessCard)
  static final Color successIconOuter = HexColor.fromHex('#E6F4EC');
  static final Color successIconInner = HexColor.fromHex('#2E9E5B');
  static final Color successTitleColor = HexColor.fromHex('#111111');
  static final Color successBodyColor = HexColor.fromHex('#707070');
  static final Color successCardBackgroundColor = HexColor.fromHex('#FFFFFF');
  static const Color successCardShadowColor = Colors.transparent;
  static final Color successCardBottomDividerColor =
      HexColor.fromHex('#E9E9EE');
  static final Color circleBackground = HexColor.fromHex('#FCE8E1');

  // Failure card colors (ReceiptFailureCard)
  static final Color failureTitleColor = HexColor.fromHex('#FB2F2F');
  static final Color failureBodyColor = HexColor.fromHex('#7A7A7A');

  // Ticket divider colors (ReceiptTicketDivider)
  static final Color defaultDashColor = HexColor.fromHex('#DDDDDD');
  static final Color redDashColor = HexColor.fromHex('#FDA29B');

  // Pill button colors (ReceiptBackButton + PaymentFailedTicket)
  static final Color failedButtonBackgroundColor = HexColor.fromHex('#F2F1F9');
  static final Color successButtonTextColor = HexColor.fromHex('#645D9C');

  // Shared text color (detail values)
  static final Color successCardValueTextBlack = HexColor.fromHex('#121212');

  // Success card layout values (ReceiptSuccessCard)
  // Outer card shape.
  static const double successCardCornerRadius = 12;
  static const double successCardElevation = 0;

  // Card inner padding from Figma:
  // top = 32, left/right = 24, bottom = 24.
  static const EdgeInsets successCardPadding =
      EdgeInsets.fromLTRB(24, 32, 24, 32);

  // Side-notch geometry for the ticket cut.
  static const double successCardNotchRadius = 10;
  // Ticket notch vertical position from card top edge.
  static const double successCardNotchTopOffset = 164;

  // Icon block sizes.
  static const double successIconOuterSize = 56;
  static const double successIconInnerSize = 30;
  static const double successIconCheckSize = 18;

  // Width lock for title/body copy shown in Figma.
  static const double successCardContentWidth = 297;

  // Vertical spacing rhythm.
  static const double successGapAfterIcon = 16;
  static const double successGapAfterTitle = 32;
  static const double successGapAfterMessage = 16;
  static const double successGapBeforeAmount = 16;
  static const double successGapAfterAmount = 32;
  static const double successGapAfterBottomDivider = 32;
  static const double successGapAfterButton = 24 + 32;

  // Divider spacing and stroke values.
  static const double successDashedDividerStrokeWidth = 1;
  static const double successDashedDividerHorizontalInset = 6;
  static const double successBottomDividerThickness = 1;

  // Row spacing inside details section.
  static const double successDetailRowVerticalPadding = 7;

  // ReceiptSuccessCard title text
  static final TextStyle successTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: successTitleColor,
  );

  // ReceiptSuccessCard helper copy
  static final TextStyle successBody = TextStyle(
    fontSize: 16,
    // Figma asks w450; w400 is the closest Flutter weight.
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: successBodyColor,
  );

  // ReceiptDetailRow label (left column)
  static final TextStyle detailLabel = TextStyle(
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: HexColor.fromHex('#7A7A7A'),
  );

  // ReceiptDetailRow value (normal)
  static final TextStyle detailValue = TextStyle(
    fontSize: 16,
    // Figma asks w450; w400 is the closest Flutter weight.
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: successCardValueTextBlack,
  );

  // ReceiptDetailRow value (bold)
  static final TextStyle detailValueBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: successCardValueTextBlack,
  );

  // ReceiptFailureCard title text
  static final TextStyle failureTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w900,
    fontFamily: AppConstants.defaultFontFamily,
    color: failureTitleColor,
  );

  // ReceiptFailureCard message copy
  static final TextStyle failureMessage = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: failureBodyColor,
  );

  // ReceiptFailureCard helper line
  static final TextStyle failureHelper = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: failureBodyColor,
  );

  // ReceiptFailureCard phone number
  static final TextStyle failurePhone = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: Colors.black,
  );

  // ReceiptBackButton label
  static final TextStyle backButtonText = TextStyle(
    color: successButtonTextColor,
    fontSize: 13,
    // Flutter has no exact w450; w400 is the closest available weight.
    fontWeight: FontWeight.w400,
    fontFamily: 'CircularPro',
  );

  // ReceiptBackButton colors + shape.
  static const Color backButtonBackgroundColor = Colors.white;
  static final Color backButtonBorderColor = HexColor.fromHex('#F2F1F9');
  static const double backButtonWidth = 156;
  static const double backButtonHeight = 40;
  static const double backButtonRadius = 100;
  static const EdgeInsets backButtonPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 12);

  // PaymentFailedTicket title base (color applied via copyWith)
  static final TextStyle ticketTitleBase = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
  );

  // PaymentFailedTicket message/helper text
  static final TextStyle ticketBody = TextStyle(
    color: HexColor.fromHex('#333333'),
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
  );

  // PaymentFailedTicket phone text
  static final TextStyle ticketPhone = TextStyle(
    color: HexColor.fromHex('#333333'),
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
  );

  // PaymentFailedTicket button label
  static final TextStyle ticketButtonText = TextStyle(
    color: successButtonTextColor,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
  );
}
