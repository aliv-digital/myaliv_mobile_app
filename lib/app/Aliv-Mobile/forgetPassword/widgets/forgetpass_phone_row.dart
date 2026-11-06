import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';
import '../theme/forget_password_theme.dart';
import '../../login/theme/login_theme.dart';
import '../../login/model/login_country_selection.dart';
import '../../login/utils/login_phone_number_helper.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_event.dart';

class ForgetPasswordPhoneRow extends StatefulWidget {
  const ForgetPasswordPhoneRow({super.key, required this.focusNode});

  final FocusNode focusNode;

  @override
  State<ForgetPasswordPhoneRow> createState() => _LoginPhoneRowState();
}

class _LoginPhoneRowState extends State<ForgetPasswordPhoneRow> {
  final LoginPhoneNumberHelper _phoneNumberHelper =
      const LoginPhoneNumberHelper(requireBahamasAreaCode: true);
  bool _hasPhoneFocus = false;
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _hasPhoneFocus = widget.focusNode.hasFocus;
    widget.focusNode.addListener(_handlePhoneFocusChange);
  }

  @override
  void didUpdateWidget(covariant ForgetPasswordPhoneRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handlePhoneFocusChange);
      widget.focusNode.addListener(_handlePhoneFocusChange);
      _hasPhoneFocus = widget.focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handlePhoneFocusChange);
    super.dispose();
  }

  void _handlePhoneFocusChange() {
    if (_hasPhoneFocus == widget.focusNode.hasFocus) {
      return;
    }

    setState(() {
      _hasPhoneFocus = widget.focusNode.hasFocus;
    });
  }

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
    final showLivePhoneValidationError = context.select(
      (ForgetPasswordBloc bloc) => _phoneNumberHelper.hasLiveValidationError(
        rawPhoneNumber: bloc.state.phone,
        selectedCountry: LoginCountrySelection.defaultBahamas,
      ),
    );
    final bool showPhoneBorderError = showLivePhoneValidationError;
    final Color phoneBorderColor = showPhoneBorderError
        ? AuthModuleColors.errorRed
        : ForgetPasswordColors.fieldBorder;
    final TextStyle phoneInputStyle = showLivePhoneValidationError
        ? ForgetPasswordTheme.phoneInput.copyWith(
            color: AuthModuleColors.errorRed,
          )
        : ForgetPasswordTheme.phoneInput;
    final double phoneErrorLeftPadding =
        ForgetPasswordSizes.countryWidth +
        ForgetPasswordSizes.countryToPhoneGap +
        ForgetPasswordPaddings.fieldHorizontal14.left;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomCountryPhoneInputRow(
          focusNode: widget.focusNode,
          hintText: 'eg: (242)-899-9999',
          flagEmoji: _flagEmoji,
          dialCode: _dialCode,
          countryIsoCode: _selectedCountry?.countryCode ?? 'BS',
          enableCountryPicker: false,
          inputFormatters: const [BahamasPhoneInputFormatter()],
          onChanged: (value) => context.read<ForgetPasswordBloc>().add(
            ForgetPasswordPhoneChanged(value),
          ),
          backgroundColor: ForgetPasswordColors.pageBackground,
          unfocusedBorderColor: phoneBorderColor,
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
          phoneInputStyle: phoneInputStyle,
          phoneHintStyle: ForgetPasswordTheme.phoneHint,
        ),
        if (showLivePhoneValidationError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: phoneErrorLeftPadding),
            child: const Text(
              'invalid Format',
              style: AuthModuleTextStyles.invalidCredentials,
            ),
          ),
        ],
      ],
    );
  }
}
