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
class PlanAddOnsBody extends StatefulWidget {
  const PlanAddOnsBody({
    super.key,
    this.onNoPrimaryPlanPurchase,
  });

  /// Action when the user has no primary plan and taps "purchase plan".
  /// Defaults to switching the cubit to the monthly tab (PlanScreen behavior).
  /// `PurchaseAddOnsScreen` overrides this to pop and route to plans.
  final VoidCallback? onNoPrimaryPlanPurchase;

  @override
  State<PlanAddOnsBody> createState() => _PlanAddOnsBodyState();
}

class _PlanAddOnsBodyState extends State<PlanAddOnsBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoRefreshIfEmpty());
  }

  void _autoRefreshIfEmpty() {
    if (!mounted) return;
    final cubit = context.read<PlansCubit>();
    final state = cubit.state;
    // Only auto-refresh when /bundles already responded but returned no add-ons
    // and a refresh isn't already running.
    if (state.addOnsApiLastSyncedAt != null &&
        state.addOns.isEmpty &&
        !state.isRefreshingBundles) {
      cubit.refreshBundlesOnly();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (previous, current) {
        return previous.selectedTabStatus != current.selectedTabStatus ||
            previous.earliestAddOnsPrimaryPlan !=
                current.earliestAddOnsPrimaryPlan ||
            previous.addOns != current.addOns ||
            previous.selectedAddOnIds != current.selectedAddOnIds ||
            previous.addOnsApiLastSyncedAt != current.addOnsApiLastSyncedAt ||
            previous.isRefreshingBundles != current.isRefreshingBundles;
      },
      builder: (context, state) {
        final status = state.selectedTabStatus;
        final bundlesReady = state.addOnsApiLastSyncedAt != null;

        // Show shimmer when bundles has never responded OR when it came back
        // empty and an auto-refresh is currently in-flight.
        if (!bundlesReady || (state.addOns.isEmpty && state.isRefreshingBundles)) {
          if (!bundlesReady && status == PlansStatus.failure) {
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
            onPurchasePlan: widget.onNoPrimaryPlanPurchase ??
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
          addOns: state.addOns,
          selectedAddOnIds: state.selectedAddOnIds,
          onToggleAddOn: (addOn) =>
              context.read<PlansCubit>().toggleAddon(addOn),
        );
      },
    );
  }
}
