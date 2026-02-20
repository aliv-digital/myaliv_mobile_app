import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/otp_prepaid_bloc.dart';
import '../bloc/otp_prepaid_event.dart';
import '../bloc/otp_prepaid_state.dart';
import '../theme/otp_prepaid_theme.dart';

class OtpAutoRenewPrepaidCodeFields extends StatefulWidget {
  const OtpAutoRenewPrepaidCodeFields({super.key});

  @override
  State<OtpAutoRenewPrepaidCodeFields> createState() =>
      _OtpAutoRenewPrepaidCodeFieldsState();
}

class _OtpAutoRenewPrepaidCodeFieldsState
    extends State<OtpAutoRenewPrepaidCodeFields> {
  final _controllers = List.generate(
    OtpAutoRenewPrepaidTheme.otpLength,
    (_) => TextEditingController(),
    growable: false,
  );
  final _focusNodes = List.generate(
    OtpAutoRenewPrepaidTheme.otpLength,
    (_) => FocusNode(),
    growable: false,
  );

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
    final int lastFieldIndex = OtpAutoRenewPrepaidTheme.otpLength - 1;

    if (value.length > 1) {
      value = value.characters.last;
      _controllers[index].text = value;
      _controllers[index].selection =
          TextSelection.collapsed(offset: value.length);
    }

    if (value.isNotEmpty && index < lastFieldIndex) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    context
        .read<OtpAutoRenewPrepaidBloc>()
        .add(OtpAutoRenewPrepaidCodeChanged(code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpAutoRenewPrepaidBloc, OtpAutoRenewPrepaidState>(
      listenWhen: (p, c) =>
          p.status != c.status && c.status == OtpAutoRenewPrepaidStatus.failure,
      listener: (context, state) {
        // চাইলে error হলে সব clear করতে পারো
        // for (final c in _controllers) c.clear();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(OtpAutoRenewPrepaidTheme.otpLength, (index) {
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
      width: OtpAutoRenewPrepaidTheme.otpBoxSize,
      height: OtpAutoRenewPrepaidTheme.otpBoxSize,
      child: AnimatedBuilder(
        animation: focusNode,
        builder: (context, _) {
          final bool isFocused = focusNode.hasFocus;
          final double innerRadius =
              (OtpAutoRenewPrepaidTheme.otpBoxBorderRadius -
                      OtpAutoRenewPrepaidTheme.otpBoxBorderWidth)
                  .clamp(0.0, OtpAutoRenewPrepaidTheme.otpBoxBorderRadius);

          return Container(
            decoration: BoxDecoration(
              gradient: isFocused
                  ? OtpAutoRenewPrepaidTheme.otpFocusedBorderGradient
                  : null,
              border: isFocused
                  ? null
                  : Border.all(
                      color: OtpAutoRenewPrepaidTheme.otpInputBorderColor,
                      width: OtpAutoRenewPrepaidTheme.otpBoxBorderWidth,
                    ),
              borderRadius: const BorderRadius.all(
                Radius.circular(OtpAutoRenewPrepaidTheme.otpBoxBorderRadius),
              ),
            ),
            padding: const EdgeInsets.all(
                OtpAutoRenewPrepaidTheme.otpBoxBorderWidth),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(innerRadius),
              child: ColoredBox(
                color: OtpAutoRenewPrepaidTheme.otpInputBackgroundColor,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: OtpAutoRenewPrepaidTheme.otpDigitTextStyle,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    contentPadding:
                        OtpAutoRenewPrepaidTheme.otpFieldContentPadding,
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
