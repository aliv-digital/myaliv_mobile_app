import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/mifi_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/monthly_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roameasy_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roaming_plan_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/model/add_on_models.dart'
    as add_ons_models;
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/widgets/add_on_tile.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/widgets/fair_use_policy_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/widgets/plan_red_image_card.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanComfirmation/models/guest_purchase_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_group.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/plan_card_shimmer.dart';
import 'package:myaliv_mobile_app/core/utils/appUtils.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/guest_purchase_plan_bloc.dart';
import '../bloc/guest_purchase_plan_event.dart';
import '../bloc/guest_purchase_plan_state.dart';
import '../models/add_on_model.dart';
import '../models/plan_model.dart';
import '../repository/guest_purchase_plan_repository.dart';
import '../theme/theme.dart';
import '../widgets/daily_plan_card.dart';
import '../widgets/liberty_global_plan_card.dart';
import '../widgets/plan_tabs.dart';
import '../widgets/roam_bottom_sheet.dart';
import '../widgets/wallet_payment_activate_bottom_sheet.dart';
import '../widgets/wallet_payment_activate_or_future_bottom_sheet.dart';
import '../widgets/weekly_plan_card.dart';

class GuestPurchasePlanScreen extends StatelessWidget {
  const GuestPurchasePlanScreen({super.key, this.phoneNumber = ''});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuestPurchasePlanBloc(
        GuestPurchasePlanRepository(phoneNumber: phoneNumber),
      )..add(GuestPurchasePlanStarted()),
      child: _GuestPurchasePlanView(phoneNumber: phoneNumber),
    );
  }
}

class _GuestPurchasePlanView extends StatelessWidget {
  const _GuestPurchasePlanView({this.phoneNumber = ''});

  final String phoneNumber;

  static const double _addOnsTabHorizontalPadding = 25;

  static final DateFormat _cardDateFormat = DateFormat('dd/MM/yy');

  /// Builds the add-ons tab summary from the entered number's real
  /// active primary plan (from /Guest/existingplans). Returns null when
  /// no active plan exists so the UI can hide the card entirely —
  /// mirrors prepaid behaviour where the active-plan card only renders
  /// when `earliestAddOnsPrimaryPlan != null`.
  add_ons_models.ActivePlanSummary? _activePlanSummaryFromState(
    GuestPurchasePlanState state,
  ) {
    final BasePlanModel? plan = state.earliestAddOnsPrimaryPlan;
    if (plan == null) return null;

    return add_ons_models.ActivePlanSummary(
      label: 'active plan',
      name: plan.planName,
      autoRenew: plan.autoRenew,
      activeDateLabel: 'active',
      activeDate: _formatPlanDate(plan.startDateTime),
      expireDateLabel: 'expire',
      expireDate: _formatPlanDate(plan.endDateTime),
      // Prepaid shows the expire time as a subtitle under the date
      // (active_plan_card_with_data.dart:124). Mirror that for parity.
      expireTime: plan.endDateTime.formatHmAOrEmpty(),
    );
  }

  String _formatPlanDate(DateTime? date) {
    if (date == null) return '--/--/--';
    return _cardDateFormat.format(date);
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
    GuestPlanDisplayModel plan, {
    required bool showDateField,
    required DateTime beginDate,
  }) {
    return <String, Object?>{
      'phoneNumber': phoneNumber,
      'planId': plan.id,
      'planName': plan.title,
      'planDuration': plan.subtitle,
      'planPrice': plan.price,
      'selectedPlan': plan,
      'benefits': plan.benefits,
      'destination': plan.destination,
      'beginDate': beginDate,
      'showDateField': showDateField,
      'forceNow': !showDateField,
    };
  }

  GuestPurchasePlanConfirmationRouteArgs _mifiConfirmationArgs(
    GuestPlanDisplayModel plan,
  ) {
    return GuestPurchasePlanConfirmationRouteArgs(
      phoneNumber: phoneNumber,
      accountHolderName: 'guest purchase a plan',
      primaryPlanName: plan.title,
      primaryPlanPrice: plan.price,
      selectedPlan: plan,
      flow: GuestPurchasePlanConfirmationEntryFlow.skip,
      forceNow: true,
    );
  }

  GuestPurchasePlanConfirmationRouteArgs _futurePlanConfirmationArgs(
    GuestPlanDisplayModel plan, {
    required String futurePlanStartDate,
  }) {
    return GuestPurchasePlanConfirmationRouteArgs(
      phoneNumber: phoneNumber,
      accountHolderName: 'guest purchase a plan',
      primaryPlanName: plan.title,
      primaryPlanPrice: plan.price,
      selectedPlan: plan,
      futurePlanStartDate: futurePlanStartDate,
      flow: GuestPurchasePlanConfirmationEntryFlow.skip,
      forceNow: false,
    );
  }

  Widget _buildAddOnsTabContent(
    BuildContext context,
    GuestPurchasePlanState state,
  ) {
    final activePlan = _activePlanSummaryFromState(state);
    final fairUsePolicy = _fairUsePolicyForAddOnsTab();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _addOnsTabHorizontalPadding,
        20,
        _addOnsTabHorizontalPadding,
        16,
      ),
      children: <Widget>[
        if (activePlan != null) ...[
          PlanRedImageCard(
            planLabel: activePlan.label,
            planName: activePlan.name,
            activeLabel: activePlan.activeDateLabel,
            activeDate: activePlan.activeDate,
            expireLabel: activePlan.expireDateLabel,
            expireDate: activePlan.expireDate,
            expireTime: activePlan.expireTime,
          ),
          const SizedBox(height: 16),
          FairUsePolicyCard(policy: fairUsePolicy, onTap: () {}),
          const SizedBox(height: 16),
        ],
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

  void _onPurchaseNowPressed(BuildContext context, GuestPlanDisplayModel plan) {
    final bloc = context.read<GuestPurchasePlanBloc>();
    bloc.add(GuestPurchasePlanPurchaseNowPressed(plan));

    final GuestPurchasePlanState currentState = bloc.state;

    // Guard: block the sheet while /Guest/existingplans is still loading.
    // Without this, hasActivePrimaryPlan would read false and we'd show
    // the "no active plan" sheet to a number that actually has one —
    // the user would then silently overwrite their real plan.
    // Mirrors prepaid's isRefreshingBundles guard
    // (home_plan_purchase_sheet_launcher.dart:300-306).
    if (currentState.isLoadingBundles) {
      AppToast.show(
        message: 'checking the account plans, please try again in a moment',
        type: ToastType.error,
      );
      return;
    }

    // Store the raw BasePlanModel on state so the activate-now sheet and
    // the dedicated add-ons screen can access `availableBoltOns`,
    // `frequency`, etc. Repository lookup is synchronous — the catalog
    // was already awaited when the tile was rendered.
    final BasePlanModel? basePlan = bloc.repository.findBasePlanById(plan.id);
    if (basePlan != null) {
      bloc.add(GuestPrimaryPlanSelected(basePlan));
    }

    final PlanTab selectedTab = currentState.selectedTab;

    // Mirror prepaid showHomePlanPurchaseBottomSheet: use the entered
    // number's /Guest/existingplans data to pick between
    // WalletPaymentActivateBottomSheet (no active plan OR row 5 schedule-only)
    // and WalletPaymentActivateOrFutureBottomSheet (row 4 — active with no
    // future primary).
    final DateTime? chainStartDate = currentState.latestPrimaryPlanEndDate;
    final String futurePlanStartDate = chainStartDate?.toIso8601String() ?? '';

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

        // Row 5: active primary + already-queued future primary →
        // schedule-only, no "activate now" option. Mirrors prepaid
        // home_plan_purchase_sheet_launcher.dart:99-122, including the
        // use of latestPurchasedPlanEndDate (primary + secondary +
        // standalone) so the next primary waits until EVERY purchased
        // plan ends, not just the latest primary.
        if (currentState.hasActivePrimaryWithFuturePrimaryPlans) {
          final DateTime? lastPlanEndDate =
              currentState.latestPurchasedPlanEndDate;
          // Do not invent a schedule date if the API supplied no valid
          // end date — fall through to Row 4.
          if (lastPlanEndDate != null) {
            final String dateText = DateFormat(
              'MM-dd-yy',
            ).format(lastPlanEndDate);
            return WalletPaymentActivateBottomSheet(
              warningText:
                  'you can activate your plan when the current plan ends on $dateText.',
              buttonLabel: 'future plan',
              planName: plan.title,
              planDurationText: plan.subtitle,
              planPriceText: plan.formattedPrice,
              onBackPressed: () => Navigator.of(sheetContext).pop(),
              onActivateNowPressed: () {
                Navigator.of(sheetContext).pop();
                context.push(
                  AppRoutes.guestPurchasePlanConfirmation,
                  extra: _futurePlanConfirmationArgs(
                    plan,
                    futurePlanStartDate: lastPlanEndDate.toIso8601String(),
                  ),
                );
              },
            );
          }
        }

        // Row 4: active primary with no future primary → activate-now OR
        // schedule. Warning text references the real end date, and
        // special-cases MiFi-on-MiFi (same copy prepaid uses at
        // home_plan_purchase_sheet_launcher.dart:142-151).
        if (currentState.hasActivePrimaryPlan) {
          final String endDateText = chainStartDate != null
              ? ' on ${DateFormat('MM-dd-yy').format(chainStartDate)}'
              : '';
          final bool hasActiveMifiPlan =
              selectedTab == PlanTab.mifi &&
              PlanGroup.parse(
                    currentState.earliestAddOnsPrimaryPlan?.planGroup,
                  ) ==
                  PlanGroup.mifi;
          final String warningText = hasActiveMifiPlan
              ? 'the account owner already has an active mifi plan. '
                    'buying this plan will replace it immediately.'
              : 'activating now replaces the current plan, '
                    'you can also activate the plan when the current plan ends$endDateText.';
          return WalletPaymentActivateOrFutureBottomSheet(
            warningText: warningText,
            planName: plan.title,
            planDurationText: plan.subtitle,
            planPriceText: plan.formattedPrice,
            onBackPressed: () => Navigator.of(sheetContext).pop(),
            onActivateNowPressed: () {
              Navigator.of(sheetContext).pop();

              // MiFi plans skip add-ons; go straight to confirmation.
              if (selectedTab == PlanTab.mifi) {
                context.push(
                  AppRoutes.guestPurchasePlanConfirmation,
                  extra: _mifiConfirmationArgs(plan),
                );
                return;
              }

              context.push(
                AppRoutes.guestPurchasePlanAddOns,
                extra: GuestPurchasePlanAddOnsRouteArgs(
                  phoneNumber: phoneNumber,
                  selectedPlan: plan,
                  selectedBasePlan: basePlan,
                  existingActivePlan: currentState.earliestAddOnsPrimaryPlan,
                ),
              );
            },
            onFuturePlanPressed: () {
              Navigator.of(sheetContext).pop();
              context.push(
                AppRoutes.guestPurchasePlanConfirmation,
                extra: _futurePlanConfirmationArgs(
                  plan,
                  futurePlanStartDate: futurePlanStartDate,
                ),
              );
            },
          );
        }

        // No active primary plan → immediate activation only.
        return WalletPaymentActivateBottomSheet(
          warningText:
              'the account owner has no active plan, so their new plan will start immediately.',
          planName: plan.title,
          planDurationText: plan.subtitle,
          planPriceText: plan.formattedPrice,
          onBackPressed: () => Navigator.of(sheetContext).pop(),
          onActivateNowPressed: () {
            Navigator.of(sheetContext).pop();

            // MiFi plans do not support add-ons, so their purchase flow goes
            // straight to confirmation with the selected plan details.
            if (selectedTab == PlanTab.mifi) {
              context.push(
                AppRoutes.guestPurchasePlanConfirmation,
                extra: _mifiConfirmationArgs(plan),
              );
              return;
            }

            context.push(
              AppRoutes.guestPurchasePlanAddOns,
              extra: GuestPurchasePlanAddOnsRouteArgs(
                phoneNumber: phoneNumber,
                selectedPlan: plan,
              ),
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
                amountText: AppUtils.formatPrice(total),
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
                    return const PlanCardShimmerList();
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
