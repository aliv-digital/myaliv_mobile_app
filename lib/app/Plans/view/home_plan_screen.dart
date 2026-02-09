import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/app/Plans/widgets/mifi_plan_card.dart';
import 'package:myaliv_mobile_app/app/Plans/widgets/monthly_plan_card.dart';
import 'package:myaliv_mobile_app/app/Plans/widgets/roameasy_plan_card.dart';
import 'package:myaliv_mobile_app/app/Plans/widgets/roaming_plan_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../bloc/home_plan_bloc.dart';
import '../bloc/home_plan_event.dart';
import '../bloc/home_plan_state.dart';
import '../models/add_on_model.dart';
import '../models/plan_model.dart';
import '../repository/home_plan_repository.dart';
import '../widgets/add_on_card.dart';
import '../widgets/daily_plan_card.dart';
import '../widgets/liberty_global_plan_card.dart';
import '../widgets/plan_tabs.dart';
import '../widgets/wallet_payment_activate_bottom_sheet.dart';
import '../widgets/wallet_payment_activate_or_future_bottom_sheet.dart';
import '../widgets/weekly_plan_card.dart';
import '../theme/theme.dart';

class HomePlanScreen extends StatelessWidget {
  const HomePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
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

  bool _hasActivePlan(HomePlanModel plan) {
    final subtitle = plan.subtitle.toLowerCase();
    return !subtitle.contains('begins immediately') &&
        !subtitle.contains('start immediately');
  }

  String _priceText(double price) => '\$ ${price.toStringAsFixed(2)}';

  void _onPurchaseNowPressed(BuildContext context, HomePlanModel plan) {
    context.read<HomePlanBloc>().add(HomePlanPurchaseNowPressed(plan));

    final hasActivePlan = _hasActivePlan(plan);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      builder: (sheetContext) {
        if (hasActivePlan) {
          return HomePlanWalletPaymentActivateOrFutureBottomSheet(
            warningText:
                'activating now replaces the account owner current plan, '
                'you can activate the account owner plan as a future plan and '
                'it will start when their current plan ends on XXX.',
            planName: plan.title,
            planDurationText: plan.subtitle,
            planPriceText: _priceText(plan.price),
            onBackPressed: () => Navigator.of(sheetContext).pop(),
            onActivateNowPressed: () {
              Navigator.of(sheetContext).pop();
              context.push(AppRoutes.guestPurchasePlanAddOns);
            },
            onFuturePlanPressed: () {
              Navigator.of(sheetContext).pop();
              context.push(AppRoutes.guestPurchasePlanAddOns);
            },
          );
        }

        return HomePlanWalletPaymentActivateBottomSheet(
          warningText:
              'the account owner has no current plan, so their new plan will start immediately.',
          planName: plan.title,
          planDurationText: plan.subtitle,
          planPriceText: _priceText(plan.price),
          onBackPressed: () => Navigator.of(sheetContext).pop(),
          onActivateNowPressed: () {
            Navigator.of(sheetContext).pop();
            context.push(AppRoutes.guestPurchasePlanAddOns);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePlanTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFF645D9C),
        centerTitle: false,

        title: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Text(
            'plans',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: 'Circular Pro',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: SvgPicture.asset('assets/icons/bell with red.svg'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // DefaultAppBar(
            //     showNotificationDotWhenZero: true,
            //     notificationCount: 0,
            //     showNotification: true,
            //     showBackArrow: false,
            //     title: 'plans',
            //     onBack: () {
            //       context.pop();
            //     }),
            // _TopBar(
            //   title: 'plans',
            //   onBack: () => Navigator.of(context).maybePop(),
            // ),

            // scrollable tab for plans
            BlocBuilder<HomePlanBloc, HomePlanState>(
              buildWhen: (p, c) => p.selectedTab != c.selectedTab,
              builder: (context, state) {
                debugPrint('selected tab: ${state.selectedTab}');
                return HomePlanTabs(
                  selected: state.selectedTab,
                  onChanged: (tab) {
                    context.read<HomePlanBloc>().add(HomePlanTabChanged(tab));
                  },
                );
              },
            ),

            const SizedBox(height: 6),

            BlocBuilder<HomePlanBloc, HomePlanState>(
              buildWhen: (p, c) => p.selectedTab != c.selectedTab,
              builder: (context, state) {
                String title;
                switch (state.selectedTab) {
                  case HomePlanTab.daily:
                    title = 'choose a prepaid daily primary plan';
                    break;
                  case HomePlanTab.weekly:
                    title = 'choose a prepaid weekly primary plan';
                    break;
                  case HomePlanTab.monthly:
                    title = 'choose a prepaid monthly primary plan';
                    break;
                  case HomePlanTab.roaming:
                    title = 'choose a prepaid roaming primary plan';
                    break;
                  case HomePlanTab.roameasy:
                    title = 'choose a prepaid roameasy primary plan';
                    break;
                  case HomePlanTab.mifi:
                    title = 'choose a prepaid mifi primary plan';
                    break;
                  case HomePlanTab.libertyGlobal:
                    title = 'choose a prepaid liberty global primary plan';
                    break;
                  case HomePlanTab.addOns:
                    title =
                        'add-ons can only be added to your active primary plan and '
                        'expires when it ends.';
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(31, 20, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: state.selectedTab == HomePlanTab.addOns
                          ? HomePlanTheme.addOnHelper
                          : HomePlanTheme.sectionTitle,
                    ),
                  ),
                );
              },
            ),

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
                        style: HomePlanTheme.errorText,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 14),

                    //  addOns হলে addOns list, নাহলে plans list
                    itemCount: state.selectedTab == HomePlanTab.addOns
                        ? state.addOns.length
                        : state.plans.length,

                    itemBuilder: (context, index) {
                      // ADD ONS TAB
                      if (state.selectedTab == HomePlanTab.addOns) {
                        final HomePlanAddOnModel addon = state.addOns[index];
                        final bool selected = state.selectedAddOnIds.contains(
                          addon.id,
                        );

                        return Padding(
                          padding: EdgeInsets.only(left: 12, right: 12),
                          child: HomePlanAddOnCard(
                            addon: addon,
                            selected: selected,
                            onToggle: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleAddon(addon),
                              );
                            },
                          ),
                        );
                      }

                      // REST TABS (your existing)
                      final plan = state.plans[index];
                      final expanded = state.expandedPlanIds.contains(plan.id);

                      if (state.selectedTab == HomePlanTab.monthly) {
                        return Padding(
                          padding: EdgeInsets.only(left: 12, right: 12),
                          child: HomePlanMonthlyPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
                            },
                          ),
                        );
                      }

                      if (state.selectedTab == HomePlanTab.daily) {
                        return Padding(
                          padding: EdgeInsets.only(left: 12, right: 12),
                          child: HomePlanDailyPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
                            },
                          ),
                        );
                      }

                      if (state.selectedTab == HomePlanTab.weekly) {
                        return Padding(
                          padding: EdgeInsets.only(left: 12, right: 12),
                          child: HomePlanWeeklyPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
                            },
                          ),
                        );
                      }

                      if (state.selectedTab == HomePlanTab.roaming) {
                        return Padding(
                          padding: EdgeInsets.only(left: 12, right: 12),
                          child: HomePlanRoamingPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
                            },
                          ),
                        );
                      }

                      if (state.selectedTab == HomePlanTab.roameasy) {
                        return Padding(
                          padding: EdgeInsets.only(left: 12, right: 12),
                          child: HomePlanRoamEasyPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
                            },
                          ),
                        );
                      }

                      if (state.selectedTab == HomePlanTab.mifi) {
                        return Padding(
                          padding: EdgeInsets.only(left: 12, right: 12),
                          child: HomePlanMifiPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
                            },
                          ),
                        );
                      }

                      if (state.selectedTab == HomePlanTab.libertyGlobal) {
                        return Padding(
                          padding: EdgeInsets.only(left: 12, right: 12),
                          child: HomePlanLibertyGlobalPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<HomePlanBloc>().add(
                                HomePlanToggleExpanded(plan.id),
                              );
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
                            },
                          ),
                        );
                      }

                      return const SizedBox.shrink();
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
