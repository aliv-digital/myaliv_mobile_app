import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class GuestPayBillTheme {
  // ===== Screen strings =====
  // Used by: `DefaultAppBar` title in `pay-bills/view/guest_pay_bill_screen.dart`.
  static const String appBarTitle = 'pay bills';

  // Used by: `GuestPayBillRequiredLabel` above service dropdown.
  static const String selectServiceLabel = 'select service';

  // Used by: helper `Text` below service dropdown in `guest_pay_bill_screen.dart`.
  static const String selectServiceHelperText =
      'please select a service to complete the bill pay transaction';

  // Used by: label above first phone field for ALIV Postpaid flow.
  static const String mobileNumberLabel = 'mobile number';

  // Used by: label above confirm phone field for ALIV Postpaid flow.
  static const String confirmMobileNumberLabel = 'confirm mobile number';

  // Used by: phone `TextField` hint and inline verify hint.
  static const String phoneHintText = 'eg: 2428999999';

  // Used by: label above name field for REV / ALIVFibr flow.
  static const String nameLabel = 'name';

  // Used by: name inline verify field hint.
  static const String nameHintText = 'enter name';

  // Used by: label above account status read-only box.
  static const String accountStatusLabel = 'account status';

  // Used by: label above account balance value in non-postpaid flow.
  static const String accountBalanceLabel = 'amount due';

  // Used by: label above amount input field.
  static const String customAmountLabel = 'enter a custom amount';

  // Used by: amount input hint in `fieldDecoration`.
  static const String amountHintText = r'$ 0.00';

  // Used by: fallback text when status/balance is not available.
  static const String statusPlaceholderText = '------';

  // Used by: success snackbar after submit event.
  static const String submitSuccessMessage = 'Payment submitted';

  // ===== Screen spacing =====
  // Used by: top content padding after app bar in `guest_pay_bill_screen.dart`.
  static const double contentTopGapAfterAppBar = 32;

  // Used by: left/right content padding for entire form body.
  static const double contentHorizontalPadding = 24;

  // Used by: scroll content bottom padding.
  static const double contentBottomPadding = 18;

  // Used by: vertical gap between each label and corresponding field.
  static const double labelToFieldGap = 8;

  // Used by: general section separation inside the form.
  static const double sectionGap = 16;

  // Used by: horizontal gap between country picker and input field.
  static const double countryPickerToInputGap = 10;

  // Used by: top margin before primary submit button.
  static const double submitTopGap = 40;

  // Used by: custom amount prefix `$` left inset.
  static const double amountPrefixLeftPadding = 14;

  // Used by: custom amount prefix `$` right inset.
  static const double amountPrefixRightPadding = 6;

  // ===== Colors =====
  // Used by: app bar background and primary action backgrounds.
  static const Color primary = Color(0xFF5A5796);

  // Used by: submit action buttons (inline verify submit + bottom submit).
  static const Color submitButtonColor = Color(0xFF645D9C);

  // Used by: entire screen background.
  static const Color pageBg = Colors.white;

  // Used by: all input/select/read-only field container backgrounds.
  static const Color fieldBg = Color(0xFFF1F1F8);

  // Used by: service helper text color.
  static const Color helperText = Color(0xFF2E57E8);

  // Used by: field labels shown before each input.
  static const Color labelText = Color(0xFF1C1C1C);

  // Requested input hint color for all form fields.
  static const Color inputHintTextColor = Color(0xFF667085);

  // Requested input value color for all form fields.
  static const Color inputTextColor = Color(0xFF344054);

  // Backward-compatible alias used by existing widgets.
  static const Color placeholder = inputHintTextColor;

  // Used by: all `OutlineInputBorder` states (transparent border look).
  static const Color border = Color(0x00000000);

  // Used by: unfocused stroke in gradient-focus wrappers around editable fields.
  static const Color unfocusedInputBorderColor = Color(0xFFE0E0E0);

  // Used by: focused gradient border palette (copied from login behavior).
  static const Color focusedInputBorderYellow = Color(0xFFFFC627);
  static const Color focusedInputBorderBlue = Color(0xFF00B3E3);
  static const Color focusedInputBorderPurple = Color(0xFF4B298C);
  static const Color focusedInputBorderPink = Color(0xFFFF9BB1);
  static const Color focusedInputBorderOrange = Color(0xFFFF6C36);

  // Used by: disabled submit button background.
  static const Color disabledBtn = Color(0xFFCDCDDD);

  // Used by: text/icons shown over primary background.
  static const Color chipTextOnPrimary = Colors.white;

  // Used by: common field corner radius across dropdown/input/read-only widgets.
  static const double radius = 10;

  // Used by: focused/unfocused wrapper stroke width around editable fields.
  static const double inputFocusBorderWidth = 1;

  // Used by: fixed container height inside inline verify field.
  static const double inlineVerifyFieldHeight = 50;

  // Used by: account balance value text in `guest_pay_bill_screen.dart`.
  static TextStyle accountBalanceValueStyle = const TextStyle(
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: Color(0xFF344054),
  );

  // Used by: `$` prefix text inside custom amount field.
  static const TextStyle amountPrefixStyle = TextStyle(
    fontSize: 13,
    fontFamily: AppConstants.defaultFontFamily,
    fontWeight: FontWeight.w600,
    color: GuestPayBillTheme.labelText,
  );

  // Shared hint style for every editable form field in pay-bills flow.
  // Note: Figma uses w450, but Flutter supports 100-step weights only.
  // `FontWeight.w400` is the closest supported option.
  static const TextStyle inputHintTextStyle = TextStyle(
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: inputHintTextColor,
  );

  // Shared input value style for every editable form field in pay-bills flow.
  // Note: Figma uses w450, but Flutter supports 100-step weights only.
  // `FontWeight.w400` is the closest supported option.
  static const TextStyle inputTextStyle = TextStyle(
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: inputTextColor,
  );

  // Used by: all snackbar messages in this module screen.
  static const TextStyle snackBarTextStyle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
  );

  // Shared label style for all labels displayed before fields.
  static const TextStyle fieldLabelTextStyle = TextStyle(
    color: Color(0xFF1C1C1C),
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
    height: 1.43,
  );

  // Used by: all section labels and required labels.
  // Linked widgets:
  // - `GuestPayBillRequiredLabel`
  // - labels in `guest_pay_bill_screen.dart` (mobile number, account status, etc.)
  static TextStyle labelStyle() => fieldLabelTextStyle;

  // Used by: helper message under service dropdown.
  static TextStyle helperStyle() => const TextStyle(
        fontSize: 11,
        fontFamily: AppConstants.defaultFontFamily,
        // Figma uses w450; closest Flutter-supported weight is w400.
        fontWeight: FontWeight.w400,
        height: 1.82,
        color: Color(0xFF707070),
      );

  // Shared input decoration for standard text fields in this module.
  // Linked widgets/locations:
  // - service-specific mobile/account/amount `TextField`s in `guest_pay_bill_screen.dart`
  // - supports optional `prefix` (`$`) and `suffix` widgets.
  static InputDecoration fieldDecoration({
    required String hint,
    Widget? suffix,
    Widget? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: inputHintTextStyle,
      filled: true,
      fillColor: fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: border),
      ),
      suffixIcon: suffix,
      prefixIcon: prefix,
    );
  }

  // Used by: focused editable input wrappers to match login gradient behavior.
  static const LinearGradient focusedInputBorderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      focusedInputBorderYellow,
      focusedInputBorderBlue,
      focusedInputBorderPurple,
      focusedInputBorderPink,
      focusedInputBorderOrange,
    ],
  );
}
