import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';

import '../theme/guest_splash_theme.dart';

/// Guest splash wrapper around `CustomCountryPhoneInputRow`.
///
/// Keeps all guest-splash-specific sizing/colors/styles in one place so the
/// bottom-sheet screen stays clean.
class PhoneRow extends StatelessWidget {
  const PhoneRow({
    super.key,
    required this.country,
    required this.hintText,
    required this.onChanged,
    this.onTapCountryPicker,
    this.enableCountryPicker = false,
    this.showCountryArrow = true,
  });

  final Country? country;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onTapCountryPicker;
  final bool enableCountryPicker;
  final bool showCountryArrow;

  @override
  Widget build(BuildContext context) {
    return CustomCountryPhoneInputRow(
      hintText: hintText,
      flagEmoji: country?.flagEmoji ?? '🏳️',
      dialCode: country?.phoneCode ?? '1',
      countryIsoCode: country?.countryCode,
      onTapCountryPicker: onTapCountryPicker,
      onChanged: onChanged,
      enableCountryPicker: enableCountryPicker,
      showCountryArrow: showCountryArrow,
      fieldHeight: GuestSplashTheme.purchasePlanPhoneInputHeight,
      countryPickerWidth: GuestSplashTheme.purchasePlanCountryPickerWidth,
      countryToPhoneGap: GuestSplashTheme.purchasePlanCountryPickerToInputGap,
      borderRadius: GuestSplashTheme.purchasePlanFieldCornerRadius,
      borderWidth: GuestSplashTheme.purchasePlanFieldBorderWidth,
      countryPickerPadding: EdgeInsets.only(
        left: GuestSplashTheme.purchasePlanCountryPickerLeftPadding,
        right: showCountryArrow
            ? GuestSplashTheme.purchasePlanCountryPickerRightPaddingWithArrow
            : GuestSplashTheme
                .purchasePlanCountryPickerRightPaddingWithoutArrow,
      ),
      showCountryPickerBorder: true,
      countryPickerBorderColor: GuestSplashTheme.purchasePlanFieldBorderColor,
      countryPickerBorderWidth: GuestSplashTheme.purchasePlanFieldBorderWidth,
      phoneInputPadding: const EdgeInsets.symmetric(
        horizontal: GuestSplashTheme.purchasePlanPhoneInputHorizontalPadding,
      ),
      countryFlagToDialGap: GuestSplashTheme.purchasePlanCountryFlagToDialGap,
      countryDialToArrowGap: GuestSplashTheme.purchasePlanCountryDialToArrowGap,
      countryArrowIconSize: GuestSplashTheme.purchasePlanCountryArrowIconSize,
      countryArrowColor: GuestSplashTheme.purchasePlanCountryArrowIconColor,
      backgroundColor: GuestSplashTheme.purchasePlanFieldBackgroundColor,
      // Static border for picker, and input keeps focus-border behavior.
      unfocusedBorderColor: GuestSplashTheme.purchasePlanFieldBorderColor,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\- ]')),
      ],
      dialCodeStyle: GuestSplashTheme.dialCode,
      phoneInputStyle: GuestSplashTheme.phoneInput,
      phoneHintStyle: GuestSplashTheme.phoneHint,
      flagStyle: GuestSplashTheme.flagEmoji,
    );
  }
}
