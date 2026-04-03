import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/liberty_global_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/mifi_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/monthly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roaming_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roameasy_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/weekly_plan_model.dart';

import '../bloc/home_plan_state.dart';
import '../models/plan_model.dart';
import '../repository/home_plan_repository.dart';
import 'daily_plan_card.dart';
import 'liberty_global_plan_card.dart';
import 'mifi_plan_card.dart';
import 'monthly_plan_card.dart';
import 'roameasy_plan_card.dart';
import 'roaming_plan_card.dart';
import 'weekly_plan_card.dart';

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
  });

  final HomePlanState state;
  final ValueChanged<String> onToggleExpanded;
  final ValueChanged<HomePlanModel> onPurchaseNow;
  final ValueChanged<DailyPlanModel>? onDailyPurchaseNow;
  final ValueChanged<LibertyGlobalPlanModel>? onLibertyGlobalPurchaseNow;
  final ValueChanged<MifiPlanModel>? onMifiPurchaseNow;
  final ValueChanged<MonthlyPlanModel>? onMonthlyPurchaseNow;
  final ValueChanged<RoamingPlanModel>? onRoamingPurchaseNow;
  final ValueChanged<RoamEasyPlanModel>? onRoamEasyPurchaseNow;
  final ValueChanged<WeeklyPlanModel>? onWeeklyPurchaseNow;

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
          final DailyPlanModel plan = state.dailyApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForDailyTab(
              plan: plan,
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
          final WeeklyPlanModel plan = state.weeklyApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForWeeklyTab(
              plan: plan,
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
          final MonthlyPlanModel plan = state.monthlyApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForMonthlyTab(
              plan: plan,
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
          final RoamingPlanModel plan = state.roamingApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForRoamingTab(
              plan: plan,
              expanded: expanded,
            ),
          );
        },
      );
    }

    if (state.selectedTab == HomePlanTab.roameasy) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        itemCount: state.roamEasyApiPlans.length,
        itemBuilder: (context, index) {
          final RoamEasyPlanModel plan = state.roamEasyApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForRoamEasyTab(
              plan: plan,
              expanded: expanded,
            ),
          );
        },
      );
    }

    if (state.selectedTab == HomePlanTab.mifi) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        itemCount: state.mifiApiPlans.length,
        itemBuilder: (context, index) {
          final MifiPlanModel plan = state.mifiApiPlans[index];
          final bool expanded = state.expandedPlanIds.contains(plan.planId);

          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: _buildCardForMifiTab(
              plan: plan,
              expanded: expanded,
            ),
          );
        },
      );
    }

    if (state.selectedTab == HomePlanTab.libertyGlobal) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        itemCount: state.libertyGlobalApiPlans.length,
        itemBuilder: (context, index) {
          final LibertyGlobalPlanModel plan =
              state.libertyGlobalApiPlans[index];
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

    return ListView.builder(
      // Title-to-first-card gap target: 16px.
      // First card already contributes 10px top margin from theme,
      // so list adds 6px top padding.
      padding: const EdgeInsets.only(top: 6, bottom: 14),
      itemCount: state.plans.length,
      itemBuilder: (context, index) {
        final HomePlanModel plan = state.plans[index];
        final bool expanded = state.expandedPlanIds.contains(plan.id);

        return Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: _buildCardForTab(
            tab: state.selectedTab,
            plan: plan,
            expanded: expanded,
          ),
        );
      },
    );
  }

  Widget _buildCardForDailyTab({
    required DailyPlanModel plan,
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
          onDailyPurchaseNow!(plan);
        }
      },
    );
  }

  Widget _buildCardForWeeklyTab({
    required WeeklyPlanModel plan,
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
          onWeeklyPurchaseNow!(plan);
        }
      },
    );
  }

  Widget _buildCardForMonthlyTab({
    required MonthlyPlanModel plan,
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
          onMonthlyPurchaseNow!(plan);
        }
      },
    );
  }

  Widget _buildCardForRoamingTab({
    required RoamingPlanModel plan,
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
    required RoamEasyPlanModel plan,
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
    required MifiPlanModel plan,
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
    required LibertyGlobalPlanModel plan,
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

  Widget _buildCardForTab({
    required HomePlanTab tab,
    required HomePlanModel plan,
    required bool expanded,
  }) {
    switch (tab) {
      case HomePlanTab.monthly:
        return const SizedBox.shrink();
      case HomePlanTab.daily:
        return const SizedBox.shrink();
      case HomePlanTab.weekly:
        return const SizedBox.shrink();
      case HomePlanTab.roaming:
        return const SizedBox.shrink();
      case HomePlanTab.roameasy:
        return const SizedBox.shrink();
      case HomePlanTab.mifi:
        return const SizedBox.shrink();
      case HomePlanTab.libertyGlobal:
        return const SizedBox.shrink();
      case HomePlanTab.addOns:
        return const SizedBox.shrink();
    }
  }
}
