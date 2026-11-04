import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/bahamas_phone_input_formatter.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
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
    this.showError = false,
    this.errorText,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enableCountryPicker;
  final bool showError;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  static const LinearGradient _defaultFocusedGradient = LinearGradient(
    colors: [Color(0xFF645D9C), Color(0xFFE5097F), Color(0xFFF9A01B)],
  );

  static const LinearGradient _errorFocusedGradient = LinearGradient(
    colors: [GiftDataTheme.errorRed, GiftDataTheme.errorRed],
  );

  @override
  Widget build(BuildContext context) {
    final Color borderColor = showError
        ? GiftDataTheme.errorRed
        : Colors.transparent;
    final TextStyle inputStyle = showError
        ? const TextStyle(
            color: GiftDataTheme.errorRed,
            fontSize: 16,
            fontFamily: AppConstants.defaultFontFamily,
          )
        : const TextStyle(
            color: GiftDataTheme.textPrimary,
            fontSize: 16,
            fontFamily: AppConstants.defaultFontFamily,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomCountryPhoneInputRow(
          hintText: 'eg: (242)-899-9999',
          flagEmoji: '🇧🇸',
          dialCode: '1',
          countryIsoCode: 'BS',
          controller: controller,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          enableCountryPicker: enableCountryPicker,
          showCountryArrow: false,
          keyboardType: TextInputType.phone,
          // Presentation-only formatter — API clients re-strip to digits.
          inputFormatters: const [BahamasPhoneInputFormatter()],
          onChanged: onChanged,
          unfocusedBorderColor: borderColor,
          hideUnfocusedInputBorder: !showError,
          focusedBorderGradient: showError
              ? _errorFocusedGradient
              : _defaultFocusedGradient,
          phoneInputStyle: inputStyle,
          backgroundColor: GiftDataTheme.fieldBg,
          borderRadius: GiftDataTheme.fieldRadius,
          fieldHeight: GiftDataTheme.fieldHeight,
        ),
        if (showError && (errorText ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(
              left: GiftDataTheme.countryPickerWidth + 10,
            ),
            child: Text(errorText!, style: GiftDataTheme.inlineError),
          ),
        ],
      ],
    );
  }
}
