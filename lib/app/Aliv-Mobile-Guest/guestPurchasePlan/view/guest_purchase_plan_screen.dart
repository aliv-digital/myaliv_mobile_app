import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/mifi_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/monthly_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roameasy_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roaming_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/model/add_on_models.dart'
    as add_ons_models;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/widgets/add_on_tile.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/widgets/fair_use_policy_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/widgets/plan_red_image_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../bloc/guest_purchase_plan_bloc.dart';
import '../bloc/guest_purchase_plan_event.dart';
import '../bloc/guest_purchase_plan_state.dart';
import '../models/add_on_model.dart';
import '../models/plan_model.dart';
import '../repository/guest_purchase_plan_repository.dart';
import '../widgets/daily_plan_card.dart';
import '../widgets/liberty_global_plan_card.dart';
import '../widgets/plan_tabs.dart';
import '../widgets/roam_bottom_sheet.dart';
import '../widgets/wallet_payment_activate_bottom_sheet.dart';
import '../widgets/wallet_payment_activate_or_future_bottom_sheet.dart';
import '../widgets/weekly_plan_card.dart';
import '../theme/theme.dart';

class GuestPurchasePlanScreen extends StatelessWidget {
  const GuestPurchasePlanScreen({super.key, this.phoneNumber = ''});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GuestPurchasePlanBloc(GuestPurchasePlanRepository())
            ..add(GuestPurchasePlanStarted()),
      child: _GuestPurchasePlanView(phoneNumber: phoneNumber),
    );
  }
}

class _GuestPurchasePlanView extends StatelessWidget {
  const _GuestPurchasePlanView({this.phoneNumber = ''});

  final String phoneNumber;

  static const double _addOnsTabHorizontalPadding = 25;

  bool _hasActivePlan(PlanModel plan) {
    final subtitle = plan.subtitle.toLowerCase();
    return !subtitle.contains('begins immediately') &&
        !subtitle.contains('start immediately');
  }

  String _priceText(double price) => '\$ ${price.toStringAsFixed(2)}';

  add_ons_models.ActivePlanSummary _activePlanSummaryForAddOnsTab() {
    // Keep this aligned with the approved add-ons tab screenshot content.
    return const add_ons_models.ActivePlanSummary(
      label: 'active plan',
      name: 'liberty70',
      autoRenew: true,
      activeDateLabel: 'active',
      activeDate: '20/08/24',
      expireDateLabel: 'expire',
      expireDate: '19/09/24',
    );
  }

  add_ons_models.FairUsePolicy _fairUsePolicyForAddOnsTab() {
    // This helper text is shown directly under the red card on add-ons tab.
    return const add_ons_models.FairUsePolicy(
      title: 'fair use policy',
      description:
          'add-ons can only be added to your active primary plan and expires when it ends.',
    );
  }

  add_ons_models.AddOnItem _toAddOnTileModel(AddOnModel addOn) {
    return add_ons_models.AddOnItem(
      id: addOn.id,
      title: addOn.title,
      subtitleLabel: addOn.label,
      subtitleValue: addOn.value,
      price: addOn.price,
    );
  }

  double _selectedAddOnsTotal(GuestPurchasePlanState state) {
    return state.addOns
        .where((addOn) => state.selectedAddOnIds.contains(addOn.id))
        .fold<double>(0, (sum, addOn) => sum + addOn.price);
  }

  Map<String, Object?> _roamingConfirmationExtra(
    PlanModel plan, {
    required bool showDateField,
    required DateTime beginDate,
  }) {
    return <String, Object?>{
      'phoneNumber': phoneNumber,
      'planId': plan.id,
      'planName': plan.title,
      'planDuration': plan.subtitle,
      'planPrice': plan.price,
      'beginDate': beginDate,
      'showDateField': showDateField,
      'forceNow': !showDateField,
    };
  }

  Widget _buildAddOnsTabContent(
    BuildContext context,
    GuestPurchasePlanState state,
  ) {
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
        PlanRedImageCard(
          planLabel: activePlan.label,
          planName: activePlan.name,
          activeLabel: activePlan.activeDateLabel,
          activeDate: activePlan.activeDate,
          expireLabel: activePlan.expireDateLabel,
          expireDate: activePlan.expireDate,
        ),
        const SizedBox(height: 16),
        FairUsePolicyCard(policy: fairUsePolicy, onTap: () {}),
        const SizedBox(height: 16),
        ...state.addOns.map((addOn) {
          final selected = state.selectedAddOnIds.contains(addOn.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AddOnTile(
              item: _toAddOnTileModel(addOn),
              selected: selected,
              onChanged: (_) {
                context.read<GuestPurchasePlanBloc>().add(
                  GuestPurchasePlanToggleAddon(addOn),
                );
              },
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  void _onPurchaseNowPressed(BuildContext context, PlanModel plan) {
    context.read<GuestPurchasePlanBloc>().add(
      GuestPurchasePlanPurchaseNowPressed(plan),
    );

    final PlanTab selectedTab = context
        .read<GuestPurchasePlanBloc>()
        .state
        .selectedTab;
    final hasActivePlan = _hasActivePlan(plan);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      builder: (sheetContext) {
        // Standalone plans share the same date-or-activate-now flow used by
        // the real Plans integration.
        if (selectedTab == PlanTab.roaming ||
            selectedTab == PlanTab.roameasy ||
            selectedTab == PlanTab.libertyGlobal) {
          return RoamBottomSheet(
            onBackPressed: () => Navigator.of(sheetContext).pop(),
            onDateApplied: (pickedDate) {
              Navigator.of(sheetContext).pop();
              context.push(
                AppRoutes.roamingPlanConfirmation,
                extra: _roamingConfirmationExtra(
                  plan,
                  showDateField: true,
                  beginDate: pickedDate,
                ),
              );
            },
            onActivateNowPressed: () {
              Navigator.of(sheetContext).pop();
              context.push(
                AppRoutes.roamingPlanConfirmation,
                extra: _roamingConfirmationExtra(
                  plan,
                  showDateField: false,
                  beginDate: DateTime.now(),
                ),
              );
            },
          );
        }

        // if (selectedTab == PlanTab.monthly) {
        //   return RoamBottomSheet(
        //     onBackPressed: () => Navigator.of(sheetContext).pop(),
        //     onActivateNowPressed: () {
        //       Navigator.of(sheetContext).pop();
        //       context.push(AppRoutes.roamingPlanConfirmation);
        //     },
        //   );
        // }
        if (hasActivePlan && selectedTab == PlanTab.addOns) {
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
              context.push(
                AppRoutes.guestPurchasePlanAddOns,
                extra: {'phoneNumber': phoneNumber},
              );
            },
            onFuturePlanPressed: () {
              Navigator.of(sheetContext).pop();
              context.push(
                AppRoutes.guestPurchasePlanAddOns,
                extra: {'phoneNumber': phoneNumber},
              );
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
            context.push(
              AppRoutes.guestPurchasePlanAddOns,
              extra: {'phoneNumber': phoneNumber},
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GuestPurchasePlanTheme.screenBackground,
      bottomNavigationBar:
          BlocBuilder<GuestPurchasePlanBloc, GuestPurchasePlanState>(
            buildWhen: (previous, current) {
              return previous.selectedTab != current.selectedTab ||
                  previous.status != current.status ||
                  previous.selectedAddOnIds != current.selectedAddOnIds ||
                  previous.addOns != current.addOns;
            },
            builder: (context, state) {
              if (state.selectedTab != PlanTab.addOns ||
                  state.status != GuestPurchasePlanStatus.loaded) {
                return const SizedBox.shrink();
              }

              final total = _selectedAddOnsTotal(state);

              return DefaultBottomPayBar(
                isVatExclusive: true,
                buttonText: 'proceed',
                amountText: '\$ ${total.toStringAsFixed(2)}',
                onPayNow: () {
                  context.push(
                    AppRoutes.addOnsConfirmation,
                    extra: {'phoneNumber': phoneNumber},
                  );
                },
              );
            },
          ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            DefaultAppBar(
              showHome: true,
              showBackArrow: true,
              showNotification: false,
              showNotificationDotWhenZero: true,
              title: 'plans',
              onBack: () {
                context.pop();
              },
              onHomeTap: () => context.go(AppRoutes.logIn),
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
                    context.read<GuestPurchasePlanBloc>().add(
                      GuestPurchasePlanTabChanged(tab),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 6),

            BlocBuilder<GuestPurchasePlanBloc, GuestPurchasePlanState>(
              buildWhen: (p, c) => p.selectedTab != c.selectedTab,
              builder: (context, state) {
                if (state.selectedTab == PlanTab.addOns) {
                  return const SizedBox.shrink();
                }

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
                    title =
                        'choose a roaming data add-on. these add-ons will only work in the usa, canada and or digicel caribbean countries.';
                    break;
                  case PlanTab.roameasy:
                    title = 'choose a roameasy standalone plan';
                    break;
                  case PlanTab.addOns:
                    title = '';
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

                  if (state.selectedTab == PlanTab.addOns) {
                    return _buildAddOnsTabContent(context, state);
                  }

                  return ListView.builder(
                    // Title-to-first-card gap target: 16px.
                    // First card already contributes 10px top margin from theme,
                    // so list adds 6px top padding.
                    padding: const EdgeInsets.only(top: 6, bottom: 14),

                    itemCount: state.plans.length,

                    itemBuilder: (context, index) {
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
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
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
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
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
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
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
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
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
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
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
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
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
                                GuestPurchasePlanToggleExpanded(plan.id),
                              );
                            },
                            onViewDetails: () {
                              context.read<GuestPurchasePlanBloc>().add(
                                GuestPurchasePlanToggleExpanded(plan.id),
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
