import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../../Home/home/home_screen.dart';
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

  // ✅ DefaultAppBar actual height is 56 in your logs
  static const double _appBarHeight = 56.0;

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
          // TODO: integrate router/go_router for home navigation
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
                slivers: [
                  /// ✅ Pinned DefaultAppBar in sliver (like your SliverAppBar pinned)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PinnedHeaderDelegate(
                      height: _appBarHeight, // ✅ MUST match actual rendered height
                      child: DefaultAppBar(
                        showHome: true,
                        title: 'auto renew',
                        onBack: () => Navigator.of(context).maybePop(),
                        onHomeTap: () => bloc.add(const AutoRenewHomePressed()),
                      ),
                    ),
                  ),

                  if (state.loadStatus == AutoRenewLoadStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 18),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoRenewPaymentMethodSection(
                              methods: state.methods,
                              selectedMethodId: state.selectedMethodId,
                              onSelect: (id) =>
                                  bloc.add(AutoRenewMethodSelected(id)),
                            ),
                            const SizedBox(height: 24),
                            DashedAddCardButton(
                              onTap: () =>
                                  bloc.add(const AutoRenewAddNewCardPressed()),
                            ),
                            const SizedBox(height: 24),
                            _ProceedButton(
                              enabled: state.canProceed,
                              loading: state.savingSelection,
                              onTap: () {
                                //bloc.add(const AutoRenewProceedPressed());
                                context.push(AppRoutes.autoRenewAuthPrepaidScreen);
                              }
                            ),
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
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
          AutoRenewPrepaidTheme.primary.withValues(alpha: enabled ? 1 : 0.45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
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
        ) :
        config.userType == UserType.postpaid? const Text(
          'use for auto pay',
          style: TextStyle(
            color: const Color(0xFFF1F1F8),
            fontSize: 13,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ):const Text(
          'proceed',
          style: TextStyle(
            color: const Color(0xFFF1F1F8),
            fontSize: 13,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// ✅ Pinned header delegate for sticky DefaultAppBar inside slivers
class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _PinnedHeaderDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // ✅ Ensure the header always reports EXACT same size as extents
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
