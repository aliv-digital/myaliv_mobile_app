import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  /// 6-digit PIN dispatched by the JWT auth API's 2FA flow.
  static const int _otpLength = 6;

  /// Minimum cell size before the row would look cramped. Below the design
  /// target (44) but still tap-friendly on small phones (e.g. 320-wide).
  static const double _minBoxSize = 36;

  /// Minimum gap between cells so borders never visually merge.
  static const double _minGap = 6;

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
    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length <= 1) {
      // Single-digit typing (or backspace clearing the cell).
      if (_controllers[index].text != digits) {
        _controllers[index].text = digits;
        _controllers[index].selection =
            TextSelection.collapsed(offset: digits.length);
      }
      if (digits.isNotEmpty && index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else if (digits.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      } else if (digits.isNotEmpty && index == _otpLength - 1) {
        _focusNodes[index].unfocus();
      }
    } else {
      // Multi-digit input: clipboard paste or SMS OTP autofill. Fan the
      // digits out starting at the current cell instead of stuffing them
      // all into this one.
      final available = _otpLength - index;
      final chunk = digits.length > available
          ? digits.substring(0, available)
          : digits;
      for (var i = 0; i < chunk.length; i++) {
        final target = _controllers[index + i];
        final ch = chunk[i];
        if (target.text != ch) {
          target.text = ch;
          target.selection = const TextSelection.collapsed(offset: 1);
        }
      }
      final nextIndex = index + chunk.length;
      if (nextIndex < _otpLength) {
        _focusNodes[nextIndex].requestFocus();
      } else {
        _focusNodes[_otpLength - 1].unfocus();
      }
    }

    final code = _controllers.map((c) => c.text).join();
    context.read<LoginOtpBloc>().add(LoginOtpCodeChanged(code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginOtpBloc, LoginOtpState>(
      builder: (context, state) {
        final hasFieldError = state.codeFieldError;
        return LayoutBuilder(
          builder: (context, constraints) {
            // Derive cell size from available width so 6 cells always fit.
            // Prefer the design target (44) but shrink down to _minBoxSize on
            // narrow devices instead of overflowing the Row.
            final maxWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : LoginOtpSizes.otpBoxSize * _otpLength +
                    _minGap * (_otpLength - 1);
            final totalGaps = _minGap * (_otpLength - 1);
            final rawBox = (maxWidth - totalGaps) / _otpLength;
            final boxSize = rawBox
                .clamp(_minBoxSize, LoginOtpSizes.otpBoxSize)
                .toDouble();

            return AutofillGroup(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_otpLength, (index) {
                  return _OtpBox(
                    size: boxSize,
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    showError: hasFieldError,
                    // Only the first cell advertises one-time-code autofill.
                    // Platform pastes the full SMS OTP into it, and the
                    // multi-digit branch of _onChanged fans it out.
                    autofillHints: index == 0
                        ? const [AutofillHints.oneTimeCode]
                        : const [],
                    onChanged: (v) => _onChanged(index, v),
                  );
                }),
              ),
            );
          },
        );
      },
    );
  }
}

class _OtpBox extends StatelessWidget {
  final double size;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showError;
  final List<String> autofillHints;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.size,
    required this.controller,
    required this.focusNode,
    required this.showError,
    required this.autofillHints,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final innerRadius =
        (LoginOtpSizes.otpBoxRadius - LoginOtpSizes.otpBoxBorderWidth)
            .clamp(0.0, LoginOtpSizes.otpBoxRadius);

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: focusNode,
        builder: (context, _) {
          final isFocused = focusNode.hasFocus;
          final showFocusStyle = isFocused && !showError;

          return Container(
            decoration: BoxDecoration(
              gradient:
                  showFocusStyle ? LoginOtpGradients.focusedInputBorder : null,
              border: showFocusStyle
                  ? null
                  : Border.all(
                      color: showError
                          ? LoginOtpColors.otpBoxBorderError
                          : LoginOtpColors.otpBoxBorderDefault,
                      width: LoginOtpSizes.otpBoxBorderWidth,
                    ),
              borderRadius: BorderRadius.circular(LoginOtpSizes.otpBoxRadius),
            ),
            padding: const EdgeInsets.all(LoginOtpSizes.otpBoxBorderWidth),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(innerRadius),
              child: ColoredBox(
                color: LoginOtpColors.otpBoxBackground,
                // Center wraps the collapsed TextField so both caret and glyph
                // sit at the vertical middle of the cell — Flutter's
                // InputDecorator + textAlignVertical is unreliable at these
                // small heights, so we let Center do the work instead.
                child: Center(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    // maxLength intentionally omitted so a pasted 6-digit
                    // code (or SMS autofill) reaches _onChanged intact and
                    // can be distributed across cells. Per-cell 1-char
                    // enforcement lives in _onChanged instead.
                    autofillHints: autofillHints,
                    cursorHeight: LoginOtpTheme.otpInput.fontSize,
                    style: LoginOtpTheme.otpInput,
                    // forceStrutHeight pins the line box to the font size so
                    // Center's placement math matches the glyph's ink box.
                    strutStyle: StrutStyle(
                      fontSize: LoginOtpTheme.otpInput.fontSize,
                      height: 1.0,
                      forceStrutHeight: true,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                      border: InputBorder.none,
                    ),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
