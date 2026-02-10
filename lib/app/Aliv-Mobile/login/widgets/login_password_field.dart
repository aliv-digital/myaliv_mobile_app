import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../theme/login_theme.dart';

class LoginPasswordField extends StatefulWidget {
  const LoginPasswordField({super.key});

  @override
  State<LoginPasswordField> createState() => _LoginPasswordFieldState();
}

class _LoginPasswordFieldState extends State<LoginPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final hasError = state.status == LoginStatus.failure && state.errorMessage != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: AuthModuleSizes.fieldHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AuthModuleSizes.fieldRadius),
                border: Border.fromBorderSide(
                  hasError ? AuthModuleDecorations.inputErrorBorder : AuthModuleDecorations.inputBorder,
                ),
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
                      obscureText: _obscure,
                      style: AuthModuleTextStyles.fieldValue,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'enter your password',
                        hintStyle: AuthModuleTextStyles.passwordHint,
                      ),
                      onChanged: (value) => context.read<LoginBloc>().add(LoginPasswordChanged(value)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: SvgPicture.asset(
                      _obscure ? AssetConstant.hideIconSVG : AssetConstant.viewIconSVG,
                      width: AuthModuleSizes.eyeIconSize,
                      height: AuthModuleSizes.eyeIconSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
