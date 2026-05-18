import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/theme/login_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';

import '../../theme/top_up_prepaid_number_postpaid_theme.dart';

class TopUpPrepaidNumberPostPaidConfirmNumberSection extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const TopUpPrepaidNumberPostPaidConfirmNumberSection({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TopUpPrepaidNumberPostPaidConfirmNumberSection> createState() =>
      _TopUpPrepaidNumberPostPaidConfirmNumberSectionState();
}

class _TopUpPrepaidNumberPostPaidConfirmNumberSectionState
    extends State<TopUpPrepaidNumberPostPaidConfirmNumberSection> {
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
    if (_hasPhoneFocus == _phoneFocusNode.hasFocus) return;
    setState(() => _hasPhoneFocus = _phoneFocusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    const selectedCountry = LoginCountrySelection.defaultBahamas;
    final showLivePhoneValidationError =
        _phoneNumberHelper.hasLiveValidationError(
      rawPhoneNumber: widget.value,
      selectedCountry: selectedCountry,
    );
    final phoneBorderColor = !_hasPhoneFocus && showLivePhoneValidationError
        ? AuthModuleColors.errorRed
        : AuthModuleColors.loginFieldBorderColor;
    final phoneInputStyle = showLivePhoneValidationError
        ? AuthModuleTextStyles.fieldValue.copyWith(
            color: AuthModuleColors.errorRed,
          )
        : AuthModuleTextStyles.fieldValue;
    final phoneErrorLeftPadding = AuthModulePaddings.fieldHorizontal14.left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'confirm number to top-up',
          style: TopUpPrepaidNumberPostPaidTheme.label(),
        ),
        const SizedBox(height: 8),
        CustomCountryPhoneInputRow(
          focusNode: _phoneFocusNode,
          hideUnfocusedInputBorder: false,
          hintText: 'eg: 242-899-9999',
          flagEmoji: selectedCountry.flagEmoji,
          dialCode: selectedCountry.dialCode,
          countryIsoCode: selectedCountry.isoCode,
          showCountryPickerBox: false,
          enableCountryPicker: false,
          onChanged: widget.onChanged,
          inputFormatters: const [BahamasPhoneInputFormatter()],
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
  }
}
