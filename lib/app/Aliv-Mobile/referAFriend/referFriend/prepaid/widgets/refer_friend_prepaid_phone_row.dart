import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';

import '../bloc/refer_friend_prepaid_bloc.dart';
import '../bloc/refer_friend_prepaid_event.dart';
import '../bloc/refer_friend_prepaid_state.dart';
import '../theme/refer_friend_prepaid_theme.dart';

class ReferFriendPrepaidPhoneRow extends StatefulWidget {
  const ReferFriendPrepaidPhoneRow({super.key});

  @override
  State<ReferFriendPrepaidPhoneRow> createState() =>
      _ReferFriendPrepaidPhoneRowState();
}

class _ReferFriendPrepaidPhoneRowState
    extends State<ReferFriendPrepaidPhoneRow> {
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

  /* PARKED: country picker disabled to match Login screen behavior.
     Keep this opener around for an easy revert if multi-country
     support is restored later.

  void _openCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        context.read<ReferFriendPrepaidBloc>().add(
          ReferFriendPrepaidCountryChanged(
            _phoneNumberHelper.selectionFromCountry(country),
          ),
        );
      },
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
      buildWhen: (previous, current) =>
          previous.friendPhone != current.friendPhone ||
          previous.selectedCountry != current.selectedCountry ||
          previous.friendPhoneFieldError != current.friendPhoneFieldError,
      builder: (context, state) {
        final bool isBahamasSelected = state.selectedCountry.isoCode == 'BS';
        final bool showLivePhoneValidationError = _phoneNumberHelper
            .hasLiveValidationError(
              rawPhoneNumber: state.friendPhone,
              selectedCountry: state.selectedCountry,
            );
        final bool showPhoneBorderError =
            state.friendPhoneFieldError || showLivePhoneValidationError;
        final Color phoneBorderColor = !_hasPhoneFocus && showPhoneBorderError
            ? ReferFriendPrepaidTheme.error
            : ReferFriendPrepaidTheme.border;
        final TextStyle phoneInputStyle = showLivePhoneValidationError
            ? ReferFriendPrepaidTheme.fieldInput.copyWith(
                color: ReferFriendPrepaidTheme.error,
              )
            : ReferFriendPrepaidTheme.fieldInput;
        final double phoneErrorLeftPadding =
            ReferFriendPrepaidTheme.countryWidth +
            ReferFriendPrepaidTheme.countryToPhoneGap +
            ReferFriendPrepaidTheme.fieldHorizontalPadding;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCountryPhoneInputRow(
              labelText: "friend’s number",
              focusNode: _phoneFocusNode,
              hideUnfocusedInputBorder: !showPhoneBorderError,
              hintText: isBahamasSelected
                  ? '(242) 345-4356'
                  : 'eg: 242-899-9999',
              flagEmoji: state.selectedCountry.flagEmoji,
              dialCode: state.selectedCountry.dialCode,
              countryIsoCode: state.selectedCountry.isoCode,
              enableCountryPicker: false,
              onChanged: (value) => context.read<ReferFriendPrepaidBloc>().add(
                ReferFriendPrepaidFriendPhoneChanged(value),
              ),
              // Bahamas keeps the same presentation-only formatter as login.
              inputFormatters: isBahamasSelected
                  ? const [BahamasPhoneInputFormatter()]
                  : null,
              backgroundColor: ReferFriendPrepaidTheme.fieldBg,
              unfocusedBorderColor: phoneBorderColor,
              focusedBorderGradient:
                  ReferFriendPrepaidTheme.focusedInputBorderGradient,
              borderRadius: ReferFriendPrepaidTheme.fieldRadius,
              borderWidth: ReferFriendPrepaidTheme.fieldBorderWidth,
              fieldHeight: ReferFriendPrepaidTheme.fieldHeight,
              countryPickerWidth: ReferFriendPrepaidTheme.countryWidth,
              countryToPhoneGap: ReferFriendPrepaidTheme.countryToPhoneGap,
              countryPickerPadding: const EdgeInsets.symmetric(
                horizontal:
                    ReferFriendPrepaidTheme.countryPickerHorizontalPadding,
              ),
              showCountryPickerBorder: true,
              countryPickerBorderColor: ReferFriendPrepaidTheme.border,
              countryPickerBorderWidth:
                  ReferFriendPrepaidTheme.fieldBorderWidth,
              phoneInputPadding: const EdgeInsets.symmetric(
                horizontal: ReferFriendPrepaidTheme.fieldHorizontalPadding,
              ),
              countryFlagToDialGap:
                  ReferFriendPrepaidTheme.countryFlagToCodeGap,
              countryDialToArrowGap:
                  ReferFriendPrepaidTheme.countryCodeToArrowGap,
              countryArrowIconSize: ReferFriendPrepaidTheme.countryArrowSize,
              countryArrowColor:
                  ReferFriendPrepaidTheme.fieldHint.color ?? Colors.grey,
              flagStyle: ReferFriendPrepaidTheme.countryFlag,
              dialCodeStyle: ReferFriendPrepaidTheme.countryCode,
              phoneInputStyle: phoneInputStyle,
              phoneHintStyle: ReferFriendPrepaidTheme.fieldHint,
              labelStyle: ReferFriendPrepaidTheme.label,
            ),
            if (showLivePhoneValidationError) ...[
              const SizedBox(height: 6),
              // Keep the message aligned with the phone field, not the picker.
              Padding(
                padding: EdgeInsets.only(left: phoneErrorLeftPadding),
                child: const Text(
                  LoginPhoneNumberHelper.invalidPhoneNumberMessage,
                  style: ReferFriendPrepaidTheme.fieldError,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
