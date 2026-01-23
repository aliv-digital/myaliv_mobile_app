import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../login/widgets/login_bottom_stripes.dart';
import '../bloc/enter_password_postpaid_bloc.dart';
import '../bloc/enter_password_postpaid_event.dart';
import '../bloc/enter_password_postpaid_state.dart';
import '../repository/enter_password_postpaid_repository.dart';
import '../theme/enter_password_postpaid_theme.dart';
import '../widgets/enter_password_postpaid_biometric_buttons.dart';
import '../widgets/enter_password_postpaid_continue_button.dart';
import '../widgets/enter_password_postpaid_header.dart';
import '../widgets/enter_password_postpaid_or_divider.dart';
import '../widgets/enter_password_postpaid_password_input.dart';
import '../widgets/enter_password_postpaid_terms_text.dart';

class EnterPasswordPostpaidScreen extends StatelessWidget {
  const EnterPasswordPostpaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return BlocProvider(
      create: (_) => EnterPasswordPostpaidBloc(EnterPasswordPostpaidRepository())
        ..add(const EnterPasswordPostpaidStarted()),
      child: const _EnterPasswordPostpaidView(),
    );
  }
}

class _EnterPasswordPostpaidView extends StatelessWidget {
  const _EnterPasswordPostpaidView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnterPasswordPostpaidTheme.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<EnterPasswordPostpaidBloc, EnterPasswordPostpaidState>(
          listenWhen: (p, c) =>
          p.status != c.status || p.errorMessage != c.errorMessage,
          listener: (context, state) {
            if (state.status == EnterPasswordPostpaidStatus.success) {
             // continue
              context.push(AppRoutes.otpReviewInvoicePostPaidScreen);
            }
            if (state.status == EnterPasswordPostpaidStatus.failure &&
                (state.errorMessage ?? '').isNotEmpty) {
              // TODO: snackbar/toast তুমি বসাবে
            }
          },
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: DefaultAppBar(
                        title: 'review invoices',
                        showHome: false,
                        onBack: () {
                          context.pop();
                          // context
                          //     .read<EnterPasswordPostpaidBloc>()
                          //     .add(const EnterPasswordPostpaidBackPressed());
                        },
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(28, 34, 28, 18),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              children: [
                                const EnterPasswordPostpaidHeader(),
                                const SizedBox(height: 22),

                                BlocBuilder<EnterPasswordPostpaidBloc, EnterPasswordPostpaidState>(
                                  buildWhen: (p, c) =>
                                  p.password != c.password ||
                                      p.obscure != c.obscure,
                                  builder: (context, state) {
                                    return EnterPasswordPostpaidPasswordInput(
                                      value: state.password,
                                      obscure: state.obscure,
                                      onChanged: (v) => context
                                          .read<EnterPasswordPostpaidBloc>()
                                          .add(EnterPasswordPostpaidPasswordChanged(v)),
                                      onToggle: () => context
                                          .read<EnterPasswordPostpaidBloc>()
                                          .add(const EnterPasswordPostpaidToggleObscure()),
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),
                                const EnterPasswordPostpaidTermsText(),
                                const SizedBox(height: 18),

                                BlocBuilder<EnterPasswordPostpaidBloc, EnterPasswordPostpaidState>(
                                  buildWhen: (p, c) =>
                                  p.status != c.status ||
                                      p.isValid != c.isValid,
                                  builder: (context, state) {
                                    final isLoading = state.status == EnterPasswordPostpaidStatus.submitting;

                                    return EnterPasswordPostpaidContinueButton(
                                      isLoading: isLoading,
                                      enabled: state.isValid && !isLoading,
                                      onTap: () {
                                        context.read<EnterPasswordPostpaidBloc>().add(
                                            const EnterPasswordPostpaidContinuePressed()
                                        );

                                      },
                                    );
                                  },
                                ),

                                const SizedBox(height: 22),
                                const EnterPasswordPostpaidOrDivider(),
                                const SizedBox(height: 18),

                                EnterPasswordPostpaidBiometricButtons(
                                  onFaceId: () => context
                                      .read<EnterPasswordPostpaidBloc>()
                                      .add(const EnterPasswordPostpaidFaceIdPressed()),
                                  onFingerprint: () => context
                                      .read<EnterPasswordPostpaidBloc>()
                                      .add(const EnterPasswordPostpaidFingerprintPressed()),
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
              const BottomStripes(),
            ],
          ),
        ),
      ),
    );
  }
}
