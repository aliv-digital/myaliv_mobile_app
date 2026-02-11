// lib/features/guest_top_up/guest_top_up/widgets/labeled_input_field.dart
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUp/theme/guest_topup_theme.dart';
import 'focused_input_border_wrapper.dart';

class LabeledInputField extends StatefulWidget {
  const LabeledInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.onChanged,
    required this.country,
    required this.onPickCountry,
    this.enableCountryPicker = true,
    this.labelStyle,
  });

  final String label;
  final String hintText;
  final Function(String) onChanged;
  final CountryInfo country;
  final VoidCallback onPickCountry;
  final bool enableCountryPicker;
  final TextStyle? labelStyle;

  @override
  State<LabeledInputField> createState() => _LabeledInputFieldState();
}

class _LabeledInputFieldState extends State<LabeledInputField> {
  final FocusNode _phoneFocusNode = FocusNode();
  bool _hasPhoneFocus = false;

  static const double _phoneFieldHeight = GuestTopUpTheme.phoneFieldHeight;
  static const double _countryPickerHeight =
      GuestTopUpTheme.countryPickerHeight;
  static const double _fieldRadius = GuestTopUpTheme.phoneFieldRadius;
  static const double _countryWidth = 76;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(_onPhoneFocusChanged);
  }

  @override
  void dispose() {
    _phoneFocusNode.removeListener(_onPhoneFocusChanged);
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _onPhoneFocusChanged() {
    if (_hasPhoneFocus != _phoneFocusNode.hasFocus) {
      setState(() {
        _hasPhoneFocus = _phoneFocusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: widget.labelStyle ?? GuestTopUpTheme.inputLabel,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: widget.enableCountryPicker ? widget.onPickCountry : null,
              borderRadius: BorderRadius.circular(_fieldRadius),
              child: Container(
                height: _countryPickerHeight,
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
                      Text(widget.country.flagEmoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(widget.country.dialCode,
                          style: GuestTopUpTheme.dialCode),
                      if (widget.enableCountryPicker) ...[
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
            const SizedBox(width: GuestTopUpTheme.countryToPhoneGap),
            Expanded(
              child: FocusedInputBorderWrapper(
                isFocused: _hasPhoneFocus,
                // Unfocused state should be borderless; show gradient only on focus.
                unfocusedBorderColor: Colors.transparent,
                child: Container(
                  height: _phoneFieldHeight,
                  decoration: BoxDecoration(
                    color: GuestTopUpTheme.inputFieldBackgroundColor,
                    borderRadius: BorderRadius.circular(_fieldRadius),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: TextField(
                    focusNode: _phoneFocusNode,
                    style: GuestTopUpTheme.phoneInput,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      fillColor: GuestTopUpTheme.inputFieldBackgroundColor,
                      filled: true,
                      border: InputBorder.none,
                      hintText: widget.hintText,
                      hintStyle: GuestTopUpTheme.phoneHint,
                      isCollapsed: true,
                    ),
                    onChanged: widget.onChanged,
                  ),
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
