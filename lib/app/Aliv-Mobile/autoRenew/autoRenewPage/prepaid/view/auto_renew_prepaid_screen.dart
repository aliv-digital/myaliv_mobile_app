import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';

import '../bloc/auto_renew_prepaid_bloc.dart';
import '../bloc/auto_renew_prepaid_event.dart';
import '../bloc/auto_renew_prepaid_state.dart';
import '../repository/auto_renew_prepaid_repository.dart';
import '../theme/auto_renew_prepaid_theme.dart';
import '../widgets/auto_renew_payment_method_section.dart';
import '../widgets/bottomsheet/add_card_bottom_sheet.dart';
import '../widgets/dashed_add_card_button.dart';

class AutoRenewPrepaidScreen extends StatelessWidget {
  const AutoRenewPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AutoRenewPrepaidBloc(
        repository: AutoRenewPrepaidRepositoryImpl(),
      )..add(const AutoRenewPrepaidStarted()),
      child: const _AutoRenewPrepaidView(),
    );
  }
}

class _AutoRenewPrepaidView extends StatelessWidget {
  const _AutoRenewPrepaidView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AutoRenewPrepaidBloc, AutoRenewPrepaidState>(
      listenWhen: (p, c) =>
      p.errorMessage != c.errorMessage || p.navTarget != c.navTarget,
      listener: (context, state) async {
        final bloc = context.read<AutoRenewPrepaidBloc>();

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        if (state.navTarget == AutoRenewNavTarget.addCard) {
          final result = await AddCardBottomSheet.show(context);
          if (!context.mounted) return;

          if (result != null) {
            bloc.add(
              AutoRenewSaveNewCardPressed(month: result.month, year: result.year),
            );
          }

          bloc.add(const AutoRenewNavigationConsumed());
          return;
        }

        if (state.navTarget == AutoRenewNavTarget.home) {
          // TODO: go_router home route
          bloc.add(const AutoRenewNavigationConsumed());
          return;
        }

        if (state.navTarget == AutoRenewNavTarget.proceed) {
          // TODO: navigate to next screen
          bloc.add(const AutoRenewNavigationConsumed());
          return;
        }
      },
      child: Scaffold(
        backgroundColor: AutoRenewPrepaidTheme.pageBg,
        body: SafeArea(
          child: BlocBuilder<AutoRenewPrepaidBloc, AutoRenewPrepaidState>(
            builder: (context, state) {
              final bloc = context.read<AutoRenewPrepaidBloc>();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: DefaultAppBar(
                      showHome: true,
                      title: 'auto renew',
                      onBack: () => Navigator.of(context).maybePop(),
                      onHomeTap: () => bloc.add(const AutoRenewHomePressed()),
                    ),
                  ),

                  if (state.loadStatus == AutoRenewLoadStatus.loading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            AutoRenewPaymentMethodSection(
                              methods: state.methods,
                              selectedMethodId: state.selectedMethodId,
                              onSelect: (id) => bloc.add(AutoRenewMethodSelected(id)),
                            ),

                            // ✅ Keep buttons "up" after section (not bottom pinned)
                            const SizedBox(height: 18),

                            DashedAddCardButton(
                              onTap: () =>
                                  bloc.add(const AutoRenewAddNewCardPressed()),
                            ),
                            const SizedBox(height: 14),

                            _ProceedButton(
                              enabled: state.canProceed,
                              loading: state.savingSelection,
                              onTap: () =>
                                  bloc.add(const AutoRenewProceedPressed()),
                            ),

                            // ✅ small bottom padding only (not pushing to bottom)
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProceedButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _ProceedButton({
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
          AutoRenewPrepaidTheme.primary.withValues(alpha: enabled ? 1 : 0.45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          elevation: 0,
        ),
        onPressed: enabled ? onTap : null,
        child: loading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          'proceed',
          style: TextStyle(
            fontFamily: AutoRenewPrepaidTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
