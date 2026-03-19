import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
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
    this.onWeeklyPurchaseNow,
  });

  final HomePlanState state;
  final ValueChanged<String> onToggleExpanded;
  final ValueChanged<HomePlanModel> onPurchaseNow;
  final ValueChanged<DailyPlanModel>? onDailyPurchaseNow;
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

  Widget _buildCardForTab({
    required HomePlanTab tab,
    required HomePlanModel plan,
    required bool expanded,
  }) {
    void toggle() => onToggleExpanded(plan.id);

    switch (tab) {
      case HomePlanTab.monthly:
        return HomePlanMonthlyPlanCard(
          plan: plan,
          expanded: expanded,
          onToggle: toggle,
          onViewDetails: toggle,
          onPurchaseNow: () => onPurchaseNow(plan),
        );
      case HomePlanTab.daily:
        return const SizedBox.shrink();
      case HomePlanTab.weekly:
        return const SizedBox.shrink();
      case HomePlanTab.roaming:
        return HomePlanRoamingPlanCard(
          plan: plan,
          expanded: expanded,
          onToggle: toggle,
          onViewDetails: toggle,
          onPurchaseNow: () => onPurchaseNow(plan),
        );
      case HomePlanTab.roameasy:
        return HomePlanRoamEasyPlanCard(
          plan: plan,
          expanded: expanded,
          onToggle: toggle,
          onViewDetails: toggle,
          onPurchaseNow: () => onPurchaseNow(plan),
        );
      case HomePlanTab.mifi:
        return HomePlanMifiPlanCard(
          plan: plan,
          expanded: expanded,
          onToggle: toggle,
          onViewDetails: toggle,
          onPurchaseNow: () => onPurchaseNow(plan),
        );
      case HomePlanTab.libertyGlobal:
        return HomePlanLibertyGlobalPlanCard(
          plan: plan,
          expanded: expanded,
          onToggle: toggle,
          onViewDetails: toggle,
          onPurchaseNow: () => onPurchaseNow(plan),
        );
      case HomePlanTab.addOns:
        return const SizedBox.shrink();
    }
  }
}
