import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/mifi_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/monthly_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roameasy_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roaming_plan_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../bloc/guest_purchase_plan_bloc.dart';
import '../bloc/guest_purchase_plan_event.dart';
import '../bloc/guest_purchase_plan_state.dart';
import '../models/add_on_model.dart';
import '../models/plan_model.dart';
import '../repository/guest_purchase_plan_repository.dart';
import '../widgets/add_on_card.dart';
import '../widgets/daily_plan_card.dart';
import '../widgets/liberty_global_plan_card.dart';
import '../widgets/plan_tabs.dart';
import '../widgets/roam_bottom_sheet.dart';
import '../widgets/wallet_payment_activate_bottom_sheet.dart';
import '../widgets/wallet_payment_activate_or_future_bottom_sheet.dart';
import '../widgets/weekly_plan_card.dart';
import '../theme/theme.dart';

class GuestPurchasePlanScreen extends StatelessWidget {
  const GuestPurchasePlanScreen({super.key});

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
      create: (_) => GuestPurchasePlanBloc(GuestPurchasePlanRepository())
        ..add(GuestPurchasePlanStarted()),
      child: const _GuestPurchasePlanView(),
    );
  }
}

class _GuestPurchasePlanView extends StatelessWidget {
  const _GuestPurchasePlanView();

  bool _hasActivePlan(PlanModel plan) {
    final subtitle = plan.subtitle.toLowerCase();
    return !subtitle.contains('begins immediately') &&
        !subtitle.contains('start immediately');
  }

  String _priceText(double price) => '\$ ${price.toStringAsFixed(2)}';

  void _onPurchaseNowPressed(BuildContext context, PlanModel plan) {
    context.read<GuestPurchasePlanBloc>().add(GuestPurchasePlanPurchaseNowPressed(plan));

    final PlanTab selectedTab =
        context.read<GuestPurchasePlanBloc>().state.selectedTab;
    final hasActivePlan = _hasActivePlan(plan);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      builder: (sheetContext) {
        // Roaming flow only: allow selecting activation date from calendar.
        if (selectedTab == PlanTab.roaming) {
          return RoamBottomSheet(
            onBackPressed: () => Navigator.of(sheetContext).pop(),
            onActivateNowPressed: () {
              Navigator.of(sheetContext).pop();
              context.push(AppRoutes.roamingPlanConfirmation);
            },
          );
        }

        if (hasActivePlan) {
          return WalletPaymentActivateOrFutureBottomSheet(
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

        return WalletPaymentActivateBottomSheet(
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
      backgroundColor: GuestPurchasePlanTheme.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            DefaultAppBar(
              showBackArrow: false,
              showNotification: false,
                showNotificationDotWhenZero: true,
                title: 'plans',
                onBack: () {
                  context.pop();
                }),

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
                    context
                        .read<GuestPurchasePlanBloc>()
                        .add(GuestPurchasePlanTabChanged(tab));
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
                    title = 'choose a roaming data add-on. these add-ons will only work in the usa, canada and or digicel caribbean countries.';
                    break;
                  case PlanTab.roameasy:
                    title = 'choose a roameasy standalone plan';
                    break;
                  case PlanTab.addOns:
                    title =
                    'add-ons can only be added to your active primary plan and '
                        'expires when it ends.';
                    break;
                  case PlanTab.mifi:
                    title = 'choose a prepaid mifi primary plan';
                    break;
                  case PlanTab.libertyGlobal:
                    title = 'choose an international calling plan';
                    break;

                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(31, 20, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: GuestPurchasePlanTheme.sectionTitle,
                      // style: state.selectedTab == PlanTab.addOns
                      //     ? GuestPurchasePlanTheme.addOnHelper
                      //     : GuestPurchasePlanTheme.sectionTitle,
                    ),
                  ),
                );
              },
            ),

            Expanded(
              child: BlocBuilder<GuestPurchasePlanBloc, GuestPurchasePlanState>(
                builder: (context, state) {
                  if (state.status == GuestPurchasePlanStatus.loading ||
                      state.status == GuestPurchasePlanStatus.initial) {
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
                    // Title-to-first-card gap target: 16px.
                    // First card already contributes 10px top margin from theme,
                    // so list adds 6px top padding.
                    padding: const EdgeInsets.only(top: 6, bottom: 14),

                    //  addOns হলে addOns list, নাহলে plans list
                    itemCount: state.selectedTab == PlanTab.addOns
                        ? state.addOns.length
                        : state.plans.length,

                    itemBuilder: (context, index) {
                      // ADD ONS TAB
                      if (state.selectedTab == PlanTab.addOns) {
                        final AddOnModel addon = state.addOns[index];
                        final bool selected =
                            state.selectedAddOnIds.contains(addon.id);

                        return Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: AddOnCard(
                            addon: addon,
                            selected: selected,
                            onToggle: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleAddon(addon)
                              );
                            },
                          ),
                        );
                      }

                      // REST TABS (your existing)
                      final plan = state.plans[index];
                      final expanded = state.expandedPlanIds.contains(plan.id);

                      if (state.selectedTab == PlanTab.monthly) {
                        return Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: MonthlyPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
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
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
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
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
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
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
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
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
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
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onPurchaseNow: () {
                              _onPurchaseNowPressed(context, plan);
                            },
                          ),
                        );
                      }

                      if (state.selectedTab == PlanTab.libertyGlobal) {
                        return Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: LibertyGlobalPlanCard(
                            plan: plan,
                            expanded: expanded,
                            onToggle: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                  GuestPurchasePlanToggleExpanded(plan.id));
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
            )
          ],
        ),
      ),
    );
  }
}
