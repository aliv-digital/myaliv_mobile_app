import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../theme/login_theme.dart';
import 'focused_input_border_wrapper.dart';

class LoginPasswordField extends StatefulWidget {
  const LoginPasswordField({super.key});

  @override
  State<LoginPasswordField> createState() => _LoginPasswordFieldState();
}

class _LoginPasswordFieldState extends State<LoginPasswordField> {
  bool _obscure = true;
  final FocusNode _passwordFocusNode = FocusNode();
  bool _hasPasswordFocus = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(_onPasswordFocusChanged);
  }

  @override
  void dispose() {
    _passwordFocusNode.removeListener(_onPasswordFocusChanged);
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onPasswordFocusChanged() {
    if (_hasPasswordFocus != _passwordFocusNode.hasFocus) {
      setState(() {
        _hasPasswordFocus = _passwordFocusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final hasError = state.passwordFieldError;
        final passwordField = Container(
          height: AuthModuleSizes.fieldHeight,
          decoration: BoxDecoration(
            color: AuthModuleColors.pageBackground,
            borderRadius: BorderRadius.circular(AuthModuleSizes.fieldRadius),
          ),
          padding: AuthModulePaddings.fieldHorizontal14,
          child: Row(
            children: [
              SvgPicture.asset(
                AssetConstant.lockPassSVG,
                width: AuthModuleSizes.lockIconSize,
                height: AuthModuleSizes.lockIconSize,
                colorFilter: const ColorFilter.mode(
                  AuthModuleColors.lockColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: AuthModuleSizes.lockToInputGap),
              Expanded(
                child: TextField(
                  focusNode: _passwordFocusNode,
                  obscureText: _obscure,
                  style: AuthModuleTextStyles.fieldValue,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'enter your password',
                    hintStyle: AuthModuleTextStyles.passwordHint,
                  ),
                  onChanged: (value) => context
                      .read<LoginBloc>()
                      .add(LoginPasswordChanged(value)),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: SvgPicture.asset(
                  _obscure
                      ? AssetConstant.hideIconSVG
                      : AssetConstant.viewIconSVG,
                  width: AuthModuleSizes.eyeIconSize,
                  height: AuthModuleSizes.eyeIconSize,
                ),
              ),
            ],
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FocusedInputBorderWrapper(
              isFocused: _hasPasswordFocus && !hasError,
              unfocusedBorderColor: hasError
                  ? AuthModuleColors.errorRed
                  : AuthModuleColors.loginFieldBorderColor,
              child: passwordField,
            ),
          ],
        );
      },
    );
  }
}
