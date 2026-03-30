import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../theme/login_theme.dart';
import '../utils/login_phone_number_helper.dart';

class LoginPhoneRow extends StatelessWidget {
  const LoginPhoneRow({super.key});

  void _openCountryPicker(BuildContext context) {
    final LoginPhoneNumberHelper phoneNumberHelper =
        const LoginPhoneNumberHelper();

    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        context.read<LoginBloc>().add(
              LoginCountryChanged(
                phoneNumberHelper.selectionFromCountry(country),
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final phoneBorderColor = state.phoneFieldError
            ? AuthModuleColors.errorRed
            : AuthModuleColors.loginFieldBorderColor;

        return CustomCountryPhoneInputRow(
          hideUnfocusedInputBorder: false,
          hintText: 'eg: 242-899-9999',
          flagEmoji: state.selectedCountry.flagEmoji,
          dialCode: state.selectedCountry.dialCode,
          countryIsoCode: state.selectedCountry.isoCode,
          onTapCountryPicker: () => _openCountryPicker(context),
          onChanged: (value) =>
              context.read<LoginBloc>().add(LoginPhoneChanged(value)),
          backgroundColor: AuthModuleColors.pageBackground,
          unfocusedBorderColor: phoneBorderColor,
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
      },
    );
  }
}
