import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../theme/login_theme.dart';

class LoginPhoneRow extends StatefulWidget {
  const LoginPhoneRow({super.key});

  @override
  State<LoginPhoneRow> createState() => _LoginPhoneRowState();
}

class _LoginPhoneRowState extends State<LoginPhoneRow> {
  Country? _selectedCountry;

  String get _flagEmoji => _selectedCountry?.flagEmoji ?? '🇧🇸'; // Bahamas default

  String get _dialCode {
    final raw = _selectedCountry?.phoneCode ?? '1';
    // Handles both "1-242" and "1 242" forms and keeps first non-empty segment.
    final normalized = raw.replaceAll('-', ' ');
    return normalized.split(' ').firstWhere((part) => part.trim().isNotEmpty, orElse: () => '1');
  }

  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) {
        setState(() {
          _selectedCountry = country;
        });

        // চাইলে country bloc এ পাঠাতে পারো
        // context.read<LoginBloc>().add(LoginCountryChanged(country));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomCountryPhoneInputRow(
      
      hideUnfocusedInputBorder: false,
      hintText: 'eg: 242-899-9999',
      flagEmoji: _flagEmoji,
      dialCode: _dialCode,
      countryIsoCode: _selectedCountry?.countryCode ?? 'BS',
      onTapCountryPicker: _openCountryPicker,
      onChanged: (value) =>
          context.read<LoginBloc>().add(LoginPhoneChanged(value)),
      backgroundColor: AuthModuleColors.pageBackground,
      unfocusedBorderColor: AuthModuleColors.loginFieldBorderColor,
      borderRadius: AuthModuleSizes.fieldRadius,
      borderWidth: AuthModuleSizes.fieldBorderWidth,
      fieldHeight: AuthModuleSizes.fieldHeight,
      countryPickerWidth: AuthModuleSizes.countryWidth,
      countryToPhoneGap: AuthModuleSizes.countryToPhoneGap,
      countryPickerPadding: AuthModulePaddings.countryHorizontal8,
      showCountryPickerBorder: true,
      countryPickerBorderColor: AuthModuleColors.loginFieldBorderColor,
      countryPickerBorderWidth: AuthModuleSizes.fieldBorderWidth,
      phoneInputPadding: AuthModulePaddings.fieldHorizontal14,
      countryFlagToDialGap: AuthModuleSizes.countryFlagToCodeGap,
      countryDialToArrowGap: AuthModuleSizes.countryCodeToArrowGap,
      countryArrowIconSize: AuthModuleSizes.countryArrowSize,
      countryArrowColor: AuthModuleColors.hintGrey,
      flagStyle: AuthModuleTextStyles.countryFlag,
      dialCodeStyle: AuthModuleTextStyles.countryCode,
      phoneInputStyle: AuthModuleTextStyles.fieldValue,
      phoneHintStyle: AuthModuleTextStyles.fieldHint,
    );
  }
}
