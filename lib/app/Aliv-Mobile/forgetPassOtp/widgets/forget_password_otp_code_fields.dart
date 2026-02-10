import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/forget_password_otp_theme.dart';
import '../bloc/forget_password_otp_bloc.dart';
import '../bloc/forget_password_otp_event.dart';
import '../bloc/forget_password_otp_state.dart';

class ForgetPasswordOtpCodeFields extends StatefulWidget {
  const ForgetPasswordOtpCodeFields({super.key});

  @override
  State<ForgetPasswordOtpCodeFields> createState() =>
      _ForgetPasswordOtpCodeFieldsState();
}

class _ForgetPasswordOtpCodeFieldsState
    extends State<ForgetPasswordOtpCodeFields> {
  final _controllers =
      List.generate(5, (_) => TextEditingController(), growable: false);
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
      _controllers[index].selection =
          TextSelection.collapsed(offset: value.length);
    }

    if (value.isNotEmpty && index < 4) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    context
        .read<ForgetPasswordOtpBloc>()
        .add(ForgetPasswordOtpCodeChanged(code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgetPasswordOtpBloc, ForgetPasswordOtpState>(
      listenWhen: (p, c) =>
          p.status != c.status && c.status == ForgetPasswordOtpStatus.failure,
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
      width: ForgetPasswordOtpSizes.otpBoxSize,
      height: ForgetPasswordOtpSizes.otpBoxSize,
      child: AnimatedBuilder(
        animation: focusNode,
        builder: (context, _) {
          final isFocused = focusNode.hasFocus;
          final innerRadius = (ForgetPasswordOtpSizes.otpBoxRadius -
                  ForgetPasswordOtpSizes.otpBoxBorderWidth)
              .clamp(0.0, ForgetPasswordOtpSizes.otpBoxRadius);

          return Container(
            decoration: BoxDecoration(
              gradient: isFocused
                  ? ForgetPasswordOtpGradients.focusedInputBorder
                  : null,
              border: isFocused
                  ? null
                  : Border.all(
                      color: ForgetPasswordOtpColors.otpBoxBorderDefault,
                      width: ForgetPasswordOtpSizes.otpBoxBorderWidth,
                    ),
              borderRadius:
                  BorderRadius.circular(ForgetPasswordOtpSizes.otpBoxRadius),
            ),
            padding:
                const EdgeInsets.all(ForgetPasswordOtpSizes.otpBoxBorderWidth),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(innerRadius),
              child: ColoredBox(
                color: ForgetPasswordOtpColors.otpBoxBackground,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: ForgetPasswordOtpTheme.otpInput,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    contentPadding: ForgetPasswordOtpSizes.otpBoxContentPadding,
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
