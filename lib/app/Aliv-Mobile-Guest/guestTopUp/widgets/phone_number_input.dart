// lib/features/guest_top_up/guest_top_up/widgets/labeled_input_field.dart
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';

class LabeledInputField extends StatelessWidget {
  const LabeledInputField({super.key,
    required this.label,
    required this.hintText,
    required this.onChanged,
    required this.country,
    required this.onPickCountry,
    this.enableCountryPicker = true,
  });

  final String label;
  final String hintText;
  final Function(String) onChanged;
  final CountryInfo country;
  final VoidCallback onPickCountry;
  final bool enableCountryPicker;

  @override
  static const double _fieldHeight = 54;
  static const double _fieldRadius = 8;
  static const double _countryWidth = 76;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GuestTopUpTheme.inputLabel,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: enableCountryPicker ? onPickCountry : null,
              borderRadius: BorderRadius.circular(_fieldRadius),
              child: Container(
                height: _fieldHeight,
                width: _countryWidth,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: GuestTopUpTheme.inputFieldBackgroundColor,
                  borderRadius: BorderRadius.circular(_fieldRadius),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(country.flagEmoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(country.dialCode, style: GuestTopUpTheme.dialCode),
                    if (enableCountryPicker) ...[
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Color(0xFFB0B0B5),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: _fieldHeight,
                decoration: BoxDecoration(
                  color: GuestTopUpTheme.inputFieldBackgroundColor,
                  borderRadius: BorderRadius.circular(_fieldRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: TextField(
                  style: GuestTopUpTheme.phoneInput,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    fillColor: GuestTopUpTheme.inputFieldBackgroundColor,
                    filled: true,
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: GuestTopUpTheme.phoneHint,
                    isCollapsed: true,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CountryInfo {
  final String flagEmoji;
  final String dialCode;

  const CountryInfo({
    required this.flagEmoji,
    required this.dialCode,
  });
}
