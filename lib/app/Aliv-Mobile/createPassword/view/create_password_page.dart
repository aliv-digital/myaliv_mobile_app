import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/app_keyboard_toolbar.dart';
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

/// Signature used by callers that need to intercept the post-reset navigation
/// (e.g. the password-recovery flow, which prompts the user to cache
/// credentials before continuing to home).
typedef CreatePasswordSuccessHandler =
    Future<void> Function(BuildContext context, String newPassword);

class CreatePasswordScreen extends StatelessWidget {
  const CreatePasswordScreen({
    super.key,
    this.title = 'create password',
    this.subtitle =
        'set the new password for your account so you can login and access myaliv app',
    this.buttonLabel = 'continue',
    this.onBack,
    this.onSuccess,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onBack;
  final CreatePasswordSuccessHandler? onSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreatePasswordBloc(repository: CreatePasswordRepository()),
      child: _CreatePasswordView(
        title: title,
        subtitle: subtitle,
        buttonLabel: buttonLabel,
        onBack: onBack,
        onSuccess: onSuccess,
      ),
    );
  }
}

class _CreatePasswordView extends StatefulWidget {
  const _CreatePasswordView({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.onBack,
    this.onSuccess,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onBack;
  final CreatePasswordSuccessHandler? onSuccess;

  @override
  State<_CreatePasswordView> createState() => _CreatePasswordViewState();
}

class _CreatePasswordViewState extends State<_CreatePasswordView> {
  final FocusNode _passwordFocusNode = FocusNode(debugLabel: 'createPassword');
  final FocusNode _confirmPasswordFocusNode = FocusNode(
    debugLabel: 'createPasswordConfirm',
  );

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _submit([String? _]) {
    final bloc = context.read<CreatePasswordBloc>();
    if (bloc.state.status == CreatePasswordStatus.submitting) return;
    bloc.add(const SubmitCreatePassword());
  }

  @override
  Widget build(BuildContext context) {
    final page = PopScope(
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onBack?.call();
      },
      child: StripedScaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: BlocListener<CreatePasswordBloc, CreatePasswordState>(
            listenWhen: (p, c) =>
                p.status != c.status || p.errorMessage != c.errorMessage,
            listener: (context, state) async {
              if (state.status == CreatePasswordStatus.success) {
                AppToast.show(
                  message: 'Password reset successful!',
                  type: ToastType.success,
                );
                final handler = widget.onSuccess;
                if (handler != null) {
                  await handler(context, state.password.trim());
                } else if (context.mounted) {
                  context.go(AppRoutes.home);
                }
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: CreatePasswordHeader(
                    title: widget.title,
                    subtitle: widget.subtitle,
                    onBack: widget.onBack,
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
                              p.password != c.password ||
                              p.passwordError != c.passwordError,
                          builder: (context, state) {
                            return PasswordInput(
                              focusNode: _passwordFocusNode,
                              hint: 'enter new password',
                              errorText: state.passwordError,
                              obscureText: state.obscurePassword,
                              textInputAction: TextInputAction.next,
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
                              p.confirmPassword != c.confirmPassword ||
                              p.confirmPasswordError != c.confirmPasswordError,
                          builder: (context, state) {
                            return PasswordInput(
                              focusNode: _confirmPasswordFocusNode,
                              hint: 're-enter password',
                              errorText: state.confirmPasswordError,
                              obscureText: state.obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onSubmitted: _submit,
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
                              label: widget.buttonLabel,
                              isLoading:
                                  state.status ==
                                  CreatePasswordStatus.submitting,
                              onPressed: _submit,
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
      ),
    );

    return AppKeyboardToolbar(
      focusNodes: [_passwordFocusNode, _confirmPasswordFocusNode],
      onDone: _submit,
      child: page,
    );
  }
}
