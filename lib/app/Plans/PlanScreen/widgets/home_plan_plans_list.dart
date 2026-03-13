import 'package:flutter/material.dart';

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
  });

  final HomePlanState state;
  final ValueChanged<String> onToggleExpanded;
  final ValueChanged<HomePlanModel> onPurchaseNow;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // Title-to-first-card gap target: 16px.
      // First card already contributes 10px top margin from theme,
      // so list adds 6px top padding.
      padding: const EdgeInsets.only(top: 6, bottom: 14),
      itemCount: state.plans.length,
      itemBuilder: (context, index) {
        final plan = state.plans[index];
        final expanded = state.expandedPlanIds.contains(plan.id);

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
        return HomePlanDailyPlanCard(
          plan: plan,
          expanded: expanded,
          onToggle: toggle,
          onViewDetails: toggle,
          onPurchaseNow: () => onPurchaseNow(plan),
        );
      case HomePlanTab.weekly:
        return HomePlanWeeklyPlanCard(
          plan: plan,
          expanded: expanded,
          onToggle: toggle,
          onViewDetails: toggle,
          onPurchaseNow: () => onPurchaseNow(plan),
        );
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
