import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class ForgetPasswordColors {
  // Base screen colors.
  static const Color pageBackground = Color(0xFFFFFFFF);
  static const Color textBlack = Color(0xFF000000);
  static const Color subtitleGrey = Color(0xFF58677D);

  // Form colors.
  static const Color hintGrey = Color(0xFF8A8A8F);
  static const Color linkBlue = Color(0xFF13AEE1);
  static const Color actionLinkPurple = Color(0xFF645D9C);
  static const Color fieldBorder = Color(0xFFE0E0E0);

  // Focused input border gradient colors.
  static const Color focusedInputBorderYellow = Color(0xFFFFC627);
  static const Color focusedInputBorderBlue = Color(0xFF00B3E3);
  static const Color focusedInputBorderPurple = Color(0xFF4B298C);
  static const Color focusedInputBorderPink = Color(0xFFFF9BB1);
  static const Color focusedInputBorderOrange = Color(0xFFFF6C36);

  // Terms & privacy text colors.
  static const Color termsBase = Color(0xFF58677D);

  // Footer stripe colors.
  static const Color stripeOrange = Color(0xFFF26C4F);
  static const Color stripePink = Color(0xFFE89BB8);
  static const Color stripeBlack = Color(0xFF000000);
  static const Color stripeBlue = Color(0xFF6ECFF6);
  static const Color stripeYellow = Color(0xFFFBB03B);
}

class ForgetPasswordSizes {
  // Back-button placement aligned with login and loginOtp screens.
  static const double backLeft = 16.64;
  static const double backTopFromScreen = 53.31;
  static const double backIconWidth = 16.64;
  static const double backIconHeight = 14.43;

  // Header composition.
  static const double headerToLogoGap = 22;
  // Absolute logo top offset from the device screen top (includes status bar).
  static const double logoTopFromScreen = 132.15;
  // Absolute phone-row top offset from the device screen top (includes status bar).
  static const double phoneRowTopFromScreen = 303.71;
  static const double logoWidth = 99.24;
  static const double logoHeight = 50.79;
  static const double logoToTitleGap = 44;
  static const double titleToSubtitleGap = 0;
  static const double subtitleWidth = 294;

  // Field sizes.
  static const double fieldHeight = 54;
  static const double fieldRadius = 8;
  static const double fieldBorderWidth = 1;
  static const double countryWidth = 76;
  static const double countryFlagFontSize = 20;
  static const double countryArrowSize = 16;
  static const double countryFlagToCodeGap = 6;
  static const double countryCodeToArrowGap = 4;
  static const double countryToPhoneGap = 12;
  static const double genericInputBorderWidth = 1;

  // Screen layout spacing.
  static const double contentHorizontalPadding = 47;
  static const double headerToPhoneGap = 9.61;
  static const double phoneToSendGap = 20;
  static const double sendToTermsGap = 147;
  static const double termsHorizontalPadding = 32;
  static const double bottomPromptToActionGap = 6;

  // Footer stripe heights.
  static const double stripeHeightLarge = 8;
  static const double stripeHeightSmall = 6;
}

class ForgetPasswordPaddings {
  // Shared horizontal padding for page content.
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(
    horizontal: ForgetPasswordSizes.contentHorizontalPadding,
  );

  // Internal paddings for form fields.
  static const EdgeInsets countryHorizontal8 =
      EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets fieldHorizontal14 =
      EdgeInsets.symmetric(horizontal: 14);
  static const EdgeInsets genericInputContent =
      EdgeInsets.symmetric(vertical: 10, horizontal: 12);

  // Terms paragraph wrapper padding.
  static const EdgeInsets termsHorizontal = EdgeInsets.symmetric(
    horizontal: ForgetPasswordSizes.termsHorizontalPadding,
  );
}

class ForgetPasswordDecorations {
  // Default border for form controls.
  static const BorderSide inputBorder = BorderSide(
    color: ForgetPasswordColors.fieldBorder,
    width: ForgetPasswordSizes.fieldBorderWidth,
  );

  // Border for generic custom input field.
  static const BorderSide genericInputBorder = BorderSide(
    color: ForgetPasswordColors.fieldBorder,
    width: ForgetPasswordSizes.genericInputBorderWidth,
  );
}

class ForgetPasswordMotion {
  // Bottom-stripes animation when keyboard toggles.
  static const Duration stripeSwitcherDuration = Duration(milliseconds: 180);
  static const Curve stripeSwitcherInCurve = Curves.easeOut;
  static const Curve stripeSwitcherOutCurve = Curves.easeIn;
}

class ForgetPasswordStripePalette {
  // Ordered top-to-bottom stripe configuration.
  static const List<Color> colors = <Color>[
    ForgetPasswordColors.stripeOrange,
    ForgetPasswordColors.stripePink,
    ForgetPasswordColors.stripeBlack,
    ForgetPasswordColors.stripeBlue,
    ForgetPasswordColors.stripeYellow,
  ];

  static const List<double> heights = <double>[
    ForgetPasswordSizes.stripeHeightLarge,
    ForgetPasswordSizes.stripeHeightSmall,
    ForgetPasswordSizes.stripeHeightSmall,
    ForgetPasswordSizes.stripeHeightSmall,
    ForgetPasswordSizes.stripeHeightLarge,
  ];
}

class ForgetPasswordGradients {
  // Gradient used for focused input border state.
  static const LinearGradient focusedInputBorder = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      ForgetPasswordColors.focusedInputBorderYellow,
      ForgetPasswordColors.focusedInputBorderBlue,
      ForgetPasswordColors.focusedInputBorderPurple,
      ForgetPasswordColors.focusedInputBorderPink,
      ForgetPasswordColors.focusedInputBorderOrange,
    ],
  );
}

class ForgetPasswordTheme {
  // Header title: "verify your number"
  static const TextStyle title = TextStyle(
    fontSize: 17,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: ForgetPasswordColors.textBlack,
  );

  // Header subtitle: "please enter your mobile..."
  static const TextStyle subtitle = TextStyle(
    fontSize: 15,
    height: 1.47,
    fontFamily: AppConstants.defaultFontFamily,
    // Design asks for w450; Flutter named weights are discrete, so w500 is used.
    fontWeight: FontWeight.w500,
    color: ForgetPasswordColors.subtitleGrey,
  );

  // Country dial code text inside the picker box
  static const TextStyle dialCode = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: ForgetPasswordColors.textBlack,
  );

  // Phone input text style
  static const TextStyle phoneInput = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: ForgetPasswordColors.textBlack,
  );

  // Phone input hint text
  static TextStyle phoneHint = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    color: ForgetPasswordColors.hintGrey,
  );

  // Country flag text in the phone-country picker.
  static const TextStyle countryFlag = TextStyle(
    fontSize: ForgetPasswordSizes.countryFlagFontSize,
  );

  // Terms & privacy base text
  static const TextStyle termsBase = TextStyle(
    fontSize: 12,
    // Design asks for w450; Flutter named weights are discrete, so w500 is used.
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: ForgetPasswordColors.termsBase,
  );

  // Intro sentence style: "By pressing the 'send' button above you agree"
  static const TextStyle termsIntro = TextStyle(
    color: ForgetPasswordColors.termsBase,
    fontSize: 12,
    fontFamily: AppConstants.defaultFontFamily,
    // Design asks for w450; Flutter named weights are discrete, so w500 is used.
    fontWeight: FontWeight.w500,
  );

  // Terms & privacy clickable links
  static TextStyle termsLink = TextStyle(
    fontWeight: FontWeight.w500,
    color: ForgetPasswordColors.linkBlue,
  );

  // Terms & privacy loading/disabled link color
  static TextStyle termsLinkDisabled = TextStyle(
    fontWeight: FontWeight.w500,
    color: ForgetPasswordColors.hintGrey,
  );

  // Bottom prompt text: "still need to activate your account?"
  static const TextStyle accountActivationPrompt = TextStyle(
    color: ForgetPasswordColors.textBlack,
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  // Bottom action link text: "manage my password"
  static const TextStyle managePasswordLink = TextStyle(
    color: ForgetPasswordColors.actionLinkPurple,
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
    height: 1.43,
  );

  // Privacy link style: "Privacy Policy"
  static const TextStyle privacyPolicyLink = TextStyle(
    color: ForgetPasswordColors.actionLinkPurple,
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    decorationColor: Color(0xFF645D9C),
  );

  // Terms link style: "Terms & Conditions"
  static const TextStyle termsAndConditionsLink = TextStyle(
    color: ForgetPasswordColors.actionLinkPurple,
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
    decorationColor: Color(0xFF645D9C),
  );

  // Primary action button label style: "send"
  static const TextStyle sendButton = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1.80,
  );
}
