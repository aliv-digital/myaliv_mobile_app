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
  const LoginPasswordField({
    super.key,
    required this.onSubmitted,
    required this.focusNode,
    this.controller,
  });

  final VoidCallback onSubmitted;
  final FocusNode focusNode;
  final TextEditingController? controller;

  @override
  State<LoginPasswordField> createState() => _LoginPasswordFieldState();
}

class _LoginPasswordFieldState extends State<LoginPasswordField> {
  bool _obscure = true;
  bool _hasPasswordFocus = false;
  TextEditingController? _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _hasPasswordFocus = widget.focusNode.hasFocus;
    widget.focusNode.addListener(_onPasswordFocusChanged);
  }

  @override
  void didUpdateWidget(covariant LoginPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onPasswordFocusChanged);
      widget.focusNode.addListener(_onPasswordFocusChanged);
      _hasPasswordFocus = widget.focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onPasswordFocusChanged);
    _internalController?.dispose();
    super.dispose();
  }

  void _onPasswordFocusChanged() {
    if (_hasPasswordFocus != widget.focusNode.hasFocus) {
      setState(() {
        _hasPasswordFocus = widget.focusNode.hasFocus;
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
                  focusNode: widget.focusNode,
                  controller: _effectiveController,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  style: AuthModuleTextStyles.fieldValue,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'enter your password',
                    hintStyle: AuthModuleTextStyles.passwordHint,
                  ),
                  onChanged: (value) => context.read<LoginBloc>().add(
                    LoginPasswordChanged(value),
                  ),
                  onSubmitted: (_) {
                    if (context.read<LoginBloc>().state.status ==
                        LoginStatus.loading) {
                      return;
                    }
                    widget.onSubmitted();
                  },
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
