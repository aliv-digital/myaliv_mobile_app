import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/mifi_plan_card.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/monthly_plan_card.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/roameasy_plan_card.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/roaming_plan_card.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/model/plan_purchase_add_on_models.dart'
    as plan_add_ons_models;
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/widgets/plan_purchase_add_on_tile.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/widgets/plan_purchase_fair_use_policy_card.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/widgets/plan_purchase_plan_red_image_card.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import '../../../../core/utils/app_session.dart';
import '../bloc/home_plan_bloc.dart';
import '../bloc/home_plan_event.dart';
import '../bloc/home_plan_state.dart';
import '../models/add_on_model.dart';
import '../models/plan_model.dart';
import '../repository/home_plan_repository.dart';
import '../theme/theme.dart';
import '../widgets/daily_plan_card.dart';
import '../widgets/liberty_global_plan_card.dart';
import '../widgets/plan_tabs.dart';
import '../widgets/roam_bottom_sheet.dart';
import '../widgets/wallet_payment_activate_bottom_sheet.dart';
import '../widgets/wallet_payment_activate_or_future_bottom_sheet.dart';
import '../widgets/weekly_plan_card.dart';

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

  static const double _addOnsTabHorizontalPadding = 25;

  bool _hasActivePlan(HomePlanModel plan) {
    final subtitle = plan.subtitle.toLowerCase();
    return !subtitle.contains('begins immediately') &&
        !subtitle.contains('start immediately');
  }

  String _priceText(double price) => '\$ ${price.toStringAsFixed(2)}';

  plan_add_ons_models.PlanPurchaseActivePlanSummary
      _activePlanSummaryForAddOnsTab() {
    // Keep this aligned with the approved add-ons tab screenshot content.
    return const plan_add_ons_models.PlanPurchaseActivePlanSummary(
      label: 'active plan',
      name: 'liberty70',
      autoRenew: true,
      activeDateLabel: 'active',
      activeDate: '20/08/24',
      expireDateLabel: 'expire',
      expireDate: '19/09/24',
    );
  }

  plan_add_ons_models.PlanPurchaseFairUsePolicy _fairUsePolicyForAddOnsTab() {
    // This helper text is shown directly under the red card on add-ons tab.
    return const plan_add_ons_models.PlanPurchaseFairUsePolicy(
      title: 'fair use policy',
      description:
          'add-ons can only be added to your active primary plan and expires when it ends.',
    );
  }

  plan_add_ons_models.PlanPurchaseAddOnItem _toAddOnTileModel(
    HomePlanAddOnModel addOn,
  ) {
    return plan_add_ons_models.PlanPurchaseAddOnItem(
      id: addOn.id,
      title: addOn.title,
      subtitleLabel: addOn.label,
      subtitleValue: addOn.value,
      price: addOn.price,
    );
  }

  double _selectedAddOnsTotal(HomePlanState state) {
    return state.addOns
        .where((addOn) => state.selectedAddOnIds.contains(addOn.id))
        .fold<double>(0, (sum, addOn) => sum + addOn.price);
  }

  Widget _buildAddOnsTabContent(BuildContext context, HomePlanState state) {
    final activePlan = _activePlanSummaryForAddOnsTab();
    final fairUsePolicy = _fairUsePolicyForAddOnsTab();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _addOnsTabHorizontalPadding,
        20,
        _addOnsTabHorizontalPadding,
        16,
      ),
      children: <Widget>[
        PlanPurchasePlanRedImageCard(
          planLabel: activePlan.label,
          planName: activePlan.name,
          activeLabel: activePlan.activeDateLabel,
          activeDate: activePlan.activeDate,
          expireLabel: activePlan.expireDateLabel,
          expireDate: activePlan.expireDate,
          autoRenew: activePlan.autoRenew,
        ),
        const SizedBox(height: 16),
        PlanPurchaseFairUsePolicyCard(policy: fairUsePolicy, onTap: () {}),
        const SizedBox(height: 16),
        ...state.addOns.map((addOn) {
          final selected = state.selectedAddOnIds.contains(addOn.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PlanPurchaseAddOnTile(
              item: _toAddOnTileModel(addOn),
              selected: selected,
              onChanged: (_) {
                context.read<HomePlanBloc>().add(HomePlanToggleAddon(addOn));
              },
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  void _onPurchaseNowPressed(BuildContext context, HomePlanModel plan) {
    context.read<HomePlanBloc>().add(HomePlanPurchaseNowPressed(plan));

    final HomePlanTab selectedTab =
        context.read<HomePlanBloc>().state.selectedTab;
    final hasActivePlan = _hasActivePlan(plan);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      builder: (sheetContext) {
        // Roaming flow only: allow selecting activation date from calendar.
        if (selectedTab == HomePlanTab.roaming) {
          return HomePlanRoamBottomSheet(
            onBackPressed: () => Navigator.of(sheetContext).pop(),
            onDateApplied: (_) {
              Navigator.of(sheetContext).pop();
              context.push(
                AppRoutes.homeRoamingConfirmation,
                extra: {'showDateField': true},
              );
            },
            onActivateNowPressed: () {
              Navigator.of(sheetContext).pop();
              context.push(
                AppRoutes.homeRoamingConfirmation,
                extra: {'showDateField': false},
              );
            },
          );
        }

        if (selectedTab == HomePlanTab.roameasy) {
          return HomePlanRoamBottomSheet(
            onBackPressed: () => Navigator.of(sheetContext).pop(),
            onDateApplied: (_) {
              Navigator.of(sheetContext).pop();
              context.push(
                AppRoutes.homeRoamingConfirmation,
                extra: {'showDateField': true},
              );
            },
            onActivateNowPressed: () {
              Navigator.of(sheetContext).pop();
              context.push(
                AppRoutes.homeRoamingConfirmation,
                extra: {'showDateField': false},
              );
            },
          );
        }

        if (hasActivePlan && selectedTab == HomePlanTab.addOns) {
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
              context.push(AppRoutes.homePurchasePlanAddOns);
            },
            onFuturePlanPressed: () {
              Navigator.of(sheetContext).pop();
              context.push(AppRoutes.homePurchasePlanAddOns);
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
            AppSession.appRoute = 'prepaidPlan';
            Navigator.of(sheetContext).pop();
            context.push(AppRoutes.homePurchasePlanAddOns);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePlanTheme.screenBackground,
      bottomNavigationBar: BlocBuilder<HomePlanBloc, HomePlanState>(
        buildWhen: (previous, current) {
          return previous.selectedTab != current.selectedTab ||
              previous.status != current.status ||
              previous.selectedAddOnIds != current.selectedAddOnIds ||
              previous.addOns != current.addOns;
        },
        builder: (context, state) {
          if (state.selectedTab != HomePlanTab.addOns ||
              state.status != HomePlanStatus.loaded) {
            return const SizedBox.shrink();
          }

          final total = _selectedAddOnsTotal(state);

          return DefaultBottomPayBar(
            isVatExclusive: true,
            buttonText: 'proceed',
            amountText: '\$ ${total.toStringAsFixed(2)}',
            onPayNow: () {
              context.push(AppRoutes.confirmation);
            },
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            DefaultAppBar(
              showHome: true,
              showBackArrow: false,
              showNotification: false,
              showNotificationDotWhenZero: true,
              title: 'plans',
              onBack: () {
                context.pop();
              },
              onHomeTap: () => context.go(AppRoutes.home),
            ),

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
                if (state.selectedTab == HomePlanTab.addOns) {
                  return const SizedBox.shrink();
                }

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
                    title =
                        'choose a roaming data add-on. these add-ons will only work in the usa, canada and or digicel caribbean countries.';
                    break;
                  case HomePlanTab.roameasy:
                    title = 'choose a roameasy standalone plan';
                    break;
                  case HomePlanTab.addOns:
                    title = '';
                    break;
                  case HomePlanTab.mifi:
                    title = 'choose a prepaid mifi primary plan';
                    break;
                  case HomePlanTab.libertyGlobal:
                    title = 'choose an international calling plan';
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(31, 20, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: HomePlanTheme.sectionTitle,
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

                  if (state.selectedTab == HomePlanTab.addOns) {
                    return _buildAddOnsTabContent(context, state);
                  }

                  return ListView.builder(
                    // Title-to-first-card gap target: 16px.
                    // First card already contributes 10px top margin from theme,
                    // so list adds 6px top padding.
                    padding: const EdgeInsets.only(top: 6, bottom: 14),

                    itemCount: state.plans.length,

                    itemBuilder: (context, index) {
                      final plan = state.plans[index];
                      final expanded = state.expandedPlanIds.contains(plan.id);

                      if (state.selectedTab == HomePlanTab.monthly) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
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
                          padding: const EdgeInsets.only(left: 15, right: 15),
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
                          padding: const EdgeInsets.only(left: 15, right: 15),
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
                          padding: const EdgeInsets.only(left: 15, right: 15),
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
                          padding: const EdgeInsets.only(left: 15, right: 15),
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
                          padding: const EdgeInsets.only(left: 15, right: 15),
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
                          padding: const EdgeInsets.only(left: 15, right: 15),
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
