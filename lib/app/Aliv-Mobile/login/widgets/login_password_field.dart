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
  static const double _fieldHeight = 54;
  static const double _fieldRadius = 8;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final hasError = state.status == LoginStatus.failure && state.errorMessage != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: _fieldHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_fieldRadius),
                border: Border.all(
                  color: hasError ? AuthModuleColors.errorRed : AuthModuleColors.lightGreyBorder,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AssetConstant.lockPassSVG,
                    width: 18,
                    height: 18,
                    colorFilter: ColorFilter.mode(
                      AuthModuleColors.lockColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      obscureText: _obscure,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'CircularPro',
                        color: AuthModuleColors.textBlack,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '• • • • • • •',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          letterSpacing: 3,
                          color: AuthModuleColors.hintGrey,
                        ),
                      ),
                      onChanged: (value) => context.read<LoginBloc>().add(LoginPasswordChanged(value)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: AuthModuleColors.lockColor,
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
