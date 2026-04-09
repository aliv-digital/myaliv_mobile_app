import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import '../cubit/home_plan_cubit.dart';
import '../cubit/home_plan_state.dart';
import '../models/liberty_global_plan_model.dart';
import '../models/mifi_plan_model.dart';
import '../models/plan_model.dart';
import '../models/roameasy_plan_model.dart';
import '../models/roaming_plan_model.dart';
import '../repository/plan_types.dart';
import '../theme/theme.dart';
import '../widgets/home_plan_add_ons_tab_content.dart';
import '../widgets/home_plan_plans_list.dart';
import '../widgets/home_plan_purchase_sheet_launcher.dart';
import '../widgets/home_plan_section_header.dart';
import '../widgets/plan_tabs.dart';
import 'start_plan_bottom_sheet.dart';

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

    return const _HomePlanView();
  }
}

class _HomePlanView extends StatefulWidget {
  const _HomePlanView();

  @override
  State<_HomePlanView> createState() => _HomePlanViewState();
}

class _HomePlanViewState extends State<_HomePlanView> {
  @override
  void initState() {
    super.initState();
    final userType = context.read<AppUiConfigCubit>().state.userType;
    context.read<HomePlanCubit>().started(userType: userType);
  }

  HomePlanModel _toRoamingPurchaseSheetPlan(RoamingPlanModel plan) {
    return HomePlanModel(
      id: plan.planId,
      title: plan.planName,
      subtitle: '',
      price: plan.planAmount,
      description: plan.planDescription,
      benefits: const <HomePlanBenefit>[],
    );
  }

  HomePlanModel _toRoamEasyPurchaseSheetPlan(RoamEasyPlanModel plan) {
    return HomePlanModel(
      id: plan.planId,
      title: plan.planName,
      subtitle: '',
      price: plan.planAmount,
      description: plan.planDescription,
      benefits: const <HomePlanBenefit>[],
    );
  }

  HomePlanModel _toMifiPurchaseSheetPlan(MifiPlanModel plan) {
    return HomePlanModel(
      id: plan.planId,
      title: plan.planName,
      subtitle: '',
      price: plan.planAmount,
      description: plan.planDescription,
      benefits: const <HomePlanBenefit>[],
    );
  }

  HomePlanModel _toLibertyGlobalPurchaseSheetPlan(
    LibertyGlobalPlanModel plan,
  ) {
    return HomePlanModel(
      id: plan.planId,
      title: plan.planName,
      subtitle: '',
      price: plan.planAmount,
      description: plan.planDescription,
      benefits: const <HomePlanBenefit>[],
    );
  }

  void _onPurchaseNowPressed(BuildContext context, HomePlanModel plan) {
    context.read<HomePlanCubit>().purchaseNowPressed(plan);
    showHomePlanPurchaseBottomSheet(
      context: context,
      plan: plan,
      selectedTab: context.read<HomePlanCubit>().state.selectedTab,
    );
  }

  void _showPostpaidStartBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => const StartPlanBottomSheet(),
    );
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

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppUiConfigCubit>().state;
    final tabs = _tabsForUserType(config.userType);
    final isPostpaid = config.userType == UserType.postpaid;
    final appBarTitle = isPostpaid ? 'roaming data add-ons' : 'plans';

    return BlocListener<HomePlanCubit, HomePlanState>(
      listenWhen: (previous, current) {
        return previous.pendingToast?.id != current.pendingToast?.id;
      },
      listener: (context, state) {
        final toast = state.pendingToast;
        if (toast == null) {
          return;
        }

        AppToast.show(
          message: toast.message,
          type: ToastType.error,
        );
        context.read<HomePlanCubit>().toastConsumed();
      },
      child: Scaffold(
        backgroundColor: HomePlanTheme.screenBackground,
        bottomNavigationBar: BlocBuilder<HomePlanCubit, HomePlanState>(
          buildWhen: (previous, current) {
            return previous.selectedTab != current.selectedTab ||
                previous.selectedTabStatus != current.selectedTabStatus ||
                previous.selectedAddOnIds != current.selectedAddOnIds ||
                previous.addOns != current.addOns;
          },
          builder: (context, state) {
            return HomePlanAddOnsBottomPayBar(
              state: state,
              onPayNow: () => context.push(AppRoutes.homePlanConfirmationScreen),
            );
          },
        ),
        body: SafeArea(
          child: BlocBuilder<HomePlanCubit, HomePlanState>(
            buildWhen: (previous, current) =>
                previous.selectedTab != current.selectedTab,
            builder: (context, state) {
              if (!tabs.contains(state.selectedTab)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<HomePlanCubit>().changeTab(tabs.first);
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
                          context.read<HomePlanCubit>().changeTab(
                                tab,
                              ),
                    ),
                  if (!isPostpaid) const SizedBox(height: 6),
                  HomePlanSectionHeader(selectedTab: state.selectedTab),
                  Expanded(
                    child: BlocBuilder<HomePlanCubit, HomePlanState>(
                      builder: (context, currentState) {
                        final currentTabStatus = currentState.selectedTabStatus;
                        final currentTabError =
                            currentState.selectedTabErrorMessage;

                        if (currentTabStatus == HomePlanStatus.loading ||
                            currentTabStatus == HomePlanStatus.initial) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (currentTabStatus == HomePlanStatus.failure) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                currentTabError ?? 'Something went wrong',
                                style: HomePlanTheme.bodyErrorText,
                              ),
                            ),
                          );
                        }

                        if (currentState.selectedTab == HomePlanTab.addOns) {
                          return HomePlanAddOnsTabContent(
                            activePrimaryPlan:
                                currentState.earliestAddOnsPrimaryPlan,
                            addOns: currentState.addOns,
                            selectedAddOnIds: currentState.selectedAddOnIds,
                            onToggleAddOn: (addOn) {
                              context.read<HomePlanCubit>().toggleAddon(addOn);
                            },
                          );
                        }

                        return HomePlanPlansList(
                          state: currentState,
                          onToggleExpanded: (planId) {
                            context.read<HomePlanCubit>().toggleExpanded(planId);
                          },
                          onWeeklyPurchaseNow: (_) {},
                          onDailyPurchaseNow: (_) {},
                          onMonthlyPurchaseNow: (_) {},
                          onMifiPurchaseNow: (plan) {
                            _onPurchaseNowPressed(
                              context,
                              _toMifiPurchaseSheetPlan(plan),
                            );
                          },
                          onLibertyGlobalPurchaseNow: (plan) {
                            _onPurchaseNowPressed(
                              context,
                              _toLibertyGlobalPurchaseSheetPlan(plan),
                            );
                          },
                          onRoamingPurchaseNow: (plan) {
                            _onPurchaseNowPressed(
                              context,
                              _toRoamingPurchaseSheetPlan(plan),
                            );
                          },
                          onRoamEasyPurchaseNow: (plan) {
                            _onPurchaseNowPressed(
                              context,
                              _toRoamEasyPurchaseSheetPlan(plan),
                            );
                          },
                          onPostpaidRoamingPurchaseNow:
                              (HomePlansPostPaidPlanModel _) {
                            _showPostpaidStartBottomSheet(context);
                          },
                          onPurchaseNow: (plan) {
                            _onPurchaseNowPressed(context, plan);
                          },
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
