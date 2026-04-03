import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../bloc/home_plan_bloc.dart';
import '../bloc/home_plan_event.dart';
import '../bloc/home_plan_state.dart';
import '../models/liberty_global_plan_model.dart';
import '../models/mifi_plan_model.dart';
import '../models/monthly_plan_model.dart';
import '../models/plan_model.dart';
import '../models/roaming_plan_model.dart';
import '../models/roameasy_plan_model.dart';
import '../repository/home_plan_repository.dart';
import '../theme/theme.dart';
import '../widgets/home_plan_add_ons_tab_content.dart';
import '../widgets/home_plan_plans_list.dart';
import '../widgets/home_plan_purchase_sheet_launcher.dart';
import '../widgets/home_plan_section_header.dart';
import '../widgets/plan_tabs.dart';

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
    context.read<HomePlanBloc>().add(HomePlanPurchaseNowPressed(plan));

    final selectedTab = context.read<HomePlanBloc>().state.selectedTab;

    showHomePlanPurchaseBottomSheet(
      context: context,
      plan: plan,
      selectedTab: selectedTab,
    );
  }

  void _onRoamingPurchaseNowPressed(BuildContext context,RoamingPlanModel plan) {
    _onPurchaseNowPressed(context, _toRoamingPurchaseSheetPlan(plan));
  }

  void _onRoamEasyPurchaseNowPressed(
    BuildContext context,
    RoamEasyPlanModel plan,
  ) {
    _onPurchaseNowPressed(context, _toRoamEasyPurchaseSheetPlan(plan));
  }

  void _onMifiPurchaseNowPressed(BuildContext context, MifiPlanModel plan) {
    _onPurchaseNowPressed(context, _toMifiPurchaseSheetPlan(plan));
  }

  void _onLibertyGlobalPurchaseNowPressed(
    BuildContext context,
    LibertyGlobalPlanModel plan,
  ) {
    _onPurchaseNowPressed(context, _toLibertyGlobalPurchaseSheetPlan(plan));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomePlanBloc, HomePlanState>(
      listenWhen: (previous, current) {
        final HomePlanToastMessage? previousToast = previous.pendingToast;
        final HomePlanToastMessage? currentToast = current.pendingToast;
        return previousToast?.id != currentToast?.id;
      },
      listener: (context, state) {
        final HomePlanToastMessage? toast = state.pendingToast;
        if (toast == null) return;

        AppToast.show(
          message: toast.message,
          type: ToastType.error,
        );
        context.read<HomePlanBloc>().add(HomePlanToastConsumed());
      },
      child: Scaffold(
        backgroundColor: HomePlanTheme.screenBackground,
        bottomNavigationBar: BlocBuilder<HomePlanBloc, HomePlanState>(
          buildWhen: (previous, current) {
            return previous.selectedTab != current.selectedTab ||
                previous.selectedTabStatus != current.selectedTabStatus ||
                previous.selectedAddOnIds != current.selectedAddOnIds ||
                previous.addOns != current.addOns;
          },
          builder: (context, state) {
            return HomePlanAddOnsBottomPayBar(
              state: state,
              onPayNow: () {
                context.push(AppRoutes.homePlanConfirmationScreen);
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
              BlocBuilder<HomePlanBloc, HomePlanState>(
                buildWhen: (p, c) => p.selectedTab != c.selectedTab,
                builder: (context, state) {
                  return HomePlanSectionHeader(selectedTab: state.selectedTab);
                },
              ),
              Expanded(
                child: BlocBuilder<HomePlanBloc, HomePlanState>(
                  builder: (context, state) {
                    final HomePlanStatus currentTabStatus =
                        state.selectedTabStatus;
                    final String? currentTabError =
                        state.selectedTabErrorMessage;

                    if (currentTabStatus == HomePlanStatus.loading ||
                        currentTabStatus == HomePlanStatus.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (currentTabStatus == HomePlanStatus.failure) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsetsGeometry.only(left: 25, right: 25),
                          child: Text(
                            currentTabError ?? 'Something went wrong',
                            style: HomePlanTheme.bodyErrorText,
                          ),
                        ),
                      );
                    }

                    if (state.selectedTab == HomePlanTab.addOns) {
                      return HomePlanAddOnsTabContent(
                        addOns: state.addOns,
                        selectedAddOnIds: state.selectedAddOnIds,
                        onToggleAddOn: (addOn) {
                          context
                              .read<HomePlanBloc>()
                              .add(HomePlanToggleAddon(addOn));
                        },
                      );
                    }

                    return HomePlanPlansList(
                      state: state,
                      onToggleExpanded: (planId) {
                        debugPrint('planId: $planId');
                        context.read<HomePlanBloc>().add(HomePlanToggleExpanded(planId));
                      },
                      onWeeklyPurchaseNow: (plan) {
                        debugPrint('plan: ${plan.planName}');
                        // _onPurchaseNowPressed(context, plan);
                      },
                      onDailyPurchaseNow: (plan) {
                        debugPrint('plan: ${plan.planName}');
                        // _onPurchaseNowPressed(context, plan);
                      },
                      onMonthlyPurchaseNow: (MonthlyPlanModel plan) {
                        debugPrint('plan: ${plan.planName}');
                        // _onPurchaseNowPressed(context, plan);
                      },
                      onMifiPurchaseNow: (MifiPlanModel plan) {
                        debugPrint('plan: ${plan.planName}');
                        _onMifiPurchaseNowPressed(context, plan);
                      },
                      onLibertyGlobalPurchaseNow:
                          (LibertyGlobalPlanModel plan) {
                        debugPrint('plan: ${plan.planName}');
                        _onLibertyGlobalPurchaseNowPressed(context, plan);
                      },
                      onRoamingPurchaseNow: (RoamingPlanModel plan) {
                        debugPrint('plan: ${plan.planName}');
                        _onRoamingPurchaseNowPressed(context, plan);
                      },
                      onRoamEasyPurchaseNow: (RoamEasyPlanModel plan) {
                        debugPrint('plan: ${plan.planName}');
                        _onRoamEasyPurchaseNowPressed(context, plan);
                      },
                      onPurchaseNow: (plan) {
                        debugPrint('plan: ${plan.id}');
                        _onPurchaseNowPressed(context, plan);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
