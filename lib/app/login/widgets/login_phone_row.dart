import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../theme/login_theme.dart';


class LoginPhoneRow extends StatefulWidget {
  const LoginPhoneRow({super.key});

  @override
  State<LoginPhoneRow> createState() => _LoginPhoneRowState();
}

class _LoginPhoneRowState extends State<LoginPhoneRow> {
  Country? _selectedCountry;

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
      height: 60,
      child: Row(
        children: [
          // ------- Country box -------
          InkWell(
            onTap: _openCountryPicker,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 82,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AuthModuleColors.lightGreyBorder,
                  width: 1.2,
                ),
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ------- Phone field -------
          Expanded(
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AuthModuleColors.lightGreyBorder,
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: BlocBuilder<LoginBloc, LoginState>(
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
                      hintText: 'eg: 242-899-9999',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: AuthModuleColors.hintGrey,
                      ),
                    ),
                    onChanged: (value) => context.read<LoginBloc>().add(LoginPhoneChanged(value)),
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
