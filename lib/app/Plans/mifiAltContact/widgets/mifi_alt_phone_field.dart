import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/theme/login_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';

class MifiAltPhoneField extends StatelessWidget {
  const MifiAltPhoneField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.country,
    required this.rawPhone,
    required this.hasFocus,
    required this.readOnly,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final LoginCountrySelection country;
  final String rawPhone;
  final bool hasFocus;
  final bool readOnly;
  final ValueChanged<String> onChanged;

  static const LoginPhoneNumberHelper _phoneHelper = LoginPhoneNumberHelper();

  @override
  Widget build(BuildContext context) {
    final bool showLiveError = _phoneHelper.hasLiveValidationError(
      rawPhoneNumber: rawPhone,
      selectedCountry: country,
    );
    final bool showBorderError = !hasFocus && showLiveError;
    final Color borderColor = showBorderError
        ? AuthModuleColors.errorRed
        : AuthModuleColors.loginFieldBorderColor;
    final TextStyle inputStyle = showLiveError
        ? AuthModuleTextStyles.fieldValue.copyWith(
            color: AuthModuleColors.errorRed,
          )
        : AuthModuleTextStyles.fieldValue;
    final bool isBahamas = country.isoCode == 'BS';
    final double errorLeftPad = AuthModuleSizes.countryWidth +
        AuthModuleSizes.countryToPhoneGap +
        AuthModulePaddings.fieldHorizontal14.left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCountryPhoneInputRow(
          controller: controller,
          focusNode: focusNode,
          hideUnfocusedInputBorder: false,
          hintText: 'eg: 242-899-9999',
          flagEmoji: country.flagEmoji,
          dialCode: country.dialCode,
          countryIsoCode: country.isoCode,
          enableCountryPicker: false,
          readOnly: readOnly,
          onChanged: onChanged,
          inputFormatters:
              isBahamas ? const [BahamasPhoneInputFormatter()] : null,
          backgroundColor: AuthModuleColors.pageBackground,
          unfocusedBorderColor: borderColor,
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
          phoneInputStyle: inputStyle,
          phoneHintStyle: AuthModuleTextStyles.fieldHint,
        ),
        if (showLiveError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: errorLeftPad),
            child: const Text(
              LoginPhoneNumberHelper.invalidPhoneNumberMessage,
              style: AuthModuleTextStyles.invalidCredentials,
            ),
          ),
        ],
      ],
    );
  }
}
