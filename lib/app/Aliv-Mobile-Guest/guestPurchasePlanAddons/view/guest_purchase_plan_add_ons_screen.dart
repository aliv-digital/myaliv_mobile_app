import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../core/utils/app_session.dart';
import '../../../../resources/widgets/default_app_bar.dart';
import '../../../../resources/widgets/default_bottom_payBar.dart';
import '../../../Home/widgets/auto_renew_toggle.dart';
import '../../guestPurchasePlanComfirmation/models/guest_purchase_plan_confirmation_models.dart';
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

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => GuestPurchasePlanAddOnsRepository(),
      child: BlocProvider(
        create: (ctx) => GuestPurchasePlanAddOnsBloc(
          repository: ctx.read<GuestPurchasePlanAddOnsRepository>(),
        )..add(const GuestPurchasePlanAddOnsStarted()),
        child: const _GuestPurchasePlanAddOnsView(),
      ),
    );
  }
}

class _GuestPurchasePlanAddOnsView extends StatelessWidget {
  const _GuestPurchasePlanAddOnsView();

  static const double _contentHorizontalPadding = 25;
  static const String _defaultPhone = '242-801-1616';
  static const String _defaultAccountHolder = 'guest purchase a plan';
  static const double _defaultPrimaryPlanPrice = 75;

  double _extractPrimaryPlanPrice(String planName) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(planName);
    if (match == null) {
      return _defaultPrimaryPlanPrice;
    }

    return double.tryParse(match.group(1) ?? '') ?? _defaultPrimaryPlanPrice;
  }

  GuestPurchasePlanConfirmationRouteArgs _routeArgsFromState(
    GuestPurchasePlanAddOnsState state, {
    required GuestPurchasePlanConfirmationEntryFlow flow,
  }) {
    final activePlan = state.activePlan;
    final primaryPlanName = activePlan?.name ?? 'liberty70';
    final primaryPlanPrice = _extractPrimaryPlanPrice(primaryPlanName);

    final selectedAddOns = state.addOns
        .where((item) => state.selectedAddOnIds.contains(item.id))
        .map(
          (item) => GuestPurchasePlanConfirmationSelectedAddOn(
            id: item.id,
            title: item.title,
            price: item.price,
          ),
        )
        .toList();

    return GuestPurchasePlanConfirmationRouteArgs(
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
        BlocListener<GuestPurchasePlanAddOnsBloc, GuestPurchasePlanAddOnsState>(
          listenWhen: (previous, current) =>
              previous.skipRequestId != current.skipRequestId,
          listener: (context, state) {
            context.push(
              AppRoutes.guestPurchasePlanConfirmation,
              extra: _routeArgsFromState(
                state,
                flow: GuestPurchasePlanConfirmationEntryFlow.skip,
              ),
            );
          },
        ),
        BlocListener<GuestPurchasePlanAddOnsBloc, GuestPurchasePlanAddOnsState>(
          listenWhen: (previous, current) =>
              previous.proceedRequestId != current.proceedRequestId,
          listener: (context, state) {
            context.push(
              AppRoutes.guestPurchasePlanConfirmation,
              extra: _routeArgsFromState(
                state,
                flow: GuestPurchasePlanConfirmationEntryFlow.proceed,
              ),
            );
          },
        ),
      ],
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
              onPayNow: () {
                context.read<GuestPurchasePlanAddOnsBloc>().add(
                      const GuestPurchasePlanAddOnsProceedPressed(),
                    );
              },
            );
          },
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              DefaultAppBar(
                title: 'add-ons',
                showBackArrow: false,
                actionText:
                    AppSession.appRoute == 'addOnsPrepaid' ? null : 'skip',
                onActionTextTap: () {
                  context.read<GuestPurchasePlanAddOnsBloc>().add(
                        const GuestPurchasePlanAddOnsSkipPressed(),
                      );
                },
                onHomeTap: () => context.go(AppRoutes.logIn),
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
                          topRight: AppSession.appRoute == 'addOnsPrepaid'
                              ? AutoRenewToggle(initialValue: true)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        FairUsePolicyCard(policy: policy, onTap: () {}),
                        const SizedBox(height: 16),
                        ...state.addOns.map((item) {
                          final selected =
                              state.selectedAddOnIds.contains(item.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: AddOnTile(
                              item: item,
                              selected: selected,
                              onChanged: (value) => context
                                  .read<GuestPurchasePlanAddOnsBloc>()
                                  .add(
                                    GuestPurchasePlanAddOnsSelectionToggled(
                                      addOnId: item.id,
                                      selected: value,
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
