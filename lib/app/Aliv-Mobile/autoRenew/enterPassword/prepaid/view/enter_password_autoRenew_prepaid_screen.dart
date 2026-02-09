import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../login/widgets/login_bottom_stripes.dart';
import '../bloc/enter_password_autoRenew_prepaid_bloc.dart';
import '../bloc/enter_password_autoRenew_prepaid_event.dart';
import '../bloc/enter_password_autoRenew_prepaid_state.dart';
import '../repository/enter_password_autoRenew_prepaid_repository.dart';
import '../theme/enter_password_autoRenew_prepaid_theme.dart';
import '../widgets/enter_password_autoRenew_prepaid_biometric_buttons.dart';
import '../widgets/enter_password_autoRenew_continue_button.dart';
import '../widgets/enter_password_autoRenew_prepaid_header.dart';
import '../widgets/enter_password_autoRenew_prepaid_or_divider.dart';
import '../widgets/enter_password_prepaid_password_input.dart';
import '../widgets/enter_password_prepaid_terms_text.dart';

class EnterPasswordAutoRenewPrepaidScreen extends StatelessWidget {
  const EnterPasswordAutoRenewPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return BlocProvider(
      create: (_) => EnterPasswordAutoRenewPrepaidBloc(
        EnterPasswordAutoRenewPrepaidRepository(),
      )..add(const EnterPasswordAutoRenewPrepaidStarted()),
      child: const _EnterPasswordAutoRenewPrepaidView(),
    );
  }
}

class _EnterPasswordAutoRenewPrepaidView extends StatelessWidget {
  const _EnterPasswordAutoRenewPrepaidView();

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: EnterPasswordAutoRenewPrepaidTheme.bg,

      // ✅ keep default keyboard behavior
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: BlocListener<EnterPasswordAutoRenewPrepaidBloc,
            EnterPasswordAutoRenewPrepaidState>(
          listenWhen: (p, c) =>
              p.status != c.status || p.errorMessage != c.errorMessage,
          listener: (context, state) {
            if (state.status == EnterPasswordAutoRenewPrepaidStatus.success) {
              // TODO: success navigation (go_router) তুমি বসাবে
            }
            if (state.status == EnterPasswordAutoRenewPrepaidStatus.failure &&
                (state.errorMessage ?? '').isNotEmpty) {
              // TODO: snackbar/toast তুমি বসাবে
            }
          },
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: DefaultAppBar(
                        title: 'Call Log Security',
                        showHome: false,
                        onBack: () {
                          context.pop();
                        },
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(42, 92, 42, 18),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              children: [
                                const EnterPasswordAutoRenewPrepaidHeader(),
                                const SizedBox(height: 28),
                                BlocBuilder<
                                  EnterPasswordAutoRenewPrepaidBloc,
                                  EnterPasswordAutoRenewPrepaidState
                                >(
                                  buildWhen: (p, c) =>
                                      p.password != c.password ||
                                      p.obscure != c.obscure,
                                  builder: (context, state) {
                                    return EnterPasswordAutoRenewPrepaidPasswordInput(
                                      value: state.password,
                                      obscure: state.obscure,
                                      onChanged: (v) => context
                                          .read<
                                              EnterPasswordAutoRenewPrepaidBloc>()
                                          .add(
                                            EnterPasswordAutoRenewPrepaidPasswordChanged(
                                              v,
                                            ),
                                          ),
                                      onToggle: () => context
                                          .read<
                                              EnterPasswordAutoRenewPrepaidBloc>()
                                          .add(
                                            const EnterPasswordAutoRenewPrepaidToggleObscure(),
                                          ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                const EnterPasswordAutoRenewPrepaidTermsText(),
                                const SizedBox(height: 30),
                                BlocBuilder<
                                  EnterPasswordAutoRenewPrepaidBloc,
                                  EnterPasswordAutoRenewPrepaidState
                                >(
                                  buildWhen: (p, c) =>
                                      p.status != c.status ||
                                      p.isValid != c.isValid,
                                  builder: (context, state) {
                                    final isLoading = state.status ==
                                        EnterPasswordAutoRenewPrepaidStatus
                                            .submitting;

                                    return EnterPasswordAutoRenewPrepaidContinueButton(
                                      isLoading: isLoading,
                                      enabled: state.isValid && !isLoading,
                                      onTap: () {
                                        context
                                            .read<
                                                EnterPasswordAutoRenewPrepaidBloc>()
                                            .add(
                                              const EnterPasswordAutoRenewPrepaidContinuePressed(),
                                            );

                                        context.push(
                                          AppRoutes.otpAutoRenewPrepaidScreen,
                                        );
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 22),
                                const EnterPasswordAutoRenewPrepaidOrDivider(),
                                const SizedBox(height: 30),
                                EnterPasswordAutoRenewPrepaidBiometricButtons(
                                  onFaceId: () => context
                                      .read<EnterPasswordAutoRenewPrepaidBloc>()
                                      .add(
                                        const EnterPasswordAutoRenewPrepaidFaceIdPressed(),
                                      ),
                                  onFingerprint: () => context
                                      .read<EnterPasswordAutoRenewPrepaidBloc>()
                                      .add(
                                        const EnterPasswordAutoRenewPrepaidFingerprintPressed(),
                                      ),
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

              // ✅ Bottom stripes vanish (not move up) when keyboard opens
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: keyboardOpen
                    ? const SizedBox.shrink()
                    : const BottomStripes(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
