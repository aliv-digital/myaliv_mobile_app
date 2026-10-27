import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';

/// Bahamas phone input used twice in the gift-data form (recipient + confirm).
/// Wraps `CustomCountryPhoneInputRow` with the gift-data preset — hardcoded
/// BS country, no live arrow, same `BahamasPhoneInputFormatter` as the login
/// row so the formatted value matches `(XXX)-XXX-XXXX` on screen.
class RecipientPhoneField extends StatelessWidget {
  const RecipientPhoneField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.enableCountryPicker = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enableCountryPicker;

  @override
  Widget build(BuildContext context) {
    return CustomCountryPhoneInputRow(
      hintText: 'eg: (242)-899-9999',
      flagEmoji: '🇧🇸',
      dialCode: '1',
      countryIsoCode: 'BS',
      controller: controller,
      enableCountryPicker: enableCountryPicker,
      showCountryArrow: false,
      keyboardType: TextInputType.phone,
      // Presentation-only formatter — API clients re-strip to digits.
      inputFormatters: const [BahamasPhoneInputFormatter()],
      onChanged: onChanged,
    );
  }
}
