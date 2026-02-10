import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/forget_password_theme.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_event.dart';
import '../bloc/forget_password_state.dart';
import 'focused_input_border_wrapper.dart';

class ForgetPasswordPhoneRow extends StatefulWidget {
  const ForgetPasswordPhoneRow({super.key});

  @override
  State<ForgetPasswordPhoneRow> createState() => _LoginPhoneRowState();
}

class _LoginPhoneRowState extends State<ForgetPasswordPhoneRow> {
  Country? _selectedCountry;
  final FocusNode _phoneFocusNode = FocusNode();
  bool _hasPhoneFocus = false;

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

  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) {
        setState(() {
          _selectedCountry = country;
        });

        // চাইলে country bloc এ পাঠাতে পারো
        // context.read<LoginBloc>().add(LoginCountryChanged(country));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final phoneField = Container(
      height: ForgetPasswordSizes.fieldHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ForgetPasswordSizes.fieldRadius),
        color: ForgetPasswordColors.pageBackground,
      ),
      padding: ForgetPasswordPaddings.fieldHorizontal14,
      alignment: Alignment.center,
      child: BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(
        buildWhen: (p, c) => p.phone != c.phone,
        builder: (context, state) {
          return TextField(
            focusNode: _phoneFocusNode,
            style: ForgetPasswordTheme.phoneInput,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'eg: 242 899 9999',
              hintStyle: ForgetPasswordTheme.phoneHint,
            ),
            onChanged: (value) => context
                .read<ForgetPasswordBloc>()
                .add(ForgetPasswordPhoneChanged(value)),
          );
        },
      ),
    );

    return SizedBox(
      height: ForgetPasswordSizes.fieldHeight,
      child: Row(
        children: [
          // ------- Country box -------
          InkWell(
            onTap: _openCountryPicker,
            borderRadius:
                BorderRadius.circular(ForgetPasswordSizes.fieldRadius),
            child: Container(
              width: ForgetPasswordSizes.countryWidth,
              height: ForgetPasswordSizes.fieldHeight,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(ForgetPasswordSizes.fieldRadius),
                border: Border.fromBorderSide(
                    ForgetPasswordDecorations.inputBorder),
                color: ForgetPasswordColors.pageBackground,
              ),
              padding: ForgetPasswordPaddings.countryHorizontal8,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _flagEmoji,
                      style: ForgetPasswordTheme.countryFlag,
                    ),
                    const SizedBox(
                        width: ForgetPasswordSizes.countryFlagToCodeGap),
                    Text(
                      _dialCode,
                      style: ForgetPasswordTheme.dialCode,
                    ),
                    const SizedBox(
                        width: ForgetPasswordSizes.countryCodeToArrowGap),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: ForgetPasswordSizes.countryArrowSize,
                      color: ForgetPasswordColors.hintGrey,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: ForgetPasswordSizes.countryToPhoneGap),

          // ------- Phone field -------
          Expanded(
            child: ForgetPasswordFocusedInputBorderWrapper(
              isFocused: _hasPhoneFocus,
              unfocusedBorderColor: ForgetPasswordColors.fieldBorder,
              child: phoneField,
            ),
          ),
        ],
      ),
    );
  }
}
