import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_plan_bloc.dart';
import '../bloc/home_plan_event.dart';
import '../bloc/home_plan_state.dart';
import '../models/add_on_model.dart';
import '../repository/home_plan_repository.dart';
import '../widgets/add_on_card.dart';
import '../widgets/daily_plan_card.dart';
import '../widgets/home_plan_tabs.dart';
import '../widgets/liberty_global_plan_card.dart';
import '../widgets/mifi_plan_card.dart';
import '../widgets/monthly_plan_card.dart';
import '../widgets/roameasy_plan_card.dart';
import '../widgets/roaming_plan_card.dart';
import '../widgets/weekly_plan_card.dart';


class HomePlanScreen extends StatelessWidget {
  const HomePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return BlocProvider(
      create: (_) => HomePlanBloc(HomePlanRepository())..add(HomePlanStarted()),
      child: const _HomePlanView(),
    );
  }
}

class _HomePlanView extends StatelessWidget {
  const _HomePlanView();

  static const Color _bg = Color(0xFFF6F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // DefaultAppBar(
            //   title: 'plans',
            //   onBack: () => context.pop(),
            // ),

            // Tabs
            BlocBuilder<HomePlanBloc, HomePlanState>(
              buildWhen: (p, c) => p.selectedTab != c.selectedTab,
              builder: (context, state) {
                return HomePlanTabs(
                  selected: state.selectedTab,
                  onChanged: (tab) {
                    context.read<HomePlanBloc>().add(HomePlanTabChanged(tab));
                  },
                );
              },
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 15, left: 31),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'choose a prepaid monthly primary plan',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: BlocBuilder<HomePlanBloc, HomePlanState>(
                builder: (context, state) {
                  if (state.status == HomePlanStatus.loading ||
                      state.status == HomePlanStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == HomePlanStatus.failure) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Something went wrong',
                        style: const TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }

                  final isAddOns = state.selectedTab == HomePlanTab.addOns;

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 14),
                    itemCount: isAddOns ? state.addOns.length : state.plans.length,
                    itemBuilder: (context, index) {
                      // ADD ONS
                      if (isAddOns) {
                        final HomePlanAddOnModel addon = state.addOns[index];
                        final bool selected = state.selectedAddOnIds.contains(addon.id);

                        return HomePlanAddOnCard(
                          addon: addon,
                          selected: selected,
                          onToggle: () {
                            context.read<HomePlanBloc>().add(HomePlanToggleAddon(addon));
                          },
                        );
                      }

                      // PLANS
                      final plan = state.plans[index];
                      final expanded = state.expandedPlanIds.contains(plan.id);

                      void toggleExpanded() {
                        context.read<HomePlanBloc>().add(HomePlanToggleExpanded(plan.id));
                      }

                      void purchaseNow() {
                        context.read<HomePlanBloc>().add(HomePlanPurchaseNowPressed(plan));
                      }

                      switch (state.selectedTab) {
                        case HomePlanTab.monthly:
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: HomePlanMonthlyPlanCard(
                              plan: plan,
                              expanded: expanded,
                              onToggle: toggleExpanded,
                              onViewDetails: toggleExpanded,
                              onPurchaseNow: purchaseNow,
                            ),
                          );

                        case HomePlanTab.daily:
                          return HomePlanDailyPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: toggleExpanded,
                            onViewDetails: toggleExpanded,
                            onPurchaseNow: purchaseNow,
                          );

                        case HomePlanTab.weekly:
                          return HomePlanWeeklyPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: toggleExpanded,
                            onViewDetails: toggleExpanded,
                            onPurchaseNow: purchaseNow,
                          );

                        case HomePlanTab.roaming:
                          return HomePlanRoamingPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: toggleExpanded,
                            onViewDetails: toggleExpanded,
                            onPurchaseNow: purchaseNow,
                          );

                        case HomePlanTab.roameasy:
                          return HomePlanRoamEasyPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: toggleExpanded,
                            onViewDetails: toggleExpanded,
                            onPurchaseNow: purchaseNow,
                          );

                        case HomePlanTab.mifi:
                          return HomePlanMifiPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: toggleExpanded,
                            onViewDetails: toggleExpanded,
                            onPurchaseNow: purchaseNow,
                          );

                        case HomePlanTab.libertyGlobal:
                          return HomePlanLibertyGlobalPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: toggleExpanded,
                            onViewDetails: toggleExpanded,
                            onPurchaseNow: purchaseNow,
                          );

                        case HomePlanTab.addOns:
                        // already handled above
                          return const SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
