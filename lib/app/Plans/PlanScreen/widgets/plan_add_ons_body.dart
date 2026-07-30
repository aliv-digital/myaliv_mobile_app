import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/home_plan_add_ons_tab_content.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/plan_card_shimmer.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/plan_empty_state.dart';

/// Reusable body for the add-ons view used by both `HomePlanScreen` and
/// the user-profile `PurchaseAddOnsScreen`. Renders the same shimmer,
/// no-primary-plan, empty, and tab-content states from `PlansCubit` data.
class PlanAddOnsBody extends StatelessWidget {
  const PlanAddOnsBody({
    super.key,
    this.onNoPrimaryPlanPurchase,
  });

  /// Action when the user has no primary plan and taps "purchase plan".
  /// Defaults to switching the cubit to the monthly tab (PlanScreen behavior).
  /// `PurchaseAddOnsScreen` overrides this to pop and route to plans.
  final VoidCallback? onNoPrimaryPlanPurchase;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (previous, current) {
        return previous.selectedTabStatus != current.selectedTabStatus ||
            previous.earliestAddOnsPrimaryPlan !=
                current.earliestAddOnsPrimaryPlan ||
            previous.addOns != current.addOns ||
            previous.selectedAddOnIds != current.selectedAddOnIds ||
            previous.addOnsApiLastSyncedAt != current.addOnsApiLastSyncedAt;
      },
      builder: (context, state) {
        final status = state.selectedTabStatus;
        // /bundles data drives the add-ons tab entirely — show shimmer only
        // while bundles hasn't responded yet, regardless of available-plans.
        final bundlesReady = state.addOnsApiLastSyncedAt != null;

        if (!bundlesReady) {
          if (status == PlansStatus.failure) {
            return PlanErrorState(
              errorMessage:
                  state.selectedTabErrorMessage ?? 'Something went wrong',
              onRetry: () => context.read<PlansCubit>().refreshCurrentTab(),
            );
          }
          return const AddOnShimmerList();
        }

        if (state.earliestAddOnsPrimaryPlan == null) {
          return AddOnsNoPrimaryPlanState(
            onPurchasePlan: onNoPrimaryPlanPurchase ??
                () =>
                    context.read<PlansCubit>().changeTab(HomePlanTab.monthly),
          );
        }

        if (state.addOns.isEmpty) {
          return PlanEmptyState(
            message: 'No add-ons available at the moment',
            onRefresh: () => context.read<PlansCubit>().refreshCurrentTab(),
          );
        }

        return HomePlanAddOnsTabContent(
          activePrimaryPlan: state.earliestAddOnsPrimaryPlan,
          addOns: state.addOns,
          selectedAddOnIds: state.selectedAddOnIds,
          onToggleAddOn: (addOn) =>
              context.read<PlansCubit>().toggleAddon(addOn),
        );
      },
    );
  }
}
