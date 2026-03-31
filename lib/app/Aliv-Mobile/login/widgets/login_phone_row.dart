import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../theme/login_theme.dart';
import '../utils/bahamas_phone_input_formatter.dart';
import '../utils/login_phone_number_helper.dart';

class LoginPhoneRow extends StatefulWidget {
  const LoginPhoneRow({super.key});

  @override
  State<LoginPhoneRow> createState() => _LoginPhoneRowState();
}

class _LoginPhoneRowState extends State<LoginPhoneRow> {
  final LoginPhoneNumberHelper _phoneNumberHelper =
      const LoginPhoneNumberHelper();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _hasPhoneFocus = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(_handlePhoneFocusChange);
  }

  @override
  void dispose() {
    _phoneFocusNode.removeListener(_handlePhoneFocusChange);
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _handlePhoneFocusChange() {
    if (_hasPhoneFocus == _phoneFocusNode.hasFocus) {
      return;
    }

    setState(() {
      _hasPhoneFocus = _phoneFocusNode.hasFocus;
    });
  }

  void _openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        context.read<LoginBloc>().add(
              LoginCountryChanged(
                _phoneNumberHelper.selectionFromCountry(country),
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final bool isBahamasSelected = state.selectedCountry.isoCode == 'BS';
        final bool showLivePhoneValidationError =
            _phoneNumberHelper.hasLiveValidationError(
          rawPhoneNumber: state.phone,
          selectedCountry: state.selectedCountry,
        );
        final bool showPhoneBorderError =
            state.phoneFieldError || showLivePhoneValidationError;
        final Color phoneBorderColor = !_hasPhoneFocus && showPhoneBorderError
            ? AuthModuleColors.errorRed
            : AuthModuleColors.loginFieldBorderColor;
        final TextStyle phoneInputStyle = showLivePhoneValidationError
            ? AuthModuleTextStyles.fieldValue.copyWith(
                color: AuthModuleColors.errorRed,
              )
            : AuthModuleTextStyles.fieldValue;
        final double phoneErrorLeftPadding = AuthModuleSizes.countryWidth +
            AuthModuleSizes.countryToPhoneGap +
            AuthModulePaddings.fieldHorizontal14.left;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCountryPhoneInputRow(
              focusNode: _phoneFocusNode,
              hideUnfocusedInputBorder: false,
              hintText:
                  isBahamasSelected ? '(242) 345-4356' : 'eg: 242-899-9999',
              flagEmoji: state.selectedCountry.flagEmoji,
              dialCode: state.selectedCountry.dialCode,
              countryIsoCode: state.selectedCountry.isoCode,
              onTapCountryPicker: () => _openCountryPicker(context),
              onChanged: (value) =>
                  context.read<LoginBloc>().add(LoginPhoneChanged(value)),
              // Bahamas gets a presentation-only formatter in the field.
              inputFormatters: isBahamasSelected
                  ? const [BahamasPhoneInputFormatter()]
                  : null,
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
              phoneInputStyle: phoneInputStyle,
              phoneHintStyle: AuthModuleTextStyles.fieldHint,
            ),
            if (showLivePhoneValidationError) ...[
              const SizedBox(height: 6),
              // Align the inline error with the phone text input, not the picker.
              Padding(
                padding: EdgeInsets.only(left: phoneErrorLeftPadding),
                child: const Text(
                  LoginPhoneNumberHelper.invalidPhoneNumberMessage,
                  style: AuthModuleTextStyles.invalidCredentials,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
