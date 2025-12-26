import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/mifi_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/monthly_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roameasy_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roaming_plan_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../bloc/guest_purchase_plan_bloc.dart';
import '../bloc/guest_purchase_plan_event.dart';
import '../bloc/guest_purchase_plan_state.dart';
import '../models/add_on_model.dart';
import '../repository/guest_purchase_plan_repository.dart';
import '../widgets/add_on_card.dart';
import '../widgets/daily_plan_card.dart';
import '../widgets/liberty_global_plan_card.dart';
import '../widgets/plan_card.dart';
import '../widgets/plan_tabs.dart';
import '../widgets/weekly_plan_card.dart';



class GuestPurchasePlanScreen extends StatelessWidget {
  const GuestPurchasePlanScreen({super.key});

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
      create: (_) => GuestPurchasePlanBloc(
          GuestPurchasePlanRepository())..add(
          GuestPurchasePlanStarted()
      ),
      child: const _GuestPurchasePlanView(),
    );
  }
}

class _GuestPurchasePlanView extends StatelessWidget {
  const _GuestPurchasePlanView();

  static const Color _topBar = Color(0xFF5D5A8B);
  static const Color _bg = Color(0xFFF6F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            DefaultAppBar(
                title: 'plans',
                onBack: (){
                  context.pop();
                }
            ),
            // _TopBar(
            //   title: 'plans',
            //   onBack: () => Navigator.of(context).maybePop(),
            // ),

            // scrollable tab for plans
            BlocBuilder<GuestPurchasePlanBloc, GuestPurchasePlanState>(
              buildWhen: (p, c) => p.selectedTab != c.selectedTab,
              builder: (context, state) {
                debugPrint('selected tab: ${state.selectedTab}');
                return PlanTabs(
                  selected: state.selectedTab,
                  onChanged: (tab) {

                    context.read<GuestPurchasePlanBloc>().add(GuestPurchasePlanTabChanged(tab));
                  },
                );
              },
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.only(top: 24,bottom: 15,left: 31),
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
              child: BlocBuilder<GuestPurchasePlanBloc, GuestPurchasePlanState>(
                builder: (context, state) {
                  if (state.status == GuestPurchasePlanStatus.loading || state.status == GuestPurchasePlanStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == GuestPurchasePlanStatus.failure) {
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

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 14),

                    //  addOns হলে addOns list, নাহলে plans list
                    itemCount: state.selectedTab == PlanTab.addOns ? state.addOns.length : state.plans.length,

                    itemBuilder: (context, index) {
                      // ADD ONS TAB
                      if (state.selectedTab == PlanTab.addOns) {
                        final AddOnModel addon = state.addOns[index];
                        final bool selected = state.selectedAddOnIds.contains(addon.id);

                        return AddOnCard(
                          addon: addon,
                          selected: selected,
                          onToggle: () {
                            context.read<GuestPurchasePlanBloc>().add(GuestPurchasePlanToggleAddon(addon));
                          },
                        );
                      }

                      // REST TABS (your existing)
                      final plan = state.plans[index];
                      final expanded = state.expandedPlanIds.contains(plan.id);

                      if (state.selectedTab == PlanTab.monthly) {
                        return Padding(
                          padding: EdgeInsets.only(left: 15,right: 15),
                          child: MonthlyPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: () {
                              context
                                  .read<GuestPurchasePlanBloc>()
                                  .add(GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onViewDetails: () {
                              context
                                  .read<GuestPurchasePlanBloc>()
                                  .add(GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onPurchaseNow: () {
                              context
                                  .read<GuestPurchasePlanBloc>()
                                  .add(GuestPurchasePlanPurchaseNowPressed(plan));
                            },
                          ),
                        );
                      }

                      if (state.selectedTab == PlanTab.daily) {
                        return DailyPlanCard(
                          plan: plan,
                          expanded: expanded,
                          onToggle: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onViewDetails: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onPurchaseNow: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanPurchaseNowPressed(plan));
                          },
                        );
                      }

                      if (state.selectedTab == PlanTab.weekly) {
                        return WeeklyPlanCard(
                          plan: plan,
                          expanded: expanded,
                          onToggle: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onViewDetails: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onPurchaseNow: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanPurchaseNowPressed(plan));
                          },
                        );
                      }

                      if (state.selectedTab == PlanTab.roaming) {
                        return RoamingPlanCard(
                          plan: plan,
                          expanded: expanded,
                          onToggle: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onViewDetails: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onPurchaseNow: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanPurchaseNowPressed(plan));
                          },
                        );
                      }

                      if (state.selectedTab == PlanTab.roameasy) {
                        return RoamEasyPlanCard(
                          plan: plan,
                          expanded: expanded,
                          onToggle: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onViewDetails: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onPurchaseNow: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanPurchaseNowPressed(plan));
                          },
                        );
                      }

                      if (state.selectedTab == PlanTab.mifi) {
                        return MifiPlanCard(
                          plan: plan,
                          expanded: expanded,
                          onToggle: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onViewDetails: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onPurchaseNow: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanPurchaseNowPressed(plan));
                          },
                        );
                      }

                      if (state.selectedTab == PlanTab.libertyGlobal) {
                        return LibertyGlobalPlanCard(
                          plan: plan,
                          expanded: expanded,
                          onToggle: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onViewDetails: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanToggleExpanded(plan.id));
                          },
                          onPurchaseNow: () {
                            context
                                .read<GuestPurchasePlanBloc>()
                                .add(GuestPurchasePlanPurchaseNowPressed(plan));
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  );

                },
              ),
            )
          ],
        ),
      ),
    );
  }
}


