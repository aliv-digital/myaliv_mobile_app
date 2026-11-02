import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/home_plan_add_ons_actions.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/home_plan_add_ons_tab_content.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/plan_add_ons_body.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

/// Reuses the PlanScreen add-ons body and bottom pay bar verbatim. No tabs,
/// no bottom-nav — just the add-ons content as its own screen reachable from
/// the user-profile purchases entry.
class PurchaseAddOnsScreen extends StatefulWidget {
  const PurchaseAddOnsScreen({super.key});

  @override
  State<PurchaseAddOnsScreen> createState() => _PurchaseAddOnsScreenState();
}

class _PurchaseAddOnsScreenState extends State<PurchaseAddOnsScreen> {
  late final PlansCubit _plansCubit;

  @override
  void initState() {
    super.initState();
    _plansCubit = context.read<PlansCubit>();
    _plansCubit.clearSelectedAddOns();
    final userType = context.read<AppUiConfigCubit>().state.userType;
    _plansCubit.started(userType: userType, initialTab: HomePlanTab.addOns);
    if (_plansCubit.state.selectedTab != HomePlanTab.addOns) {
      _plansCubit.changeTab(HomePlanTab.addOns);
    }
  }

  @override
  void dispose() {
    _plansCubit.clearSelectedAddOns();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userType = context.watch<AppUiConfigCubit>().state.userType;
    final title = userType == UserType.postpaid
        ? 'roaming data add-ons'
        : 'add-ons';

    return Scaffold(
      bottomNavigationBar: BlocBuilder<PlansCubit, PlansState>(
        buildWhen: (previous, current) =>
            previous.selectedTabStatus != current.selectedTabStatus ||
            previous.selectedAddOnIds != current.selectedAddOnIds ||
            previous.addOns != current.addOns,
        builder: (context, state) {
          return HomePlanAddOnsBottomPayBar(
            state: state,
            requireAddOnsTab: false,
            onPayNow: () =>
                HomePlanAddOnsActions.openConfirmation(context, state),
          );
        },
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            DefaultAppBar(
              title: title,
              showHome: true,
              showBackArrow: true,
              showNotification: false,
              showNotificationDotWhenZero: true,
              onBack: context.pop,
              onHomeTap: () => context.go(AppRoutes.home),
            ),
            Expanded(
              child: PlanAddOnsBody(
                onNoPrimaryPlanPurchase: () => context.go(AppRoutes.plans),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
