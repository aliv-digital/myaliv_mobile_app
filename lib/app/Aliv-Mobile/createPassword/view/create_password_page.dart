import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../bloc/create_password_bloc.dart';
import '../bloc/create_password_event.dart';
import '../bloc/create_password_state.dart';
import '../repository/create_password_repository.dart';
import '../theme/create_password_theme.dart';
import '../widgets/create_password_header.dart';
import '../widgets/password_input.dart';

class CreatePasswordScreen extends StatelessWidget {
  const CreatePasswordScreen({
    super.key,
    this.title = 'create password',
    this.subtitle =
        'Set the new password for your account so you can login and access myaliv app',
    this.buttonLabel = 'continue',
  });

  final String title;
  final String subtitle;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreatePasswordBloc(repository: CreatePasswordRepository()),
      child: _CreatePasswordView(
        title: title,
        subtitle: subtitle,
        buttonLabel: buttonLabel,
      ),
    );
  }
}

class _CreatePasswordView extends StatelessWidget {
  const _CreatePasswordView({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return StripedScaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<CreatePasswordBloc, CreatePasswordState>(
          listenWhen: (p, c) =>
              p.status != c.status || p.errorMessage != c.errorMessage,
          listener: (context, state) {
            if (state.status == CreatePasswordStatus.success) {
              AppToast.show(
                message: 'Password updated successfully.',
                type: ToastType.success,
              );
              context.go(AppRoutes.home);
            }
            if (state.status == CreatePasswordStatus.failure &&
                state.errorMessage != null) {
              AppToast.show(
                message: state.errorMessage!,
                type: ToastType.error,
              );
            }
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: CreatePasswordHeader(
                  title: title,
                  subtitle: subtitle,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(right: 42, left: 42),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 39),

                      BlocBuilder<CreatePasswordBloc, CreatePasswordState>(
                        buildWhen: (p, c) =>
                            p.obscurePassword != c.obscurePassword ||
                            p.password != c.password,
                        builder: (context, state) {
                          return PasswordInput(
                            hint: 'enter new password',
                            obscureText: state.obscurePassword,
                            onChanged: (v) => context
                                .read<CreatePasswordBloc>()
                                .add(PasswordChanged(v)),
                            onToggle: () => context
                                .read<CreatePasswordBloc>()
                                .add(const TogglePasswordVisibility()),
                          );
                        },
                      ),

                      const SizedBox(height: 15),

                      BlocBuilder<CreatePasswordBloc, CreatePasswordState>(
                        buildWhen: (p, c) =>
                            p.obscureConfirm != c.obscureConfirm ||
                            p.confirmPassword != c.confirmPassword,
                        builder: (context, state) {
                          return PasswordInput(
                            hint: 're-enter password',
                            obscureText: state.obscureConfirm,
                            onChanged: (v) => context
                                .read<CreatePasswordBloc>()
                                .add(ConfirmPasswordChanged(v)),
                            onToggle: () => context
                                .read<CreatePasswordBloc>()
                                .add(const ToggleConfirmPasswordVisibility()),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'your password should contain letters and/or\n'
                        'numbers and be between 8 and 64 characters long.',
                        textAlign: TextAlign.center,
                        style: CreatePasswordTheme.helperText,
                      ),

                      const SizedBox(height: 30),

                      BlocBuilder<CreatePasswordBloc, CreatePasswordState>(
                        buildWhen: (p, c) => p.status != c.status,
                        builder: (context, state) {
                          return DefaultButton(
                            label: buttonLabel,
                            isLoading: state.status ==
                                CreatePasswordStatus.submitting,
                            onPressed: () => context
                                .read<CreatePasswordBloc>()
                                .add(const SubmitCreatePassword()),
                          );
                        },
                      ),

                      const SizedBox(height: 181),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
