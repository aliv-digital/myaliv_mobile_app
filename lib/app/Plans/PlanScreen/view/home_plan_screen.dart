import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import '../cubit/plans_cubit.dart';
import '../cubit/plans_state.dart';
import '../models/add_on_model.dart';
import '../models/base_plan_model.dart';
import '../models/plan_model.dart';
import '../repository/plan_types.dart';
import '../theme/theme.dart';
import '../widgets/home_plan_add_ons_tab_content.dart';
import '../widgets/home_plan_plans_list.dart';
import '../widgets/home_plan_purchase_sheet_launcher.dart';
import '../widgets/home_plan_section_header.dart';
import '../widgets/plan_tabs.dart';
import '../widgets/plan_card_shimmer.dart';
import '../widgets/plan_empty_state.dart';
import 'start_plan_bottom_sheet.dart';

class HomePlanScreen extends StatelessWidget {
  final HomePlanTab? initialTab;

  const HomePlanScreen({super.key, this.initialTab});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return _HomePlanView(initialTab: initialTab);
  }
}

class _HomePlanView extends StatefulWidget {
  final HomePlanTab? initialTab;

  const _HomePlanView({this.initialTab});

  @override
  State<_HomePlanView> createState() => _HomePlanViewState();
}

class _HomePlanViewState extends State<_HomePlanView> {
  @override
  void initState() {
    super.initState();
    final userType = context.read<AppUiConfigCubit>().state.userType;
    context.read<PlansCubit>().started(
          userType: userType,
          initialTab: widget.initialTab,
        );
  }

  // Primary tabs use API models, while the shared purchase sheet still expects
  // the older UI model.
  HomePlanModel _toPrimaryPurchaseSheetPlan(BasePlanModel plan) {
    return HomePlanModel(
      id: plan.planId,
      title: plan.planName,
      subtitle: _planDurationText(plan),
      price: plan.planAmount + plan.vatAmount,
      description: plan.planDescription,
      benefits: const <HomePlanBenefit>[],
    );
  }

  HomePlanModel _toRoamingPurchaseSheetPlan(BasePlanModel plan) {
    return HomePlanModel(
      id: plan.planId,
      title: plan.planName,
      subtitle: '',
      price: plan.planAmount,
      description: plan.planDescription,
      benefits: const <HomePlanBenefit>[],
    );
  }

  HomePlanModel _toRoamEasyPurchaseSheetPlan(BasePlanModel plan) {
    return HomePlanModel(
      id: plan.planId,
      title: plan.planName,
      subtitle: '',
      price: plan.planAmount,
      description: plan.planDescription,
      benefits: const <HomePlanBenefit>[],
    );
  }

  HomePlanModel _toMifiPurchaseSheetPlan(BasePlanModel plan) {
    return HomePlanModel(
      id: plan.planId,
      title: plan.planName,
      subtitle: '',
      price: plan.planAmount,
      description: plan.planDescription,
      benefits: const <HomePlanBenefit>[],
    );
  }

  HomePlanModel _toLibertyGlobalPurchaseSheetPlan(BasePlanModel plan) {
    return HomePlanModel(
      id: plan.planId,
      title: plan.planName,
      subtitle: '',
      price: plan.planAmount,
      description: plan.planDescription,
      benefits: const <HomePlanBenefit>[],
    );
  }

  String _planDurationText(BasePlanModel plan) {
    final frequency = plan.frequency.trim().toUpperCase();

    switch (frequency) {
      case 'D':
        return '1 day';
      case '3':
        return '3 days';
      case '5':
        return '5 days';
      case 'W':
        return '7 days';
      case 'T':
        return '10 days';
      case 'B':
      case 'H':
        return '15 days';
      case 'M':
        return '30 days';
      case 'S':
        return '60 days';
      case 'N':
        return '90 days';
      case 'A':
        return '1 year';
      default:
        return '';
    }
  }

  void _onPurchaseNowPressed(
    BuildContext context,
    HomePlanModel plan, {
    required HomeUiConfig homeUiConfig,
    BasePlanModel? selectedApiPlan,
    int? selectedIndex,
  }) {
    final cubit = context.read<PlansCubit>();

    // Prevent opening multiple purchase modals simultaneously
    if (cubit.state.isPurchaseModalOpen) {
      return;
    }

    _logSelectedApiPlan(
      selectedTab: cubit.state.selectedTab,
      selectedApiPlan: selectedApiPlan,
      selectedIndex: selectedIndex,
    );

    cubit.purchaseNowPressed(plan);
    showHomePlanPurchaseBottomSheet(
      context: context,
      plan: plan,
      selectedTab: cubit.state.selectedTab,
      homeUiConfig: homeUiConfig,
      selectedApiPlan: selectedApiPlan,
      selectedIndex: selectedIndex,
    ).then((_) {
      // Clear the modal open flag when bottom sheet is dismissed
      cubit.purchaseModalClosed();
    });
  }

  void _logSelectedApiPlan({
    required HomePlanTab selectedTab,
    required BasePlanModel? selectedApiPlan,
    required int? selectedIndex,
  }) {
    if (selectedApiPlan == null || selectedIndex == null) {
      return;
    }

    debugPrint('Selected ${selectedTab.name} plan index: $selectedIndex');
    debugPrint(
      'Selected ${selectedTab.name} plan object: '
      '${selectedApiPlan.toDebugMap()}',
    );

    if (selectedApiPlan.availableBoltOns.isNotEmpty) {
      debugPrint(
        'First available bolt-on: '
        '${selectedApiPlan.availableBoltOns.first.planName}',
      );
    }
  }

  void _showPostpaidStartBottomSheet(BuildContext context) {
    final cubit = context.read<PlansCubit>();

    // Prevent opening multiple purchase modals simultaneously
    if (cubit.state.isPurchaseModalOpen) {
      return;
    }

    cubit.purchaseNowPressed(
      HomePlanModel(
        id: 'postpaid',
        title: 'Postpaid Plan',
        subtitle: '',
        price: 0.0,
        description: '',
        benefits: const [],
      ),
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const StartPlanBottomSheet(),
    ).then((_) {
      // Clear the modal open flag when bottom sheet is dismissed
      cubit.purchaseModalClosed();
    });
  }

  List<HomePlanTab> _tabsForUserType(UserType userType) {
    if (userType == UserType.postpaid) {
      return const [HomePlanTab.postpaidRoaming];
    }

    return const [
      HomePlanTab.daily,
      HomePlanTab.weekly,
      HomePlanTab.monthly,
      HomePlanTab.roaming,
      HomePlanTab.roameasy,
      HomePlanTab.addOns,
      HomePlanTab.mifi,
      HomePlanTab.libertyGlobal,
    ];
  }

  Widget _buildTabContent(
    BuildContext context,
    PlansState currentState,
    PlansStatus currentTabStatus,
    String? currentTabError,
    HomeUiConfig homeUiConfig,
  ) {
    // Loading state - show shimmer
    if (currentTabStatus == PlansStatus.loading ||
        currentTabStatus == PlansStatus.initial) {
      if (currentState.selectedTab == HomePlanTab.addOns) {
        return const AddOnShimmerList();
      }
      return const PlanCardShimmerList();
    }

    // Error state - show error with retry button
    if (currentTabStatus == PlansStatus.failure) {
      return PlanErrorState(
        errorMessage: currentTabError ?? 'Something went wrong',
        onRetry: () {
          context.read<PlansCubit>().refreshCurrentTab();
        },
      );
    }

    // Success state - check if data exists
    if (currentState.selectedTab == HomePlanTab.addOns) {
      // Block add-on purchase when no active primary plan exists.
      if (currentState.earliestAddOnsPrimaryPlan == null) {
        return AddOnsNoPrimaryPlanState(
          onPurchasePlan: () {
            context.read<PlansCubit>().changeTab(HomePlanTab.monthly);
          },
        );
      }

      // Check if add-ons list is empty
      if (currentState.addOns.isEmpty) {
        return PlanEmptyState(
          message: 'No add-ons available at the moment',
          onRefresh: () {
            context.read<PlansCubit>().refreshCurrentTab();
          },
        );
      }

      return HomePlanAddOnsTabContent(
        activePrimaryPlan: currentState.earliestAddOnsPrimaryPlan,
        addOns: currentState.addOns,
        selectedAddOnIds: currentState.selectedAddOnIds,
        onToggleAddOn: (addOn) {
          context.read<PlansCubit>().toggleAddon(addOn);
        },
      );
    }

    // Check if plans list is empty for the current tab
    final bool isEmpty = _isCurrentTabEmpty(currentState);
    if (isEmpty) {
      return PlanEmptyState(
        message: 'No plans available for this category',
        onRefresh: () {
          context.read<PlansCubit>().refreshCurrentTab();
        },
      );
    }

    return HomePlanPlansList(
      state: currentState,
      onToggleExpanded: (planId) {
        context.read<PlansCubit>().toggleExpanded(planId);
      },
      onWeeklyPurchaseNow: (plan, index) {
        _onPurchaseNowPressed(
          context,
          _toPrimaryPurchaseSheetPlan(plan),
          homeUiConfig: homeUiConfig,
          selectedApiPlan: plan,
          selectedIndex: index,
        );
      },
      onDailyPurchaseNow: (plan, index) {
        _onPurchaseNowPressed(
          context,
          _toPrimaryPurchaseSheetPlan(plan),
          homeUiConfig: homeUiConfig,
          selectedApiPlan: plan,
          selectedIndex: index,
        );
      },
      onMonthlyPurchaseNow: (plan, index) {
        _onPurchaseNowPressed(
          context,
          _toPrimaryPurchaseSheetPlan(plan),
          homeUiConfig: homeUiConfig,
          selectedApiPlan: plan,
          selectedIndex: index,
        );
      },
      onMifiPurchaseNow: (plan) {
        _onPurchaseNowPressed(
          context,
          _toMifiPurchaseSheetPlan(plan),
          homeUiConfig: homeUiConfig,
        );
      },
      onLibertyGlobalPurchaseNow: (plan) {
        _onPurchaseNowPressed(
          context,
          _toLibertyGlobalPurchaseSheetPlan(plan),
          homeUiConfig: homeUiConfig,
        );
      },
      onRoamingPurchaseNow: (plan) {
        _onPurchaseNowPressed(
          context,
          _toRoamingPurchaseSheetPlan(plan),
          homeUiConfig: homeUiConfig,
        );
      },
      onRoamEasyPurchaseNow: (plan) {
        _onPurchaseNowPressed(
          context,
          _toRoamEasyPurchaseSheetPlan(plan),
          homeUiConfig: homeUiConfig,
        );
      },
      onPostpaidRoamingPurchaseNow: (HomePlansPostPaidPlanModel _) {
        _showPostpaidStartBottomSheet(context);
      },
      onPurchaseNow: (plan) {
        //_onPurchaseNowPressed(context, plan);
      },
    );
  }

  void _openAddOnsConfirmation(BuildContext context, PlansState state) {
    final selected = state.addOns
        .where((addOn) => state.selectedAddOnIds.contains(addOn.id))
        .toList(growable: false);

    if (selected.isEmpty) {
      return;
    }

    final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
    if (accountInfo == null) {
      AppToast.show(
        message: 'account information is unavailable, please try again',
        type: ToastType.error,
      );
      return;
    }

    final fullName = <String>[
      accountInfo.fName,
      accountInfo.lName,
    ].where((part) => part.trim().isNotEmpty).join(' ').trim();
    final phoneNumber = accountInfo.phoneNumber.isNotEmpty
        ? accountInfo.phoneNumber
        : accountInfo.primaryPhoneNumber;

    final activePlan = state.earliestAddOnsPrimaryPlan;

    final args = HomePlanConfirmationRouteArgs(
      phoneNumber: phoneNumber,
      accountHolderName: fullName,
      primaryPlanName: activePlan?.planName ?? '',
      primaryPlanPrice: 0,
      flow: HomePlanConfirmationEntryFlow.proceed,
      isPrimaryPlanActive: true,
      selectedAddOns: selected
          .map(
            (HomePlanAddOnModel addOn) => HomePlanConfirmationSelectedAddOn(
              id: addOn.id,
              title: addOn.title,
              price: addOn.price,
              vatAmount: addOn.vatAmount,
            ),
          )
          .toList(growable: false),
    );

    context.push(AppRoutes.homePlanConfirmationScreen, extra: args);
  }

  bool _isCurrentTabEmpty(PlansState state) {
    switch (state.selectedTab) {
      case HomePlanTab.daily:
        return state.dailyApiPlans.isEmpty;
      case HomePlanTab.weekly:
        return state.weeklyApiPlans.isEmpty;
      case HomePlanTab.monthly:
        return state.monthlyApiPlans.isEmpty;
      case HomePlanTab.roaming:
        return state.roamingApiPlans.isEmpty;
      case HomePlanTab.roameasy:
        return state.roamEasyApiPlans.isEmpty;
      case HomePlanTab.mifi:
        return state.mifiApiPlans.isEmpty;
      case HomePlanTab.libertyGlobal:
        return state.libertyGlobalApiPlans.isEmpty;
      case HomePlanTab.postpaidRoaming:
        return state.postpaidRoamingApiPlans.isEmpty;
      case HomePlanTab.addOns:
        return state.addOns.isEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig homeUiConfig = context.watch<AppUiConfigCubit>().state;
    debugPrint("active plan : ${homeUiConfig.hasActivePlan}");

    final tabs = _tabsForUserType(homeUiConfig.userType);
    final isPostpaid = homeUiConfig.userType == UserType.postpaid;
    final appBarTitle = isPostpaid ? 'roaming data add-ons' : 'plans';

    return BlocListener<PlansCubit, PlansState>(
      listenWhen: (previous, current) {
        return previous.pendingToast?.id != current.pendingToast?.id;
      },
      listener: (context, state) {
        final toast = state.pendingToast;
        if (toast == null) {
          return;
        }

        AppToast.show(message: toast.message, type: ToastType.error);
        context.read<PlansCubit>().toastConsumed();
      },
      child: Scaffold(
        backgroundColor: HomePlanTheme.screenBackground,
        bottomNavigationBar: BlocBuilder<PlansCubit, PlansState>(
          buildWhen: (previous, current) {
            return previous.selectedTab != current.selectedTab ||
                previous.selectedTabStatus != current.selectedTabStatus ||
                previous.selectedAddOnIds != current.selectedAddOnIds ||
                previous.addOns != current.addOns;
          },
          builder: (context, state) {
            return HomePlanAddOnsBottomPayBar(
              state: state,
              onPayNow: () => _openAddOnsConfirmation(context, state),
            );
          },
        ),
        body: SafeArea(
          child: BlocBuilder<PlansCubit, PlansState>(
            buildWhen: (previous, current) {
              // Rebuild when tab changes OR when tab status changes
              final tabChanged = previous.selectedTab != current.selectedTab;
              final statusChanged =
                  previous.selectedTabStatus != current.selectedTabStatus;

              return tabChanged || statusChanged;
            },
            builder: (context, state) {
              if (!tabs.contains(state.selectedTab)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<PlansCubit>().changeTab(tabs.first);
                });
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  DefaultAppBar(
                    showHome: true,
                    showBackArrow: false,
                    showNotification: false,
                    showNotificationDotWhenZero: true,
                    title: appBarTitle,
                    onBack: context.pop,
                    onHomeTap: () => context.go(AppRoutes.home),
                  ),
                  if (!isPostpaid)
                    HomePlanTabs(
                      selected: state.selectedTab,
                      tabs: tabs,
                      onChanged: (tab) =>
                          context.read<PlansCubit>().changeTab(tab),
                    ),
                  if (!isPostpaid) const SizedBox(height: 6),
                  HomePlanSectionHeader(selectedTab: state.selectedTab),
                  Expanded(
                    child: BlocBuilder<PlansCubit, PlansState>(
                      builder: (context, currentState) {
                        final currentTabStatus = currentState.selectedTabStatus;
                        final currentTabError =
                            currentState.selectedTabErrorMessage;

                        return RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<PlansCubit>()
                                .refreshCurrentTab();
                          },
                          child: _buildTabContent(
                            context,
                            currentState,
                            currentTabStatus,
                            currentTabError,
                            homeUiConfig,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
