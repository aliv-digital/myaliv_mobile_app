import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class AuthModuleColors {
  // Primary purple used in login accents and outline actions.
  static const Color alivPurple = Color(0xFF645D9C);

  // Social login outline/text purple.
  static const Color socialMediaButtonPurple = Color(0xFF746BB9);

  // Semi-transparent purple used for outlined button text in older mocks.
  static const Color loginRoundOutLinedBorderButton = Color(0xCC5146A8);

  // Neutral UI colors for fields, hints, and base surfaces.
  static const Color pageBackground = Color(0xFFFFFFFF);
  static const lightGreyBorder = Color(0xFFE5E5EA);
  static const errorRed = Color(0xFFFF3B30);
  static const Color hintGrey = Color(0xFF8A8A8F);
  static const Color linkBlue = Color(0xFF13AEE1);
  static const textBlack = Color(0xFF000000);
  static const Color textInputBorderColor = Color(0xFFE0E0E0);
  static const Color loginFieldBorderColor = Color(0xFFE0E0E0);
  static const Color lockColor = Color(0xFF707070);
  static const Color activateAccountPrompt = Color(0xFF1C1C1C);
  static const Color managePassword = Color(0xFF645D9C);

  // Label color for the divider text: "or sign in with".
  static const orSignInWithTextColor = Color(0xFF8A8A8F);
}

class AuthModuleSizes {
  // Header placement values measured from full screen top.
  static const double backLeft = 16;
  static const double backTopFromScreen = 53;
  static const double logoTopFromScreen = 60;
  static const double backIconWidth = 16.64;
  static const double backIconHeight = 14.43;
  static const double logoWidth = 95.42;
  static const double logoHeight = 48.86;
  static const double logoToTitleGap = 30;

  // Shared field dimensions.
  static const double fieldHeight = 50;
  static const double fieldRadius = 8;
  static const double fieldBorderWidth = 1;
  static const double genericInputBorderWidth = 1;

  // Login page layout spacing.
  static const double contentHorizontalPadding = 47;
  static const double welcomeToPhoneGap = 109.14;
  static const double phoneToPasswordGap = 15;
  static const double passwordToErrorRowGap = 15;
  static const double errorRowToSignInGap = 15;
  static const double signInToSocialGap = 56;
  static const double socialToBottomGap = 60;
  static const double bottomScrollSafeGap = 113;
  static const double bottomTextsBottomOffset = 112;
  static const double bottomTextsHorizontalPadding = 41;

  // Social block sizing.
  static const double socialButtonHeight = 40;
  static const double socialButtonRadius = 22;
  static const double socialButtonsGap = 16;
  static const double socialContentHorizontalPadding = 20;
  static const double socialContentVerticalPadding = 10;
  static const double dividerWidth = 23;
  static const double dividerHeight = 1;
  static const double dividerLabelGap = 10;
  static const double dividerToButtonsGap = 30;

  // Bottom helper texts spacing.
  static const double activatePromptWidth = 296;
  static const double activatePromptToLinkGap = 4;

  // Misc element sizing.
  static const double lockIconSize = 18;
  static const double lockToInputGap = 10;
  static const double eyeIconSize = 20;
  static const double countryWidth = 76;
  static const double countryFlagFontSize = 20;
  static const double countryFlagToCodeGap = 6;
  static const double countryCodeToArrowGap = 4;
  static const double countryToPhoneGap = 10;
  static const double countryArrowSize = 16;

  // Decorative stripe heights at page bottom.
  static const double stripeHeight = 14;
  static const double stripeTotalHeight = stripeHeight * 5;
}

class AuthModulePaddings {
  // Common zero-padding for compact text buttons.
  static const EdgeInsets zero = EdgeInsets.zero;

  // Shared internal paddings for input controls.
  static const EdgeInsets fieldHorizontal14 = EdgeInsets.symmetric(horizontal: 14);
  static const EdgeInsets countryHorizontal8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets genericInputContent = EdgeInsets.symmetric(vertical: 10, horizontal: 12);

  // Login content wrapper padding.
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(
    horizontal: AuthModuleSizes.contentHorizontalPadding,
  );

  // Social button content padding from design.
  static const EdgeInsets socialButtonContent = EdgeInsets.symmetric(
    horizontal: AuthModuleSizes.socialContentHorizontalPadding,
    vertical: AuthModuleSizes.socialContentVerticalPadding,
  );
}

class AuthModuleButtonStyles {
  // Compact link button style used for inline text actions.
  static final ButtonStyle inlineTextLink = TextButton.styleFrom(
    padding: AuthModulePaddings.zero,
    minimumSize: const Size(0, 0),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  // Shared outline style for social login buttons.
  static final ButtonStyle socialOutlined = OutlinedButton.styleFrom(
    side: const BorderSide(
      color: AuthModuleColors.socialMediaButtonPurple,
      width: AuthModuleSizes.fieldBorderWidth,
    ),
    padding: AuthModulePaddings.socialButtonContent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AuthModuleSizes.socialButtonRadius),
    ),
  );
}

class AuthModuleTextStyles {
  // Design requests 450 weight; Flutter exposes 100-step named weights,
  // so w500 is used as the closest built-in value.
  static const TextStyle orSignInWith = TextStyle(
    color: AuthModuleColors.orSignInWithTextColor,
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    height: 1.38,
    letterSpacing: -0.08,
  );

  // Label style for both social login action buttons.
  static const TextStyle socialMediaButton = TextStyle(
    color: AuthModuleColors.socialMediaButtonPurple,
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1.43,
  );

  // Design asks for 450; Flutter named weights are discrete, so w500 is closest.
  static const TextStyle activateAccountPrompt = TextStyle(
    color: AuthModuleColors.activateAccountPrompt,
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    height: 1.43,
  );

  // Style for the "manage my password" link in login bottom section.
  static const TextStyle manageMyPassword = TextStyle(
    color: AuthModuleColors.managePassword,
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
  );

  // Header title style below ALIV logo.
  static const TextStyle welcomeBack = TextStyle(
    fontSize: 17,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w600,
    color: AuthModuleColors.textBlack,
  );

  // Field text style for phone/password inputs.
  static const TextStyle fieldValue = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: AuthModuleColors.textBlack,
  );

  // Placeholder style used in phone/password fields.
  static const TextStyle fieldHint = TextStyle(
    fontSize: 14,
    color: AuthModuleColors.hintGrey,
  );

  // Country code style shown beside flag.
  static const TextStyle countryCode = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: AuthModuleColors.textBlack,
  );

  // Country flag emoji sizing.
  static const TextStyle countryFlag = TextStyle(
    fontSize: AuthModuleSizes.countryFlagFontSize,
  );

  // Login error label shown for invalid credentials.
  static const TextStyle invalidCredentials = TextStyle(
    fontSize: 12,
    color: AuthModuleColors.errorRed,
  );

  // Forgot password link style in form row.
  static const TextStyle forgotPassword = TextStyle(
    fontSize: 13,
    color: AuthModuleColors.managePassword,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    decoration: TextDecoration.underline,
  );

  // Password hint uses increased bullet spacing.
  static  TextStyle passwordHint = TextStyle(
    //color: Color(0xFF667085) /* Colors-Text-text-placeholder */,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    color: AuthModuleColors.hintGrey,
  );

  // Primary sign-in button label style.
  static const TextStyle signInButton = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1.80,
  );
}

class AuthModuleDecorations {
  // Border used by the generic custom input field widget.
  static const BorderSide genericInputBorder = BorderSide(
    color: AuthModuleColors.textInputBorderColor,
    width: AuthModuleSizes.genericInputBorderWidth,
  );

  // Shared border for normal input containers.
  static const BorderSide inputBorder = BorderSide(
    color: AuthModuleColors.loginFieldBorderColor,
    width: AuthModuleSizes.fieldBorderWidth,
  );

  // Error border for invalid password input state.
  static const BorderSide inputErrorBorder = BorderSide(
    color: AuthModuleColors.errorRed,
    width: AuthModuleSizes.fieldBorderWidth,
  );
}

class AuthModuleStripePalette {
  // Ordered top-to-bottom colors for login footer stripes.
  static const List<Color> colors = <Color>[
    Color(0xFFF26C4F),
    Color(0xFFE89BB8),
    Color(0xFF000000),
    Color(0xFF6ECFF6),
    Color(0xFFFBB03B),
  ];
}
