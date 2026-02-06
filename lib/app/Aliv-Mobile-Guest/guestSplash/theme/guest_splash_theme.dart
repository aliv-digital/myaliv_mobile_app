import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class GuestSplashTheme {
  // Main title: "Please Select Option"
  static const TextStyle title = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
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
  );

  // Field label text: "enter mobile number" etc.
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // Country dial code text inside picker box
  static const TextStyle dialCode = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // Phone input hint text
  static const TextStyle phoneHint = TextStyle(
    color: Color(0xFFB7B7B7),
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w400,
  );

  // Phone input text
  static const TextStyle phoneInput = TextStyle(
    fontSize: 14,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  // Country flag emoji text
  static const TextStyle flagEmoji = TextStyle(
    fontSize: 18,
    fontFamily: AppConstants.defaultFontFamily,
  );
}
