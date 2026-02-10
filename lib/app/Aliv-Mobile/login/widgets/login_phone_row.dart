import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../theme/login_theme.dart';
import 'focused_input_border_wrapper.dart';

class LoginPhoneRow extends StatefulWidget {
  const LoginPhoneRow({super.key});

  @override
  State<LoginPhoneRow> createState() => _LoginPhoneRowState();
}

class _LoginPhoneRowState extends State<LoginPhoneRow> {
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

  String get _flagEmoji => _selectedCountry?.flagEmoji ?? '🇧🇸'; // Bahamas default

  String get _dialCode {
    final raw = _selectedCountry?.phoneCode ?? '1';
    // Handles both "1-242" and "1 242" forms and keeps first non-empty segment.
    final normalized = raw.replaceAll('-', ' ');
    return normalized.split(' ').firstWhere((part) => part.trim().isNotEmpty, orElse: () => '1');
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
      height: AuthModuleSizes.fieldHeight,
      decoration: BoxDecoration(
        color: AuthModuleColors.pageBackground,
        borderRadius: BorderRadius.circular(AuthModuleSizes.fieldRadius),
      ),
      padding: AuthModulePaddings.fieldHorizontal14,
      alignment: Alignment.center,
      child: BlocBuilder<LoginBloc, LoginState>(
        buildWhen: (p, c) => p.phone != c.phone,
        builder: (context, state) {
          return TextField(
            focusNode: _phoneFocusNode,
            style: AuthModuleTextStyles.fieldValue,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'eg: 242-899-9999',
              hintStyle: AuthModuleTextStyles.fieldHint,
            ),
            onChanged: (value) => context.read<LoginBloc>().add(LoginPhoneChanged(value)),
          );
        },
      ),
    );

    return SizedBox(
      height: AuthModuleSizes.fieldHeight,
      child: Row(
        children: [
          // ------- Country box -------
          InkWell(
            onTap: _openCountryPicker,
            borderRadius: BorderRadius.circular(AuthModuleSizes.fieldRadius),
            child: Container(
              width: AuthModuleSizes.countryWidth,
              height: AuthModuleSizes.fieldHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AuthModuleSizes.fieldRadius),
                border: Border.fromBorderSide(AuthModuleDecorations.inputBorder),
                color: AuthModuleColors.pageBackground,
              ),
              padding: AuthModulePaddings.countryHorizontal8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _flagEmoji,
                    style: AuthModuleTextStyles.countryFlag,
                  ),
                  const SizedBox(width: AuthModuleSizes.countryFlagToCodeGap),
                  Text(
                    _dialCode,
                    style: AuthModuleTextStyles.countryCode,
                  ),
                  const SizedBox(width: AuthModuleSizes.countryCodeToArrowGap),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: AuthModuleSizes.countryArrowSize,
                    color: AuthModuleColors.hintGrey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AuthModuleSizes.countryToPhoneGap),

          // ------- Phone field -------
          Expanded(
            child: FocusedInputBorderWrapper(
              isFocused: _hasPhoneFocus,
              unfocusedBorderColor: AuthModuleColors.loginFieldBorderColor,
              child: phoneField,
            ),
          ),
        ],
      ),
    );
  }
}
