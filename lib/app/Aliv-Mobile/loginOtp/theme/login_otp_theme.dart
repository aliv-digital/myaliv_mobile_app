import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';

class LoginOtpColors {
  // Primary text color used in OTP screen.
  static const Color textBlack = Color(0xFF000000);
  static const Color screenBackground = Color(0xFFFFFFFF);

  // OTP box base fill and unfocused border color.
  static const Color otpBoxBackground = Color(0xFFFFFFFF);
  static const Color otpBoxBorderDefault = Color(0xFFE0E0E0);

  // Action/link colors on OTP screen.
  static const Color actionLinkPurple = Color(0xFF645D9C);
  static const Color helperTextDark = Color(0xFF121212);

  // Focused OTP border gradient palette (same as login input focused border).
  static const Color focusedInputBorderYellow = Color(0xFFFFC627);
  static const Color focusedInputBorderBlue = Color(0xFF00B3E3);
  static const Color focusedInputBorderPurple = Color(0xFF4B298C);
  static const Color focusedInputBorderPink = Color(0xFFFF9BB1);
  static const Color focusedInputBorderOrange = Color(0xFFFF6C36);
}

class LoginOtpSizes {
  // Header back-button placement and icon dimensions.
  static const double backLeft = 16;
  static const double backTopFromScreen = 53;
  static const double backIconWidth = 16.64;
  static const double backIconHeight = 14.43;

  // Header artwork positioning and sizing.
  static const double otpImageTopFromScreen = 123;
  static const double otpImageWidth = 162.7;
  static const double otpImageHeight = 170;
  static const double otpImageToTitleGap = 21;
  static const double titleToSubtitleGap = 16;

  // Scroll content layout spacing.
  static const double contentHorizontalPadding = 41;
  static const double contentTopGap = 24;
  static const double otpToBottomActionsGap = 54;

  static const double contentBottomGap = 26;

  // Bottom fixed action placement over stripes.
  static const double changePhoneBottomOffset = 22;

  // OTP single-cell dimensions.
  static const double otpBoxSize = 52;
  static const double otpBoxRadius = 6;
  static const double otpBoxBorderWidth = 1;

  // Inner content padding for OTP digit alignment.
  static const EdgeInsets otpBoxContentPadding = EdgeInsets.only(
    left: 15,
    right: 15,
    top: 10,
    bottom: 15,
  );

  // Gap between verify button and resend row.
  static const double verifyToResendGap = 20;
}

class LoginOtpGradients {
  // Gradient used when OTP box is focused.
  static const LinearGradient focusedInputBorder = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      LoginOtpColors.focusedInputBorderYellow,
      LoginOtpColors.focusedInputBorderBlue,
      LoginOtpColors.focusedInputBorderPurple,
      LoginOtpColors.focusedInputBorderPink,
      LoginOtpColors.focusedInputBorderOrange,
    ],
  );
}

class LoginOtpPaddings {
  // Shared horizontal padding for OTP content column.
  static const EdgeInsets contentHorizontal = EdgeInsets.symmetric(
    horizontal: LoginOtpSizes.contentHorizontalPadding,
  );
}

class LoginOtpMotion {
  // Bottom stripes show/hide animation when keyboard toggles.
  static const Duration stripeSwitcherDuration = Duration(milliseconds: 180);
  static const Curve stripeSwitcherInCurve = Curves.easeOut;
  static const Curve stripeSwitcherOutCurve = Curves.easeIn;
}

class LoginOtpTheme {
  // Header title: "verification code"
  static const TextStyle title = TextStyle(
    fontSize: 24,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: LoginOtpColors.textBlack,
  );

  // Header subtitle: "we have sent a verification code..."
  static TextStyle subtitle = TextStyle(
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
    fontFamily: AppConstants.defaultFontFamily,
    color: ColorManager.otpScreenTxtGray,
  );

  // OTP input digits style inside code boxes
  static const TextStyle otpInput = TextStyle(
    fontSize: 20,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w600,
    color: LoginOtpColors.textBlack,
  );

  // Helper text before resend action: "didn't receive a code?"
  // Design asks for 450; Flutter named weights are discrete, so w500 is closest.
  static const TextStyle helperText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    height: 1.43,
    color: LoginOtpColors.helperTextDark,
  );

  // Resend action text: "resend code" / "sending..."
  static const TextStyle resendText = TextStyle(
    color: LoginOtpColors.actionLinkPurple,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    decoration: TextDecoration.underline,
  );

  // Fixed bottom action: "change phone number"
  static const TextStyle changePhoneText = TextStyle(
    color: LoginOtpColors.actionLinkPurple,
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
  );

  // SnackBar message text for OTP errors
  static const TextStyle snackBarText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
  );

  // Verify button label style.
  static const TextStyle verifyButtonText = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1.80,
  );
}
