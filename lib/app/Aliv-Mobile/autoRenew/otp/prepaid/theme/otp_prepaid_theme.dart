import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class OtpAutoRenewPrepaidTheme {
  // ==================== Typography ====================
  // Shared font family used across OTP screen widgets.
  static const String fontFamily = AppConstants.defaultFontFamily;

  // ==================== Colors ====================
  // Used as scaffold background in otp_prepaid_screen.dart.
  static const Color scaffoldBackground = Colors.white;

  // Used as title color in otp_prepaid_header.dart.
  static const Color headerTitleColor = Color(0xFF000000);

  // Used as subtitle color in otp_prepaid_header.dart.
  static final Color headerSubtitleColor = HexColor.fromHex('#58677D');

  // Used as OTP field text color in otp_prepaid_code_fields.dart.
  static const Color otpDigitTextColor = Color(0xFF000000);

  // Used as default OTP input border color in otp_prepaid_code_fields.dart.
  static const Color otpInputBorderColor = Color(0xFFE0E0E0);

  // Used as OTP box background behind the digit input in otp_prepaid_code_fields.dart.
  static const Color otpInputBackgroundColor = Color(0xFFFFFFFF);

  // Used in otp_prepaid_code_fields.dart for focused gradient border (left to right).
  static const Color otpFocusedBorderYellow = Color(0xFFFFC627);
  static const Color otpFocusedBorderBlue = Color(0xFF00B3E3);
  static const Color otpFocusedBorderPurple = Color(0xFF4B298C);
  static const Color otpFocusedBorderPink = Color(0xFFFF9BB1);
  static const Color otpFocusedBorderOrange = Color(0xFFFF6C36);

  // Used for "didn't receive a code?" prompt in otp_prepaid_bottom_action.dart.
  static const Color resendPromptColor = Color(0xFF121212);

  // Used for resend action text in otp_prepaid_bottom_action.dart.
  static const Color resendActionColor = Color(0xFF645D9C);

  // ==================== Dimensions ====================
  // Used for the number of OTP boxes in otp_prepaid_code_fields.dart.
  static const int otpLength = 5;

  // Used for top header back button placement in otp_prepaid_header.dart.
  static const EdgeInsets headerBackButtonPadding =
      EdgeInsets.only(left: 24, top: 53);

  // Used for OTP illustration sizing in otp_prepaid_header.dart.
  static const double headerIllustrationWidth = 162.0;
  static const double headerIllustrationHeight = 170.0;

  // Used for spacing between header sections in otp_prepaid_header.dart.
  static const double headerBackToIllustrationGap = 16.0;
  static const double headerIllustrationToTitleGap = 21.0;
  static const double headerTitleToSubtitleGap = 16.0;

  // Used for OTP input box sizing in otp_prepaid_code_fields.dart.
  static const double otpBoxSize = 52.0;
  static const double otpBoxBorderRadius = 6.0;
  static const double otpBoxBorderWidth = 1.0;

  // Used for OTP input content padding in otp_prepaid_code_fields.dart.
  static const EdgeInsets otpFieldContentPadding =
      EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 15);

  // Used for main OTP content horizontal padding in otp_prepaid_screen.dart.
  static const EdgeInsets contentHorizontalPadding =
      EdgeInsets.only(left: 41, right: 41);

  // Used for spacing between OTP content sections in otp_prepaid_screen.dart.
  static const double topGapBeforeOtpBoxes = 24.0;
  static const double otpBoxesToBottomActionsGap = 54.0;
  static const double bottomActionsToScrollEndGap = 24.0;

  // Used for verify button sizing in otp_prepaid_bottom_action.dart.
  static const double verifyButtonHeight = 52.0;
  static const double verifyButtonRadius = 100.0;
  static const double verifyButtonElevation = 0.0;

  // Used for bottom action internal spacing in otp_prepaid_bottom_action.dart.
  static const double verifyButtonToResendRowGap = 20.0;
  static const double resendPromptToActionGap = 8.0;
  static const double resendRowToBottomGap = 113.0;

  // Used for keyboard-aware stripes animation in otp_prepaid_screen.dart.
  static const Duration bottomStripeAnimationDuration =
      Duration(milliseconds: 180);

  // ==================== Text Styles ====================
  // Used in otp_prepaid_header.dart for "verification code".
  static const TextStyle verificationTitleTextStyle = TextStyle(
    fontSize: 24,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    color: headerTitleColor,
  );

  // Used in otp_prepaid_header.dart for the OTP instruction subtitle.
  static TextStyle verificationSubtitleTextStyle() => TextStyle(
        fontSize: 15,
        color: headerSubtitleColor,
        height: 1.4,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      );

  // Used in otp_prepaid_code_fields.dart for OTP digit text.
  static const TextStyle otpDigitTextStyle = TextStyle(
    fontSize: 20,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w600,
    color: otpDigitTextColor,
  );

  // Used in otp_prepaid_bottom_action.dart for "didn't receive a code?".
  static const TextStyle resendPromptTextStyle = TextStyle(
    color: resendPromptColor,
    fontSize: 14,
    fontFamily: fontFamily,
    // Flutter does not provide FontWeight.w450; w500 is the closest built-in option.
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  // Used in otp_prepaid_bottom_action.dart for "resend code" / "sending...".
  static const TextStyle resendActionTextStyle = TextStyle(
    color: resendActionColor,
    fontSize: 13,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
  );

  // Used in otp_prepaid_bottom_action.dart for verify button label.
  static const TextStyle verifyButtonTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    height: 1.80,
  );

  // Used in otp_prepaid_bottom_action.dart for verify button shape.
  static const BorderRadius verifyButtonBorderRadius =
      BorderRadius.all(Radius.circular(verifyButtonRadius));

  // Used in otp_prepaid_bottom_action.dart for verify button color.
  static const Color verifyButtonBackgroundColor = Color(0xFF645D9C);

  // Used in otp_prepaid_code_fields.dart as focused OTP border gradient.
  static const LinearGradient otpFocusedBorderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      otpFocusedBorderYellow,
      otpFocusedBorderBlue,
      otpFocusedBorderPurple,
      otpFocusedBorderPink,
      otpFocusedBorderOrange,
    ],
  );
}
