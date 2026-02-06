import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../login/theme/login_theme.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_event.dart';
import '../bloc/forget_password_state.dart';



class ForgetPasswordPhoneRow extends StatefulWidget {
  const ForgetPasswordPhoneRow({super.key});

  @override
  State<ForgetPasswordPhoneRow> createState() => _LoginPhoneRowState();
}

class _LoginPhoneRowState extends State<ForgetPasswordPhoneRow> {
  Country? _selectedCountry;
  static const double _fieldHeight = 54;
  static const double _fieldRadius = 8;

  String get _flagEmoji => _selectedCountry?.flagEmoji ?? '🇧🇸'; // Bahamas default

  String get _dialCode {
    final raw = _selectedCountry?.phoneCode ?? '1';
    // "1-242" / "1 242" টাইপ হলে প্রথম অংশটাই নেব
    return raw.split(RegExp(r'[\s-]')).first;
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
    return SizedBox(
      height: _fieldHeight,
      child: Row(
        children: [
          // ------- Country box -------
          InkWell(
            onTap: _openCountryPicker,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 76,
              height: _fieldHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_fieldRadius),
                border: Border.all(
                  color: AuthModuleColors.lightGreyBorder,
                  width: 1,
                ),
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _flagEmoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _dialCode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'CircularPro',
                        color: AuthModuleColors.textBlack,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AuthModuleColors.hintGrey,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ------- Phone field -------
          Expanded(
            child: Container(
              height: _fieldHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_fieldRadius),
                border: Border.all(
                  color: AuthModuleColors.lightGreyBorder,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(
                buildWhen: (p, c) => p.phone != c.phone,
                builder: (context, state) {
                  return TextField(
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'CircularPro',
                      color: AuthModuleColors.textBlack,
                    ),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'eg: 242 899 9999',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AuthModuleColors.hintGrey,
                        fontFamily: 'CircularPro',
                      ),
                    ),
                    onChanged: (value) => context.read<ForgetPasswordBloc>().add(ForgetPasswordPhoneChanged(value)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
