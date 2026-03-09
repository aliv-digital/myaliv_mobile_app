import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/login_otp_theme.dart';
import '../bloc/login_otp_bloc.dart';
import '../bloc/login_otp_state.dart';
import '../bloc/login_otp_event.dart';

class OtpCodeFields extends StatefulWidget {
  const OtpCodeFields({super.key});

  @override
  State<OtpCodeFields> createState() => _OtpCodeFieldsState();
}

class _OtpCodeFieldsState extends State<OtpCodeFields> {
  static const int _otpLength = 4;
  final _controllers =
      List.generate(_otpLength, (_) => TextEditingController(), growable: false);
  final _focusNodes =
      List.generate(_otpLength, (_) => FocusNode(), growable: false);

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

    if (value.isNotEmpty && index < _otpLength - 1) {
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
        children: List.generate(_otpLength, (index) {
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
      width: LoginOtpSizes.otpBoxSize,
      height: LoginOtpSizes.otpBoxSize,
      child: AnimatedBuilder(
        animation: focusNode,
        builder: (context, _) {
          final isFocused = focusNode.hasFocus;
          final innerRadius =
              (LoginOtpSizes.otpBoxRadius - LoginOtpSizes.otpBoxBorderWidth)
                  .clamp(0.0, LoginOtpSizes.otpBoxRadius);

          return Container(
            decoration: BoxDecoration(
              gradient: isFocused ? LoginOtpGradients.focusedInputBorder : null,
              border: isFocused
                  ? null
                  : Border.all(
                      color: LoginOtpColors.otpBoxBorderDefault,
                      width: LoginOtpSizes.otpBoxBorderWidth,
                    ),
              borderRadius: BorderRadius.circular(LoginOtpSizes.otpBoxRadius),
            ),
            padding: const EdgeInsets.all(LoginOtpSizes.otpBoxBorderWidth),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(innerRadius),
              child: ColoredBox(
                color: LoginOtpColors.otpBoxBackground,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: LoginOtpTheme.otpInput,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    contentPadding: LoginOtpSizes.otpBoxContentPadding,
                    counterText: '',
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
