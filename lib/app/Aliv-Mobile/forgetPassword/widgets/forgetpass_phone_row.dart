import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import '../theme/forget_password_theme.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_event.dart';

class ForgetPasswordPhoneRow extends StatefulWidget {
  const ForgetPasswordPhoneRow({super.key});

  @override
  State<ForgetPasswordPhoneRow> createState() => _LoginPhoneRowState();
}

class _LoginPhoneRowState extends State<ForgetPasswordPhoneRow> {
  Country? _selectedCountry;

  String get _flagEmoji =>
      _selectedCountry?.flagEmoji ?? '🇧🇸'; // Bahamas default

  String get _dialCode {
    final raw = _selectedCountry?.phoneCode ?? '1';
    // Handles both "1-242" and "1 242" forms and keeps first non-empty segment.
    final normalized = raw.replaceAll('-', ' ');
    return normalized
        .split(' ')
        .firstWhere((part) => part.trim().isNotEmpty, orElse: () => '1');
  }

  /* PARKED: country picker disabled to match Login screen behavior.
     Keep this opener around for an easy revert if multi-country
     support is restored later.

  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return CustomCountryPhoneInputRow(
      hintText: 'eg: 242-899-9999',
      flagEmoji: _flagEmoji,
      dialCode: _dialCode,
      countryIsoCode: _selectedCountry?.countryCode ?? 'BS',
      enableCountryPicker: false,
      onChanged: (value) => context
          .read<ForgetPasswordBloc>()
          .add(ForgetPasswordPhoneChanged(value)),
      backgroundColor: ForgetPasswordColors.pageBackground,
      unfocusedBorderColor: ForgetPasswordColors.fieldBorder,
      focusedBorderGradient: ForgetPasswordGradients.focusedInputBorder,
      borderRadius: ForgetPasswordSizes.fieldRadius,
      borderWidth: ForgetPasswordSizes.fieldBorderWidth,
      fieldHeight: ForgetPasswordSizes.fieldHeight,
      countryPickerWidth: ForgetPasswordSizes.countryWidth,
      countryToPhoneGap: ForgetPasswordSizes.countryToPhoneGap,
      countryPickerPadding: ForgetPasswordPaddings.countryHorizontal8,
      showCountryPickerBorder: true,
      countryPickerBorderColor: ForgetPasswordColors.fieldBorder,
      countryPickerBorderWidth: ForgetPasswordSizes.fieldBorderWidth,
      phoneInputPadding: ForgetPasswordPaddings.fieldHorizontal14,
      countryFlagToDialGap: ForgetPasswordSizes.countryFlagToCodeGap,
      countryDialToArrowGap: ForgetPasswordSizes.countryCodeToArrowGap,
      countryArrowIconSize: ForgetPasswordSizes.countryArrowSize,
      //countryArrowWidth: 19,
      //countryArrowHeight: 12,
      countryArrowColor: ForgetPasswordColors.hintGrey,
      flagStyle: ForgetPasswordTheme.countryFlag,
      dialCodeStyle: ForgetPasswordTheme.dialCode,
      phoneInputStyle: ForgetPasswordTheme.phoneInput,
      phoneHintStyle: ForgetPasswordTheme.phoneHint,
    );
  }
}
