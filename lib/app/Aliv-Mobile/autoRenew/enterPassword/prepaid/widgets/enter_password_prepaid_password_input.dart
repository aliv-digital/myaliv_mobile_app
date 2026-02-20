import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../theme/enter_password_autoRenew_prepaid_theme.dart';

class EnterPasswordAutoRenewPrepaidPasswordInput extends StatefulWidget {
  final String value;
  final bool obscure;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggle;

  const EnterPasswordAutoRenewPrepaidPasswordInput({
    super.key,
    required this.value,
    required this.obscure,
    required this.onChanged,
    required this.onToggle,
  });

  @override
  State<EnterPasswordAutoRenewPrepaidPasswordInput> createState() =>
      _EnterPasswordAutoRenewPrepaidPasswordInputState();
}

class _EnterPasswordAutoRenewPrepaidPasswordInputState
    extends State<EnterPasswordAutoRenewPrepaidPasswordInput> {
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: EnterPasswordAutoRenewPrepaidTheme.passwordInputHeight,
      child: AnimatedBuilder(
        animation: _passwordFocusNode,
        builder: (BuildContext context, Widget? child) {
          final bool isFocused = _passwordFocusNode.hasFocus;
          final double innerRadius = (EnterPasswordAutoRenewPrepaidTheme
                      .passwordInputBorderRadius -
                  EnterPasswordAutoRenewPrepaidTheme.passwordInputBorderWidth)
              .clamp(
            0.0,
            EnterPasswordAutoRenewPrepaidTheme.passwordInputBorderRadius,
          );

          return Container(
            decoration: BoxDecoration(
              gradient: isFocused
                  ? EnterPasswordAutoRenewPrepaidTheme
                      .focusedInputBorderGradient
                  : null,
              border: isFocused
                  ? null
                  : Border.all(
                      color: EnterPasswordAutoRenewPrepaidTheme.inputBorder,
                      width: EnterPasswordAutoRenewPrepaidTheme
                          .passwordInputBorderWidth,
                    ),
              borderRadius: BorderRadius.circular(
                EnterPasswordAutoRenewPrepaidTheme.passwordInputBorderRadius,
              ),
            ),
            padding: const EdgeInsets.all(
              EnterPasswordAutoRenewPrepaidTheme.passwordInputBorderWidth,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(innerRadius),
              child: ColoredBox(
                color: EnterPasswordAutoRenewPrepaidTheme.inputBackground,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: EnterPasswordAutoRenewPrepaidTheme
                        .passwordInputHorizontalPadding,
                  ),
                  child: Row(
                    children: <Widget>[
                      SvgPicture.asset('assets/icons/LockKey.svg'),
                      const SizedBox(
                        width: EnterPasswordAutoRenewPrepaidTheme
                            .passwordInputIconGap,
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: _passwordFocusNode,
                          obscureText: widget.obscure,
                          onChanged: widget.onChanged,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                            hintText: 'Password',
                            hintStyle: EnterPasswordAutoRenewPrepaidTheme
                                .passwordHintTextStyle,
                          ),
                          style: EnterPasswordAutoRenewPrepaidTheme
                              .passwordInputTextStyle,
                        ),
                      ),
                      InkWell(
                        onTap: widget.onToggle,
                        borderRadius: BorderRadius.circular(999),
                        child: const Padding(
                          padding: EdgeInsets.all(
                            EnterPasswordAutoRenewPrepaidTheme
                                .passwordInputSuffixIconPadding,
                          ),
                          child: _PasswordVisibilityIcon(),
                        ),
                      ),
                    ],
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

class _PasswordVisibilityIcon extends StatelessWidget {
  const _PasswordVisibilityIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/icons/EyeSlash.svg');
  }
}
