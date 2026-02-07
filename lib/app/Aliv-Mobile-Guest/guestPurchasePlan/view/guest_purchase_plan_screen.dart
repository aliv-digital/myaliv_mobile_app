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
import '../theme/theme.dart';



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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GuestPurchasePlanTheme.screenBackground,
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

            BlocBuilder<GuestPurchasePlanBloc, GuestPurchasePlanState>(
              buildWhen: (p, c) => p.selectedTab != c.selectedTab,
              builder: (context, state) {
                String title;
                switch (state.selectedTab) {
                  case PlanTab.daily:
                    title = 'choose a prepaid daily primary plan';
                    break;
                  case PlanTab.weekly:
                    title = 'choose a prepaid weekly primary plan';
                    break;
                  case PlanTab.monthly:
                    title = 'choose a prepaid monthly primary plan';
                    break;
                  case PlanTab.roaming:
                    title = 'choose a prepaid roaming primary plan';
                    break;
                  case PlanTab.roameasy:
                    title = 'choose a prepaid roameasy primary plan';
                    break;
                  case PlanTab.mifi:
                    title = 'choose a prepaid mifi primary plan';
                    break;
                  case PlanTab.libertyGlobal:
                    title = 'choose a prepaid liberty global primary plan';
                    break;
                  case PlanTab.addOns:
                    title = 'choose add ons for your plan';
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(32, 20, 30, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: GuestPurchasePlanTheme.sectionTitle,
                    ),
                  ),
                );
              },
            ),

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
                        style: GuestPurchasePlanTheme.errorText,
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
                        return Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: DailyPlanCard(
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

                      if (state.selectedTab == PlanTab.weekly) {
                        return Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: WeeklyPlanCard(
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

                      if (state.selectedTab == PlanTab.roaming) {
                        return Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: RoamingPlanCard(
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

                      if (state.selectedTab == PlanTab.roameasy) {
                        return Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: RoamEasyPlanCard(
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

                      if (state.selectedTab == PlanTab.mifi) {
                        return Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: MifiPlanCard(
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
