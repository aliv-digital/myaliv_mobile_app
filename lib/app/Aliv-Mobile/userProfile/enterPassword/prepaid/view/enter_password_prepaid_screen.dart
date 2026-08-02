import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../bloc/enter_password_prepaid_bloc.dart';
import '../bloc/enter_password_prepaid_event.dart';
import '../bloc/enter_password_prepaid_state.dart';
import '../repository/enter_password_prepaid_repository.dart';
import '../theme/enter_password_prepaid_theme.dart';
import '../widgets/enter_password_prepaid_biometric_buttons.dart';
import '../widgets/enter_password_prepaid_continue_button.dart';
import '../widgets/enter_password_prepaid_header.dart';
import '../widgets/enter_password_prepaid_or_divider.dart';
import '../widgets/enter_password_prepaid_password_input.dart';
import '../widgets/enter_password_prepaid_terms_text.dart';

class EnterPasswordPrepaidScreen extends StatelessWidget {
  const EnterPasswordPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnterPasswordPrepaidBloc(EnterPasswordPrepaidRepository())
        ..add(const EnterPasswordPrepaidStarted()),
      child: const _EnterPasswordPrepaidView(),
    );
  }
}

class _EnterPasswordPrepaidView extends StatelessWidget {
  const _EnterPasswordPrepaidView();

  @override
  Widget build(BuildContext context) {
    return StripedScaffold(
      backgroundColor: EnterPasswordPrepaidTheme.bg,

      // ✅ keep default keyboard behavior (auto resize + auto scroll)
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        top: false,
        child:
            BlocListener<EnterPasswordPrepaidBloc, EnterPasswordPrepaidState>(
          listenWhen: (p, c) =>
              p.status != c.status || p.errorMessage != c.errorMessage,
          listener: (context, state) {
            if (state.status == EnterPasswordPrepaidStatus.success) {
              // TODO: success navigation (go_router) তুমি বসাবে
            }
            if (state.status == EnterPasswordPrepaidStatus.failure &&
                (state.errorMessage ?? '').isNotEmpty) {
              // TODO: snackbar/toast তুমি বসাবে
            }
          },
          child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: DefaultAppBar(
                        title: 'security check',
                        showHome: false,
                        onBack: () {
                          context.pop();
                        },
                          onHomeTap: () => context.go(AppRoutes.home)

                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(47, 93, 47, 18),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              children: [
                                const EnterPasswordPrepaidHeader(),
                                const SizedBox(height: 27),
                                BlocBuilder<EnterPasswordPrepaidBloc,
                                    EnterPasswordPrepaidState>(
                                  buildWhen: (p, c) =>
                                      p.password != c.password ||
                                      p.obscure != c.obscure,
                                  builder: (context, state) {
                                    return EnterPasswordPrepaidPasswordInput(
                                      value: state.password,
                                      obscure: state.obscure,
                                      onChanged: (v) => context
                                          .read<EnterPasswordPrepaidBloc>()
                                          .add(
                                              EnterPasswordPrepaidPasswordChanged(
                                                  v)),
                                      onToggle: () => context
                                          .read<EnterPasswordPrepaidBloc>()
                                          .add(
                                              const EnterPasswordPrepaidToggleObscure()),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                const EnterPasswordPrepaidTermsText(),
                                const SizedBox(height: 30),
                                BlocBuilder<EnterPasswordPrepaidBloc,
                                    EnterPasswordPrepaidState>(
                                  buildWhen: (p, c) =>
                                      p.status != c.status ||
                                      p.isValid != c.isValid,
                                  builder: (context, state) {
                                    final isLoading = state.status ==
                                        EnterPasswordPrepaidStatus.submitting;

                                    return EnterPasswordPrepaidContinueButton(
                                      isLoading: isLoading,
                                      // Keep the button visually active from initial state.
                                      enabled: !isLoading,
                                      onTap: () {
                                        // if (!state.isValid) {
                                        //   ScaffoldMessenger.of(context)
                                        //     ..hideCurrentSnackBar()
                                        //     ..showSnackBar(
                                        //       const SnackBar(
                                        //         content: Text(
                                        //           'Please enter your password to continue.',
                                        //         ),
                                        //       ),
                                        //     );
                                        //   return;
                                        // }

                                        context
                                            .read<EnterPasswordPrepaidBloc>()
                                            .add(
                                                const EnterPasswordPrepaidContinuePressed());

                                        context.push(
                                            AppRoutes.otpProfilePrepaidScreen);
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 38),
                                const EnterPasswordPrepaidOrDivider(),
                                const SizedBox(height: 30),
                                EnterPasswordPrepaidBiometricButtons(
                                  onFaceId: () => context
                                      .read<EnterPasswordPrepaidBloc>()
                                      .add(
                                          const EnterPasswordPrepaidFaceIdPressed()),
                                  onFingerprint: () => context
                                      .read<EnterPasswordPrepaidBloc>()
                                      .add(
                                          const EnterPasswordPrepaidFingerprintPressed()),
                                ),
                                const SizedBox(height: 180),
                              ],
                            ),
                          ),
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
