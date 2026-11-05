import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/theme/login_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';

import '../../theme/top_up_prepaid_number_postpaid_theme.dart';

class TopUpPrepaidNumberPostPaidConfirmNumberSection extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool hasMismatchError;
  final bool hasFormatError;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;

  const TopUpPrepaidNumberPostPaidConfirmNumberSection({
    super.key,
    required this.value,
    required this.onChanged,
    this.hasMismatchError = false,
    this.hasFormatError = false,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<TopUpPrepaidNumberPostPaidConfirmNumberSection> createState() =>
      _TopUpPrepaidNumberPostPaidConfirmNumberSectionState();
}

class _TopUpPrepaidNumberPostPaidConfirmNumberSectionState
    extends State<TopUpPrepaidNumberPostPaidConfirmNumberSection> {
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());
  bool _hasPhoneFocus = false;

  @override
  void initState() {
    super.initState();
    _hasPhoneFocus = _effectiveFocusNode.hasFocus;
    _effectiveFocusNode.addListener(_handlePhoneFocusChange);
  }

  @override
  void didUpdateWidget(
    covariant TopUpPrepaidNumberPostPaidConfirmNumberSection oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(
        _handlePhoneFocusChange,
      );
      _effectiveFocusNode.addListener(_handlePhoneFocusChange);
      _hasPhoneFocus = _effectiveFocusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    (widget.focusNode ?? _internalFocusNode)?.removeListener(
      _handlePhoneFocusChange,
    );
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handlePhoneFocusChange() {
    if (_hasPhoneFocus == _effectiveFocusNode.hasFocus) return;
    setState(() => _hasPhoneFocus = _effectiveFocusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    const selectedCountry = LoginCountrySelection.defaultBahamas;
    final String? errorMessage = widget.hasFormatError
        ? 'invalid Format'
        : (widget.hasMismatchError ? 'phone numbers do not match' : null);
    final showError = errorMessage != null;
    final phoneBorderColor = !_hasPhoneFocus && showError
        ? AuthModuleColors.errorRed
        : Colors.transparent;
    final phoneInputStyle = showError
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
          focusNode: _effectiveFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: widget.onSubmitted,
          hideUnfocusedInputBorder: !_hasPhoneFocus && !showError,
          hintText: 'eg: (242)-899-9999',
          flagEmoji: selectedCountry.flagEmoji,
          dialCode: selectedCountry.dialCode,
          countryIsoCode: selectedCountry.isoCode,
          showCountryPickerBox: false,
          enableCountryPicker: false,
          onChanged: widget.onChanged,
          inputFormatters: const [BahamasPhoneInputFormatter()],
          backgroundColor: TopUpPrepaidNumberPostPaidTheme.fieldBg,
          unfocusedBorderColor: phoneBorderColor,
          borderRadius: TopUpPrepaidNumberPostPaidTheme.radius,
          borderWidth: AuthModuleSizes.fieldBorderWidth,
          fieldHeight: AuthModuleSizes.fieldHeight,
          countryPickerWidth: AuthModuleSizes.countryWidth,
          countryToPhoneGap: AuthModuleSizes.countryToPhoneGap,
          countryPickerPadding: AuthModulePaddings.countryHorizontal8,
          showCountryPickerBorder: false,
          countryPickerBorderColor: Colors.transparent,
          countryPickerBorderWidth: 0,
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
        if (showError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: phoneErrorLeftPadding),
            child: Text(
              errorMessage!,
              style: AuthModuleTextStyles.invalidCredentials,
            ),
          ),
        ],
      ],
    );
  }
}
