import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import '../../login/theme/login_theme.dart';
import '../bloc/login_otp_bloc.dart';
import '../bloc/login_otp_state.dart';
import '../bloc/login_otp_event.dart';

class OtpCodeFields extends StatefulWidget {
  const OtpCodeFields({super.key});

  @override
  State<OtpCodeFields> createState() => _OtpCodeFieldsState();
}

class _OtpCodeFieldsState extends State<OtpCodeFields> {
  final _controllers = List.generate(5, (_) => TextEditingController(), growable: false);
  final _focusNodes = List.generate(5, (_) => FocusNode(), growable: false);

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      value = value.characters.last;
      _controllers[index].text = value;
      _controllers[index].selection = TextSelection.collapsed(offset: value.length);
    }

    if (value.isNotEmpty && index < 4) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    context.read<LoginOtpBloc>().add(LoginOtpCodeChanged(code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginOtpBloc, LoginOtpState>(
      listenWhen: (p, c) => p.status != c.status && c.status == LoginOtpStatus.failure,
      listener: (context, state) {
        // চাইলে error হলে সব clear করতে পারো
        // for (final c in _controllers) c.clear();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          return _OtpBox(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            onChanged: (v) => _onChanged(index, v),
          );
        }),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center, // vertical center
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w600,
          color: LoginColors.textBlack,
        ),
        decoration: InputDecoration(
          isCollapsed: true,                  //reduce extra height
          contentPadding: EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 15),   // no extra padding না
          counterText: '',
          border:  OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide(
              color: ColorManager.otpBoxBorderDefaultColor, // LoginColors.lightGreyBorder,
              width: 1,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            borderSide: BorderSide(
              color: LoginColors.alivPurple,
              width: 1.4,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
