import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import '../theme/top_up_prepaid_theme.dart';

class SendTopUpPhoneField extends StatefulWidget {
  final String hint;

  const SendTopUpPhoneField({
    super.key,
    required this.hint,
  });

  @override
  State<SendTopUpPhoneField> createState() => _SendTopUpPhoneFieldState();
}

class _SendTopUpPhoneFieldState extends State<SendTopUpPhoneField> {
  Country? _selectedCountry;
  String _phone = '';
  String? _error;

  String get _flagEmoji => _selectedCountry?.flagEmoji ?? '🇺🇸';

  String get _dialCode {
    final raw = _selectedCountry?.phoneCode ?? '1';
    return raw.split(RegExp(r'[\s-]')).first;
  }

  bool get _isUSA => _dialCode == '1';

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
          _validate(_phone);
        });
      },
    );
  }
  */

  void _validate(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (!_isUSA) {
      _error = null; // Only enforcing USA for now
    } else if (digits.isEmpty) {
      _error = null;
    } else if (digits.length != 10) {
      _error = 'enter a valid 10-digit phone number';
    } else if (!RegExp(r'^[2-9]').hasMatch(digits)) {
      _error = 'invalid  phone number';
    } else {
      _error = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 60,
          child: Row(
            children: [

              Expanded(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasError
                          ? Colors.red
                          : TopUpPrepaidTheme.lightBg,
                      width: 1.2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'CircularPro',
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hint,
                      hintStyle: const TextStyle(
                        color: const Color(0xFF707070),
                        fontSize: 14,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _phone = value;
                        _validate(value);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // -------- Error text --------
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _error!,
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
