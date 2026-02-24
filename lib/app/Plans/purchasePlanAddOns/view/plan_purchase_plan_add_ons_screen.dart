import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../resources/widgets/default_app_bar.dart';
import '../bloc/plan_purchase_plan_add_ons_bloc.dart';
import '../bloc/plan_purchase_plan_add_ons_event.dart';
import '../bloc/plan_purchase_plan_add_ons_state.dart';
import '../repository/plan_purchase_plan_add_ons_repository.dart';
import '../theme/plan_purchase_plan_add_ons_theme.dart';
import '../widgets/plan_purchase_add_on_tile.dart';
import '../widgets/plan_purchase_bottom_checkout_bar.dart';
import '../widgets/plan_purchase_fair_use_policy_card.dart';
import '../widgets/plan_purchase_plan_red_image_card.dart';

class PlanPurchasePlanAddOnsScreen extends StatelessWidget {
  const PlanPurchasePlanAddOnsScreen({super.key});

  // final VoidCallback onSkip;
  // final VoidCallback onProceed;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => PlanPurchasePlanAddOnsRepository(),
      child: BlocProvider(
        create: (ctx) => PlanPurchasePlanAddOnsBloc(
          repository: ctx.read<PlanPurchasePlanAddOnsRepository>(),
        )..add(const PlanPurchasePlanAddOnsStarted()),
        child: _PlanPurchasePlanAddOnsView(
          onSkip: () => context.push(AppRoutes.confirmation),
          onProceed: () => context.push(AppRoutes.confirmation),
        ),
      ),
    );
  }
}

class _PlanPurchasePlanAddOnsView extends StatelessWidget {
  const _PlanPurchasePlanAddOnsView({
    required this.onSkip,
    required this.onProceed,
  });

  final VoidCallback onSkip;
  final VoidCallback onProceed;
  static const double _contentHorizontalPadding = 25;
  //static const _bg = Color(0xFFF1F2FA);
  @override
  Widget build(BuildContext context) {
    return BlocListener<
      PlanPurchasePlanAddOnsBloc,
      PlanPurchasePlanAddOnsState
    >(
      listenWhen: (p, c) =>
          p.skipRequestId != c.skipRequestId ||
          p.proceedRequestId != c.proceedRequestId,
      listener: (context, state) {
        if (state.skipRequestId > 0) onSkip();
        if (state.proceedRequestId > 0) onProceed();
      },
      child: Scaffold(
        backgroundColor: PlanPurchasePlanAddOnsTheme.bg,
        bottomNavigationBar:
            BlocBuilder<
              PlanPurchasePlanAddOnsBloc,
              PlanPurchasePlanAddOnsState
            >(
              builder: (context, state) {
                if (state.status != PlanPurchasePlanAddOnsStatus.ready) {
                  return const SizedBox.shrink();
                }
                return PlanPurchaseBottomPayBar(
                  buttonText: 'proceed',
                  amountText: '\$ ${state.totalPrice.toStringAsFixed(2)}',
                  onPayNow: () {
                    context.read<PlanPurchasePlanAddOnsBloc>().add(
                      const PlanPurchasePlanAddOnsProceedPressed(),
                    );
                  },
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
                  debugPrint('[PlanPurchasePlanAddOns] skip tapped');
                  //context.read<PlanPurchasePlanAddOnsBloc>().add(const PlanPurchasePlanAddOnsSkipPressed());
                  context.push(AppRoutes.confirmation);
                },
                  onHomeTap: () => context.go(AppRoutes.home)

              ),
              Expanded(
                child:
                    BlocBuilder<
                      PlanPurchasePlanAddOnsBloc,
                      PlanPurchasePlanAddOnsState
                    >(
                      builder: (context, state) {
                        if (state.status ==
                                PlanPurchasePlanAddOnsStatus.loading ||
                            state.status ==
                                PlanPurchasePlanAddOnsStatus.initial) {
                          return const Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }

                        if (state.status ==
                            PlanPurchasePlanAddOnsStatus.error) {
                          return Center(
                            child: Text(
                              state.errorMessage ?? 'Failed to load',
                              style: PlanPurchasePlanAddOnsTheme.t(
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
                            // SvgPicture.asset(

                            //     AssetConstant.staticRedCreditCard
                            // ),
                            PlanPurchasePlanRedImageCard(
                              planLabel: plan.label,
                              planName: plan.name,
                              activeLabel: plan.activeDateLabel,
                              activeDate: plan.activeDate,
                              expireLabel: plan.expireDateLabel,
                              expireDate: plan.expireDate,
                            ),
                            const SizedBox(height: 16),
                            PlanPurchaseFairUsePolicyCard(
                              policy: policy,
                              onTap: () {},
                            ),
                            const SizedBox(height: 16),

                            // Add-on list
                            ...state.addOns.map((item) {
                              final selected = state.selectedAddOnIds.contains(
                                item.id,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: PlanPurchaseAddOnTile(
                                  item: item,
                                  selected: selected,
                                  onChanged: (v) => context
                                      .read<PlanPurchasePlanAddOnsBloc>()
                                      .add(
                                        PlanPurchasePlanAddOnsSelectionToggled(
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
