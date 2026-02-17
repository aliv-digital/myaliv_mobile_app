import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';

import '../../../../login/widgets/login_bottom_stripes.dart';

import '../bloc/change_password_prepaid_bloc.dart';
import '../bloc/change_password_prepaid_event.dart';
import '../bloc/change_password_prepaid_state.dart';
import '../repository/change_password_prepaid_repository.dart';
import '../theme/change_password_prepaid_theme.dart';
import '../widgets/change_password_prepaid_header_text.dart';
import '../widgets/change_password_prepaid_password_field.dart';
import '../widgets/change_password_prepaid_submit_button.dart';

class ChangePasswordPrepaidScreen extends StatelessWidget {
  const ChangePasswordPrepaidScreen({super.key});

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
      create: (_) => ChangePasswordPrepaidBloc(
        ChangePasswordPrepaidRepository(),
      )..add(const ChangePasswordPrepaidStarted()),
      child: const _ChangePasswordPrepaidView(),
    );
  }
}

class _ChangePasswordPrepaidView extends StatelessWidget {
  const _ChangePasswordPrepaidView();

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: ChangePasswordPrepaidTheme.bg,

      // ✅ keep default keyboard behavior (auto resize + auto scroll)
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child:
            BlocListener<ChangePasswordPrepaidBloc, ChangePasswordPrepaidState>(
          listenWhen: (p, c) =>
              p.status != c.status || p.errorMessage != c.errorMessage,
          listener: (context, state) {
            if (state.status == ChangePasswordPrepaidStatus.success) {
              // TODO: success navigation/snackbar (তুমি বসাবে)
            }

            if (state.status == ChangePasswordPrepaidStatus.failure &&
                (state.errorMessage ?? '').isNotEmpty) {
              // TODO: failure snackbar/toast (তুমি বসাবে)
            }
          },
          child: Column(
            children: [
              // ---------- Scrollable content ----------
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: DefaultAppBar(
                        title: 'change password',
                        showHome: false,
                        onBack: () {
                          context.pop();
                        },
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(28, 26, 28, 18),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const ChangePasswordPrepaidHeaderText(),
                                const SizedBox(height: 18),
                                BlocBuilder<ChangePasswordPrepaidBloc,
                                    ChangePasswordPrepaidState>(
                                  buildWhen: (p, c) =>
                                      p.newPassword != c.newPassword ||
                                      p.obscureNew != c.obscureNew,
                                  builder: (context, state) {
                                    return ChangePasswordPrepaidPasswordField(
                                      hint: 'new password',
                                      value: state.newPassword,
                                      obscure: state.obscureNew,
                                      onChanged: (v) => context
                                          .read<ChangePasswordPrepaidBloc>()
                                          .add(ChangePasswordPrepaidNewChanged(
                                              v)),
                                      onToggle: () => context
                                          .read<ChangePasswordPrepaidBloc>()
                                          .add(
                                              const ChangePasswordPrepaidToggleNewVisibility()),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                BlocBuilder<ChangePasswordPrepaidBloc,
                                    ChangePasswordPrepaidState>(
                                  buildWhen: (p, c) =>
                                      p.confirmPassword != c.confirmPassword ||
                                      p.obscureConfirm != c.obscureConfirm,
                                  builder: (context, state) {
                                    return ChangePasswordPrepaidPasswordField(
                                      hint: 'confirm new password',
                                      value: state.confirmPassword,
                                      obscure: state.obscureConfirm,
                                      onChanged: (v) => context
                                          .read<ChangePasswordPrepaidBloc>()
                                          .add(
                                              ChangePasswordPrepaidConfirmChanged(
                                                  v)),
                                      onToggle: () => context
                                          .read<ChangePasswordPrepaidBloc>()
                                          .add(
                                              const ChangePasswordPrepaidToggleConfirmVisibility()),
                                    );
                                  },
                                ),
                                const SizedBox(height: 38),
                                BlocBuilder<ChangePasswordPrepaidBloc,
                                    ChangePasswordPrepaidState>(
                                  buildWhen: (p, c) =>
                                      p.status != c.status ||
                                      p.isValid != c.isValid,
                                  builder: (context, state) {
                                    final isLoading = state.status ==
                                        ChangePasswordPrepaidStatus.submitting;

                                    return ChangePasswordPrepaidSubmitButton(
                                      label: 'change password',
                                      enabled: !isLoading,
                                      isLoading: isLoading,
                                      onTap: () => context
                                          .read<ChangePasswordPrepaidBloc>()
                                          .add(
                                              const ChangePasswordPrepaidSubmitPressed()),
                                    );
                                  },
                                ),
                                const SizedBox(height: 260),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Bottom stripes vanish when keyboard opens
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
