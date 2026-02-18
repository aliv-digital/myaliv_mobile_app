import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class GuestTopUpTheme {
  // Screen copy for guest top-up form.
  static const String activePrepaidLabel = 'please enter an active prepaid number to top-up';
  static const String confirmMobileLabel = 'confirm mobile number';
  static const String amountLabel = 'enter top-up amount';
  static const String phoneHintText = 'eg: 2428999999';
  static const String amountHintText = '00.00';
  static const String nextButtonLabel = 'next';
  static const String fallbackErrorMessage = 'Something went wrong';

  // Guest top-up screen background.
  static const Color screenBackgroundColor = Color(0xFFFFFFFF);

  static Color appBarColor = HexColor.fromHex('#645D9C');
  static Color headingColor = HexColor.fromHex('#000000');
  static Color bodyTextColor = HexColor.fromHex('#707070');
  static Color inputFieldBackgroundColor = HexColor.fromHex('#F2F1F9');
  static Color inputFieldBorderColor = HexColor.fromHex('#E0E0E0');

  // Gradient border colors (Figma)
  static Color yellow = HexColor.fromHex('#FFC627');
  static Color blue = HexColor.fromHex('#00B3E3');
  static Color purple = HexColor.fromHex('#4B298C');
  static Color lightPink = HexColor.fromHex('#FF9BB1');
  static Color orange = HexColor.fromHex('#FF6C36');

  // Selection color (Figma)
  static Color selection = HexColor.fromHex('#5146A8');

  static Color amountTextColor = HexColor.fromHex('#5146A8');
  static Color simpleTxt = HexColor.fromHex('#222222');

  static final Color amountValueColor = HexColor.fromHex('#5146A8');

  // Shared phone field dimensions and border settings.
  static const double phoneFieldHeight = 48;
  static const double countryPickerHeight = 48;
  static const double phoneFieldRadius = 8;
  static const double phoneFieldBorderWidth = 1;
  static const double countryToPhoneGap = 10;

  // Focused-state gradient border for phone inputs.
  static final LinearGradient focusedInputBorderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      yellow,
      blue,
      purple,
      lightPink,
      orange,
    ],
  );

  // Amount input field dimensions from design.
  static const double amountFieldOuterHorizontalPadding = 68;
  static const double amountFieldHeight = 71;
  static const double amountFieldRadius = 10;
  static const double amountFieldBorderWidth = 3;
  static const double amountFieldLabelToFieldGap = 2;
  static const double amountFieldTextHorizontalInset = 68;

  // Elevation below the amount input card.
  static const Color amountFieldShadowColor = Color(0x1A000000);
  static const double amountFieldShadowBlur = 12;
  static const double amountFieldShadowOffsetY = 6;

  // Default value shown in the amount input.
  static const String amountDefaultValue = r'$15.00';

  // Exact gradient palette provided for the amount border.
  static final List<Color> amountFieldBorderGradientColors = <Color>[
    yellow,
    blue,
    purple,
    lightPink,
    orange,
    lightPink,
    purple,
    blue,
    yellow,
  ];

  // Position each color along the border loop:
  // top-left -> top -> top-right -> right -> bottom-right -> bottom -> bottom-left -> left -> top-left.
  static const List<double> amountFieldBorderGradientStops = <double>[
    0.00, // yellow at top-left start
    0.22, // blue across top edge
    0.40, // purple near top-right
    0.46, // pink on right side
    0.52, // orange at bottom-right
    0.68, // pink across bottom
    0.86, // purple near bottom-left
    0.94, // blue on left side
    1.00, // yellow closes back to top-left
  ];

  // Input label text above phone fields
  static final TextStyle inputLabel = TextStyle(
    fontSize: 14,
    height: 1.43,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // First heading: "please enter an active prepaid number to top up"
  static const TextStyle activePrepaidPrompt = TextStyle(
    color: Color(0xFF1C1C1C),
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    height: 1.43,
  );

  // Exact spacing for the first heading block.
  static const double activePrepaidTopGap = 25.49;
  static const double activePrepaidHorizontal = 23.5;

  // Phone input text
  static final TextStyle phoneInput = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: Color(0xFF000000),
  );

  // Phone input hint
  static final TextStyle phoneHint = TextStyle(
    // 70% opacity of #707070 for the phone placeholder text.
    color: Color(0xB3707070),
    fontSize: 14,
    height: 1.43,
    fontFamily: AppConstants.defaultFontFamily,
    // Flutter has no named w450, so w500 is the closest available weight.
    fontWeight: FontWeight.w500,
  );

  // Country dial code text inside picker
  static final TextStyle dialCode = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: Color(0xFF111111),
  );

  // Top-up amount input text
  static final TextStyle amountInput = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: amountValueColor,
  );

  // Top-up amount prefix ($)
  static final TextStyle amountPrefix = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: amountValueColor,
  );

  // Top-up amount hint
  static final TextStyle amountHint = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    fontFamily: AppConstants.defaultFontFamily,
    color: amountValueColor.withValues(alpha: 0.35),
  );

  // Helper text below amount field
  static final TextStyle amountHelper = TextStyle(
    fontSize: 12,
    // Flutter has no named w450, so w500 is the closest available weight.
    fontWeight: FontWeight.w500,
    fontFamily: AppConstants.defaultFontFamily,
    color: Color(0xFF1C1C1C),
  );

  // SnackBar message text
  static final TextStyle snackBarText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
  );
}
