import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/widgets/home_plans_postpaid_plan_card.dart';

import '../cubit/plans_state.dart';
import '../models/plan_model.dart';
import '../repository/plan_types.dart';
import 'daily_plan_card.dart';
import 'liberty_global_plan_card.dart';
import 'mifi_plan_card.dart';
import 'monthly_plan_card.dart';
import 'roameasy_plan_card.dart';
import 'roaming_plan_card.dart';
import 'weekly_plan_card.dart';

typedef IndexedBasePlanCallback = void Function(BasePlanModel plan, int index);

class HomePlanPlansList extends StatelessWidget {
  const HomePlanPlansList({
    super.key,
    required this.state,
    required this.onToggleExpanded,
    required this.onPurchaseNow,
    this.onDailyPurchaseNow,
    this.onLibertyGlobalPurchaseNow,
    this.onMonthlyPurchaseNow,
    this.onMifiPurchaseNow,
    this.onRoamingPurchaseNow,
    this.onRoamEasyPurchaseNow,
    this.onWeeklyPurchaseNow,
    this.onPostpaidRoamingPurchaseNow,
  });

  final PlansState state;
  final ValueChanged<String> onToggleExpanded;
  final ValueChanged<HomePlanModel> onPurchaseNow;
  final IndexedBasePlanCallback? onDailyPurchaseNow;
  final ValueChanged<BasePlanModel>? onLibertyGlobalPurchaseNow;
  final ValueChanged<BasePlanModel>? onMifiPurchaseNow;
  final IndexedBasePlanCallback? onMonthlyPurchaseNow;
  final ValueChanged<BasePlanModel>? onRoamingPurchaseNow;
  final ValueChanged<BasePlanModel>? onRoamEasyPurchaseNow;
  final IndexedBasePlanCallback? onWeeklyPurchaseNow;
  final ValueChanged<HomePlansPostPaidPlanModel>? onPostpaidRoamingPurchaseNow;

  @override
  Widget build(BuildContext context) {
    if (state.selectedTab == HomePlanTab.daily) {
      return ListView.builder(
        // Title-to-first-card gap target: 16px.
        // First card already contributes 10px top margin from theme,
        // so list adds 6px top padding.
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        itemCount: state.dailyApiPlans.length,
        itemBuilder: (context, index) {
          final BasePlanModel plan = state.dailyApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForDailyTab(
              plan: plan,
              index: index,
              expanded: expanded,
            ),
          );
        },
      );
    }

    if (state.selectedTab == HomePlanTab.weekly) {
      return ListView.builder(
        // Title-to-first-card gap target: 16px.
        // First card already contributes 10px top margin from theme,
        // so list adds 6px top padding.
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        itemCount: state.weeklyApiPlans.length,
        itemBuilder: (context, index) {
          final BasePlanModel plan = state.weeklyApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForWeeklyTab(
              plan: plan,
              index: index,
              expanded: expanded,
            ),
          );
        },
      );
    }

    if (state.selectedTab == HomePlanTab.monthly) {
      return ListView.builder(
        // Title-to-first-card gap target: 16px.
        // First card already contributes 10px top margin from theme,
        // so list adds 6px top padding.
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        itemCount: state.monthlyApiPlans.length,
        itemBuilder: (context, index) {
          final BasePlanModel plan = state.monthlyApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForMonthlyTab(
              plan: plan,
              index: index,
              expanded: expanded,
            ),
          );
        },
      );
    }

    if (state.selectedTab == HomePlanTab.roaming) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        itemCount: state.roamingApiPlans.length,
        itemBuilder: (context, index) {
          final BasePlanModel plan = state.roamingApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForRoamingTab(plan: plan, expanded: expanded),
          );
        },
      );
    }

    if (state.selectedTab == HomePlanTab.roameasy) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        itemCount: state.roamEasyApiPlans.length,
        itemBuilder: (context, index) {
          final BasePlanModel plan = state.roamEasyApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForRoamEasyTab(plan: plan, expanded: expanded),
          );
        },
      );
    }

    if (state.selectedTab == HomePlanTab.mifi) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        itemCount: state.mifiApiPlans.length,
        itemBuilder: (context, index) {
          final BasePlanModel plan = state.mifiApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForMifiTab(plan: plan, expanded: expanded),
          );
        },
      );
    }

    if (state.selectedTab == HomePlanTab.libertyGlobal) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        itemCount: state.libertyGlobalApiPlans.length,
        itemBuilder: (context, index) {
          final BasePlanModel plan = state.libertyGlobalApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForLibertyGlobalTab(
              plan: plan,
              expanded: expanded,
            ),
          );
        },
      );
    }

    if (state.selectedTab == HomePlanTab.postpaidRoaming) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        itemCount: state.postpaidRoamingApiPlans.length,
        itemBuilder: (context, index) {
          final plan = state.postpaidRoamingApiPlans[index];
          final expanded = state.expandedPlanIds.contains(plan.planId);
          // fix
          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 16),
            child: HomePlansPostPaidPlanCard(
              plan: plan,
              expanded: expanded,
              onToggle: () => onToggleExpanded(plan.planId),
              onPurchaseNow: () {
                debugPrint(plan.planGroup);
                if (onPostpaidRoamingPurchaseNow != null) {
                  onPostpaidRoamingPurchaseNow!(plan);
                }
              },
            ),
          );
        },
      );
    }

    // Fallback case - should never be reached as all tabs are handled above
    return const SizedBox.shrink();
  }

  Widget _buildCardForDailyTab({
    required BasePlanModel plan,
    required int index,
    required bool expanded,
  }) {
    void toggle() => onToggleExpanded(plan.planId);

    return HomePlanDailyPlanCard(
      plan: plan,
      expanded: expanded,
      onToggle: toggle,
      onViewDetails: toggle,
      onPurchaseNow: () {
        if (onDailyPurchaseNow != null) {
          onDailyPurchaseNow!(plan, index);
        }
      },
    );
  }

  Widget _buildCardForWeeklyTab({
    required BasePlanModel plan,
    required int index,
    required bool expanded,
  }) {
    void toggle() => onToggleExpanded(plan.planId);

    return HomePlanWeeklyPlanCard(
      plan: plan,
      expanded: expanded,
      onToggle: toggle,
      onViewDetails: toggle,
      onPurchaseNow: () {
        if (onWeeklyPurchaseNow != null) {
          onWeeklyPurchaseNow!(plan, index);
        }
      },
    );
  }

  Widget _buildCardForMonthlyTab({
    required BasePlanModel plan,
    required int index,
    required bool expanded,
  }) {
    void toggle() => onToggleExpanded(plan.planId);

    return HomePlanMonthlyPlanCard(
      plan: plan,
      expanded: expanded,
      onToggle: toggle,
      onViewDetails: toggle,
      onPurchaseNow: () {
        if (onMonthlyPurchaseNow != null) {
          onMonthlyPurchaseNow!(plan, index);
        }
      },
    );
  }

  Widget _buildCardForRoamingTab({
    required BasePlanModel plan,
    required bool expanded,
  }) {
    void toggle() => onToggleExpanded(plan.planId);

    return HomePlanRoamingPlanCard(
      plan: plan,
      expanded: expanded,
      onToggle: toggle,
      onViewDetails: toggle,
      onPurchaseNow: () {
        if (onRoamingPurchaseNow != null) {
          onRoamingPurchaseNow!(plan);
        }
      },
    );
  }

  Widget _buildCardForRoamEasyTab({
    required BasePlanModel plan,
    required bool expanded,
  }) {
    void toggle() => onToggleExpanded(plan.planId);

    return HomePlanRoamEasyPlanCard(
      plan: plan,
      expanded: expanded,
      onToggle: toggle,
      onViewDetails: toggle,
      onPurchaseNow: () {
        if (onRoamEasyPurchaseNow != null) {
          onRoamEasyPurchaseNow!(plan);
        }
      },
    );
  }

  Widget _buildCardForMifiTab({
    required BasePlanModel plan,
    required bool expanded,
  }) {
    void toggle() => onToggleExpanded(plan.planId);

    return HomePlanMifiPlanCard(
      plan: plan,
      expanded: expanded,
      onToggle: toggle,
      onViewDetails: toggle,
      onPurchaseNow: () {
        if (onMifiPurchaseNow != null) {
          onMifiPurchaseNow!(plan);
        }
      },
    );
  }

  Widget _buildCardForLibertyGlobalTab({
    required BasePlanModel plan,
    required bool expanded,
  }) {
    void toggle() => onToggleExpanded(plan.planId);

    return HomePlanLibertyGlobalPlanCard(
      plan: plan,
      expanded: expanded,
      onToggle: toggle,
      onViewDetails: toggle,
      onPurchaseNow: () {
        if (onLibertyGlobalPurchaseNow != null) {
          onLibertyGlobalPurchaseNow!(plan);
        }
      },
    );
  }
}
