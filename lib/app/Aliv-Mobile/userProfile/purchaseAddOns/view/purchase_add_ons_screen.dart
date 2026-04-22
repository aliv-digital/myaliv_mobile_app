import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/purchase_add_ons_bloc.dart';
import '../bloc/purchase_add_ons_event.dart';
import '../bloc/purchase_add_ons_state.dart';
import '../model/purchase_add_ons_route_args.dart';
import '../repository/purchase_add_ons_repository.dart';
import '../theme/purchase_add_ons_theme.dart';
import '../widgets/purchase_add_ons_bottom_checkout_bar.dart';
import '../widgets/purchase_add_ons_tab_content.dart';

class PurchaseAddOnsScreen extends StatelessWidget {
  final ValueChanged<PurchaseAddOnsRouteArgs>? onSkip;
  final ValueChanged<PurchaseAddOnsRouteArgs>? onProceed;

  const PurchaseAddOnsScreen({super.key, this.onSkip, this.onProceed});

  @override
  Widget build(BuildContext context) {
    final plansState = context.read<PlansCubit>().state;

    return RepositoryProvider(
      create: (_) => const PurchaseAddOnsRepository(),
      child: BlocProvider(
        create: (ctx) =>
            PurchaseAddOnsBloc(repository: ctx.read<PurchaseAddOnsRepository>())
              ..add(PurchaseAddOnsStarted(plansState: plansState)),
        child: _PurchaseAddOnsView(onSkip: onSkip, onProceed: onProceed),
      ),
    );
  }
}

class _PurchaseAddOnsView extends StatelessWidget {
  final ValueChanged<PurchaseAddOnsRouteArgs>? onSkip;
  final ValueChanged<PurchaseAddOnsRouteArgs>? onProceed;

  const _PurchaseAddOnsView({this.onSkip, this.onProceed});

  static const String _defaultPhone = '242-801-1616';
  static const String _defaultAccountHolder = 'purchase add-ons';
  static const double _defaultPrimaryPlanPrice = 75;

  bool _shouldSyncFromPlans(PlansState previous, PlansState current) {
    return previous.earliestAddOnsPrimaryPlan !=
            current.earliestAddOnsPrimaryPlan ||
        previous.addOns != current.addOns ||
        previous.selectedAddOnIds != current.selectedAddOnIds;
  }

  void _syncFromPlansState(BuildContext context, PlansState plansState) {
    context.read<PurchaseAddOnsBloc>().add(
          PurchaseAddOnsStarted(plansState: plansState),
        );
  }

  void _toggleAddOn(BuildContext context, String addOnId) {
    final plansCubit = context.read<PlansCubit>();
    final matchingPlanAddOns =
        plansCubit.state.addOns.where((addOn) => addOn.id == addOnId).toList();

    if (matchingPlanAddOns.isNotEmpty) {
      plansCubit.toggleAddon(matchingPlanAddOns.first);
      return;
    }

    final purchaseBloc = context.read<PurchaseAddOnsBloc>();
    final selected = purchaseBloc.state.selectedAddOnIds.contains(addOnId);
    purchaseBloc.add(
      PurchaseAddOnsSelectionToggled(addOnId: addOnId, selected: !selected),
    );
  }

  double _extractPrimaryPlanPrice(String planName) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(planName);
    if (match == null) {
      return _defaultPrimaryPlanPrice;
    }

    return double.tryParse(match.group(1) ?? '') ?? _defaultPrimaryPlanPrice;
  }

  PurchaseAddOnsRouteArgs _routeArgsFromState(
    PurchaseAddOnsState state, {
    required PurchaseAddOnsEntryFlow flow,
  }) {
    final activePlan = state.activePrimaryPlan;
    final primaryPlanName = activePlan?.name ?? 'liberty70';
    final primaryPlanPrice = _extractPrimaryPlanPrice(primaryPlanName);

    final selectedAddOns = state.addOns
        .where((item) => state.selectedAddOnIds.contains(item.id))
        .map(
          (item) => PurchaseAddOnsSelectedAddOn(
            id: item.id,
            title: item.title,
            price: item.price,
          ),
        )
        .toList();

    return PurchaseAddOnsRouteArgs(
      phoneNumber: _defaultPhone,
      accountHolderName: _defaultAccountHolder,
      primaryPlanName: primaryPlanName,
      primaryPlanPrice: primaryPlanPrice,
      flow: flow,
      selectedAddOns: selectedAddOns,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PlansCubit, PlansState>(
          listenWhen: _shouldSyncFromPlans,
          listener: _syncFromPlansState,
        ),
        BlocListener<PurchaseAddOnsBloc, PurchaseAddOnsState>(
          listenWhen: (previous, current) =>
              previous.skipRequestId != current.skipRequestId,
          listener: (context, state) {
            final args = _routeArgsFromState(
              state,
              flow: PurchaseAddOnsEntryFlow.skip,
            );
            if (onSkip != null) {
              onSkip!(args);
            } else {
              debugPrint('[PurchaseAddOns] skip requested: $args');
            }
          },
        ),
        BlocListener<PurchaseAddOnsBloc, PurchaseAddOnsState>(
          listenWhen: (previous, current) =>
              previous.proceedRequestId != current.proceedRequestId,
          listener: (context, state) {
            final args = _routeArgsFromState(
              state,
              flow: PurchaseAddOnsEntryFlow.proceed,
            );
            if (onProceed != null) {
              onProceed!(args);
            } else {
              debugPrint('[PurchaseAddOns] proceed requested: $args');
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: PurchaseAddOnsTheme.bg,
        bottomNavigationBar:
            BlocBuilder<PurchaseAddOnsBloc, PurchaseAddOnsState>(
          builder: (context, state) {
            return PurchaseAddOnsBottomPayBar(
              state: state,
              onPayNow: () {
                context.read<PurchaseAddOnsBloc>().add(
                      const PurchaseAddOnsProceedPressed(),
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
                showBackArrow: true,
                actionText:
                    AppSession.appRoute == 'addOnsPrepaid' ? null : 'skip',
                onActionTextTap: () {
                  context.read<PurchaseAddOnsBloc>().add(
                        const PurchaseAddOnsSkipPressed(),
                      );
                },
                onHomeTap: () => context.go(AppRoutes.home),
              ),
              Expanded(
                child: BlocBuilder<PurchaseAddOnsBloc, PurchaseAddOnsState>(
                  builder: (context, state) {
                    if (state.status == PurchaseAddOnsStatus.loading ||
                        state.status == PurchaseAddOnsStatus.initial) {
                      return const Center(
                        child: SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (state.status == PurchaseAddOnsStatus.error) {
                      return Center(
                        child: Text(
                          state.errorMessage ?? 'Failed to load',
                          style: PurchaseAddOnsTheme.t(
                            13,
                            weight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    return PurchaseAddOnsTabContent(
                      activePrimaryPlan: state.activePrimaryPlan,
                      addOns: state.addOns,
                      selectedAddOnIds: state.selectedAddOnIds,
                      onToggleAddOn: (addOn) {
                        _toggleAddOn(context, addOn.id);
                      },
                      onAutoRenewChanged: (value) {
                        context.read<PurchaseAddOnsBloc>().add(
                              PurchaseAddOnsAutoRenewToggled(value),
                            );
                      },
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
