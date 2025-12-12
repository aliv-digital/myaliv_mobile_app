import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: hasError ? AuthModuleColors.errorRed : AuthModuleColors.lightGreyBorder,
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: AuthModuleColors.hintGrey,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      obscureText: _obscure,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '• • • • • • •',
                        hintStyle: TextStyle(
                          fontSize: 16,
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
                      color: AuthModuleColors.hintGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            if (hasError)
              const Text(
                'invalid credentials!',
                style: TextStyle(
                  fontSize: 12,
                  color: AuthModuleColors.errorRed,
                ),
              ),
          ],
        );
      },
    );
  }
}
