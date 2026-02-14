import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class GuestSplashTheme {
  // Primary purple from Figma.
  static final Color purple = HexColor.fromHex('#645D9C');

  // Primary token used for guest splash option button text.
  static final Color primaryButtonTextColor = purple;

  // Guest splash option button text style.
  static final TextStyle optionButtonText = TextStyle(
    color: primaryButtonTextColor,
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.lerp(FontWeight.w400, FontWeight.w500, 0.5),
  );

  // Main title: "Please Select Option"
  static final TextStyle title = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.lerp(FontWeight.w400, FontWeight.w500, 0.5),
    letterSpacing: -0.30,
  );

  // Bottom sheet error message
  static const TextStyle errorText = TextStyle(
    fontSize: 12.5,
    color: Colors.red,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
  );

  // Bottom sheet primary button text: "continue"
  static const TextStyle continueButtonText = TextStyle(
    fontSize: 14.5,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  // Bottom sheet header title text
  static const TextStyle sheetTitle = TextStyle(
      fontSize: 18,
      fontFamily: AppConstants.defaultFontFamily,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      height: 1.56);

  // Field label text: "enter mobile number" etc.
  static const TextStyle fieldLabel = TextStyle(
      fontSize: 14,
      fontFamily: AppConstants.defaultFontFamily,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      height: 1.43);

  // Country dial code text inside picker box
  static const TextStyle dialCode = TextStyle(
      fontSize: 14,
      fontFamily: AppConstants.defaultFontFamily,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      height: 1.43);

  // Phone input hint text
  static const TextStyle phoneHint = TextStyle(
      color: Color(0xFFB7B7B7),
      fontSize: 14,
      fontFamily: AppConstants.defaultFontFamily,
      fontWeight: FontWeight.w400,
      height: 1.43);

  // Phone input text
  static const TextStyle phoneInput = TextStyle(
      fontSize: 14,
      fontFamily: AppConstants.defaultFontFamily,
      fontWeight: FontWeight.w500,
      color: Colors.black,
      height: 1.43);

  // Country flag emoji text
  static const TextStyle flagEmoji = TextStyle(
    fontSize: 18,
    fontFamily: AppConstants.defaultFontFamily,
  );

  // -----------------------------
  // Purchase Plan Bottom Sheet UI
  // -----------------------------

  // Bottom sheet modal barrier color (`showModalBottomSheet`).
  static const Color purchasePlanSheetBarrierColor = Color(0x59000000);

  // Keyboard inset animation config (`AnimatedPadding` in sheet container).
  static const Duration purchasePlanSheetKeyboardAnimationDuration =
      Duration(milliseconds: 180);
  static const Curve purchasePlanSheetKeyboardAnimationCurve = Curves.easeOut;

  // Additional entrance animation config (`FadeTransition` + `SlideTransition`).
  static const Curve purchasePlanSheetEntranceCurve = Curves.easeOutCubic;
  static const Offset purchasePlanSheetEntranceBeginOffset = Offset(0, 0.12);

  // Main sheet container styling (`Container` wrapping `_SheetBody`).
  static const EdgeInsets purchasePlanSheetContentPadding =
      EdgeInsets.fromLTRB(16, 24, 16, 24);
  static const Color purchasePlanSheetBackgroundColor = Colors.white;
  static const double purchasePlanSheetTopCornerRadius = 22;

  // Placeholder loader area when bloc state is not ready (`_SheetBody`).
  static const double purchasePlanSheetLoadingHeight = 180;

  // Vertical spacing between sections in `_SheetBody`.
  static const double purchasePlanSectionGap = 20;
  static const double purchasePlanLabelToFieldGap = 10;
  static const double purchasePlanErrorBottomPadding = 10;

  // Continue button container + shape.
  static const double purchasePlanContinueButtonHeight = 50;
  static const double purchasePlanContinueButtonRadius = 100;
  static final Color purchasePlanContinueButtonColor =
      HexColor.fromHex('#645D9C');

  // Header back icon touch area + icon size.
  static const double purchasePlanHeaderBackTapRadius = 22;
  static const double purchasePlanHeaderBackIconSize = 24;
  static const double purchasePlanHeaderBackToTitleGap = 8;

  // Country picker + phone input shared field values.
  static final Color purchasePlanFieldBorderColor = HexColor.fromHex('#E3E3E3');
  static const double purchasePlanFieldBorderWidth = 1;
  static const double purchasePlanFieldCornerRadius = 10;
  static const Color purchasePlanFieldBackgroundColor = Colors.white;

  // Country picker box dimensions + inner spacing.
  static const double purchasePlanCountryPickerHeight = 52;
  static const double purchasePlanCountryPickerWidth = 96;
  // Left inner padding before the flag icon.
  static const double purchasePlanCountryPickerLeftPadding = 10;
  // Right inner padding when dropdown arrow is visible.
  static const double purchasePlanCountryPickerRightPaddingWithArrow = 6;
  // Right inner padding when dropdown arrow is hidden.
  static const double purchasePlanCountryPickerRightPaddingWithoutArrow = 16;
  // Exact country flag rendering size in picker.
  static const double purchasePlanCountryFlagWidth = 26;
  static const double purchasePlanCountryFlagHeight = 20;
  static const double purchasePlanCountryPickerToInputGap = 10;
  // Gap between flag and country dial code ("1").
  static const double purchasePlanCountryFlagToDialGap = 5;
  // Gap between dial code and dropdown arrow.
  static const double purchasePlanCountryDialToArrowGap = 2;

  // Country picker dropdown arrow icon style.
  static const double purchasePlanCountryArrowIconSize = 16;
  static final Color purchasePlanCountryArrowIconColor = HexColor.fromHex('#9E9E9E');

  // Phone input field dimensions + inner spacing.
  static const double purchasePlanPhoneInputHeight = 52;
  static const double purchasePlanPhoneInputHorizontalPadding = 20;
}
