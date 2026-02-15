import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../resources/widgets/default_app_bar.dart';
import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../bloc/guest_purchase_plan_add_ons_bloc.dart';
import '../bloc/guest_purchase_plan_add_ons_event.dart';
import '../bloc/guest_purchase_plan_add_ons_state.dart';
import '../repository/guest_purchase_plan_add_ons_repository.dart';
import '../theme/guest_purchase_plan_add_ons_theme.dart';
import '../widgets/add_on_tile.dart';
import '../widgets/fair_use_policy_card.dart';
import '../widgets/plan_red_image_card.dart';

class GuestPurchasePlanAddOnsScreen extends StatelessWidget {
  const GuestPurchasePlanAddOnsScreen({super.key});

  // final VoidCallback onSkip;
  // final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => GuestPurchasePlanAddOnsRepository(),
      child: BlocProvider(
        create: (ctx) => GuestPurchasePlanAddOnsBloc(
          repository: ctx.read<GuestPurchasePlanAddOnsRepository>(),
        )..add(const GuestPurchasePlanAddOnsStarted()),
        child: _GuestPurchasePlanAddOnsView(
          onSkip: () => context.push(AppRoutes.guestPurchasePlanConfirmation),
          onProceed: () =>
              context.push(AppRoutes.guestPurchasePlanConfirmation),
        ),
      ),
    );
  }
}

class _GuestPurchasePlanAddOnsView extends StatelessWidget {
  const _GuestPurchasePlanAddOnsView({
    required this.onSkip,
    required this.onProceed,
  });

  final VoidCallback onSkip;
  final VoidCallback onProceed;
  static const double _contentHorizontalPadding = 25;
  //static const _bg = Color(0xFFF1F2FA);
  @override
  Widget build(BuildContext context) {
    return BlocListener<GuestPurchasePlanAddOnsBloc,
        GuestPurchasePlanAddOnsState>(
      listenWhen: (p, c) =>
          p.skipRequestId != c.skipRequestId ||
          p.proceedRequestId != c.proceedRequestId,
      listener: (context, state) {
        if (state.skipRequestId > 0) onSkip();
        if (state.proceedRequestId > 0) onProceed();
      },
      child: Scaffold(
        backgroundColor: GuestPurchasePlanAddOnsTheme.bg,
        bottomNavigationBar: BlocBuilder<GuestPurchasePlanAddOnsBloc,
            GuestPurchasePlanAddOnsState>(
          builder: (context, state) {
            if (state.status != GuestPurchasePlanAddOnsStatus.ready) {
              return const SizedBox.shrink();
            }
            return DefaultBottomPayBar(
              isVatExclusive: true,
              buttonText: 'proceed',
              amountText: '\$ ${state.totalPrice.toStringAsFixed(2)}',
              onPayNow: () => context
                  .read<GuestPurchasePlanAddOnsBloc>()
                  .add(const GuestPurchasePlanAddOnsProceedPressed()),
            );
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              DefaultAppBar(
                title: 'add-ons',
                showBackArrow: false,
                actionText: 'skip',
                onActionTextTap: () {
                  debugPrint('[GuestPurchasePlanAddOns] skip tapped');
                  //context.read<GuestPurchasePlanAddOnsBloc>().add(const GuestPurchasePlanAddOnsSkipPressed());
                  context.push(AppRoutes.guestPurchasePlanConfirmation);
                },
              ),
              Expanded(
                child: BlocBuilder<GuestPurchasePlanAddOnsBloc,
                    GuestPurchasePlanAddOnsState>(
                  builder: (context, state) {
                    if (state.status == GuestPurchasePlanAddOnsStatus.loading ||
                        state.status == GuestPurchasePlanAddOnsStatus.initial) {
                      return const Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (state.status == GuestPurchasePlanAddOnsStatus.error) {
                      return Center(
                        child: Text(
                          state.errorMessage ?? 'Failed to load',
                          style: GuestPurchasePlanAddOnsTheme.t(
                            13,
                            weight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    final plan = state.activePlan!;
                    final policy = state.fairUsePolicy!;

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        _contentHorizontalPadding,
                        20,
                        _contentHorizontalPadding,
                        16,
                      ),
                      children: [
                        PlanRedImageCard(
                          planLabel: plan.label,
                          planName: plan.name,
                          activeLabel: plan.activeDateLabel,
                          activeDate: plan.activeDate,
                          expireLabel: plan.expireDateLabel,
                          expireDate: plan.expireDate,
                        ),
                        const SizedBox(height: 16),
                        FairUsePolicyCard(policy: policy, onTap: () {}),
                        const SizedBox(height: 16),

                        // Add-on list
                        ...state.addOns.map((item) {
                          final selected = state.selectedAddOnIds.contains(
                            item.id,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AddOnTile(
                              item: item,
                              selected: selected,
                              onChanged: (v) => context
                                  .read<GuestPurchasePlanAddOnsBloc>()
                                  .add(
                                    GuestPurchasePlanAddOnsSelectionToggled(
                                      addOnId: item.id,
                                      selected: v,
                                    ),
                                  ),
                            ),
                          );
                        }),
                        const SizedBox(height: 4),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
