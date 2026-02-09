import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../login/widgets/login_bottom_stripes.dart';
import '../bloc/edit_email_prepaid_bloc.dart';
import '../bloc/edit_email_prepaid_event.dart';
import '../bloc/edit_email_prepaid_state.dart';
import '../repository/edit_email_prepaid_repository.dart';
import '../theme/edit_email_prepaid_theme.dart';
import '../widgets/edit_email_prepaid_email_input.dart';
import '../widgets/edit_email_prepaid_info_field.dart';
import '../widgets/edit_email_prepaid_save_button.dart';

class EditEmailPrepaidScreen extends StatelessWidget {
  const EditEmailPrepaidScreen({super.key});

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
      create: (_) => EditEmailPrepaidBloc(EditEmailPrepaidRepository())
        ..add(const EditEmailPrepaidStarted()),
      child: const _EditEmailPrepaidView(),
    );
  }
}

class _EditEmailPrepaidView extends StatelessWidget {
  const _EditEmailPrepaidView();

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: EditEmailPrepaidTheme.bg,

      // ✅ keep default keyboard behavior (auto resize + auto scroll)
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: BlocListener<EditEmailPrepaidBloc, EditEmailPrepaidState>(
          listenWhen: (p, c) =>
              p.status != c.status || p.errorMessage != c.errorMessage,
          listener: (context, state) {
            if (state.status == EditEmailPrepaidStatus.success) {
              // optional: success toast/snackbar ( তুমি চাইলে বসাবে )
            }
            if (state.status == EditEmailPrepaidStatus.failure &&
                (state.errorMessage ?? '').isNotEmpty) {
              // optional: failure toast/snackbar ( তুমি চাইলে বসাবে )
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
                        title: 'edit email',
                        showHome: true,
                        onHomeTap: () {
                          context.go(AppRoutes.home);
                        },
                        onBack: () {
                          context.pop();
                        },
                      ),
                    ),
                    BlocBuilder<EditEmailPrepaidBloc, EditEmailPrepaidState>(
                      builder: (context, state) {
                        if (state.status == EditEmailPrepaidStatus.loading ||
                            state.status == EditEmailPrepaidStatus.initial) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final data = state.data;
                        if (data == null) {
                          return const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: Text('No data')),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                          sliver: SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 420),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    EditEmailPrepaidInfoField(
                                      label: 'full name',
                                      value: data.fullName,
                                    ),
                                    const SizedBox(height: 16),
                                    EditEmailPrepaidInfoField(
                                      label: 'phone number',
                                      value: data.phoneNumber,
                                    ),
                                    const SizedBox(height: 16),
                                    EditEmailPrepaidInfoField(
                                      label: 'gender',
                                      value: data.gender,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'email address',
                                      style: EditEmailPrepaidTheme.fieldLabel,
                                    ),
                                    const SizedBox(height: 8),
                                    BlocBuilder<EditEmailPrepaidBloc,
                                        EditEmailPrepaidState>(
                                      buildWhen: (p, c) =>
                                          p.email != c.email ||
                                          p.status != c.status,
                                      builder: (context, state) {
                                        return EditEmailPrepaidEmailInput(
                                          initialValue: state.email,
                                          enabled: state.status !=
                                              EditEmailPrepaidStatus.submitting,
                                          onChanged: (v) => context
                                              .read<EditEmailPrepaidBloc>()
                                              .add(EditEmailPrepaidEmailChanged(
                                                  v)),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40),
                        child: BlocBuilder<EditEmailPrepaidBloc,
                            EditEmailPrepaidState>(
                          buildWhen: (p, c) =>
                              p.status != c.status ||
                              p.isEmailValid != c.isEmailValid,
                          builder: (context, state) {
                            final isLoading = state.status ==
                                EditEmailPrepaidStatus.submitting;

                            return EditEmailPrepaidSaveButton(
                              isLoading: isLoading,
                              enabled: state.isEmailValid && !isLoading,
                              onTap: () => context
                                  .read<EditEmailPrepaidBloc>()
                                  .add(const EditEmailPrepaidSavePressed()),
                            );
                          },
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
