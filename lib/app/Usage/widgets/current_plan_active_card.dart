import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_with_data.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/no_active_plan_card.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/postpaid_current_plan.dart';

/// Top-of-tab card on Usage → current plan. Shows the active primary
/// plan card while plans are loading or once one is found, or a
/// `NoActivePlanCard` fallback when the resolved primary list is empty.
class CurrentPlanActiveCard extends StatelessWidget {
  const CurrentPlanActiveCard({super.key, required this.config});

  final HomeUiConfig config;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.addOnsApiPrimaryPlans != current.addOnsApiPrimaryPlans,
      builder: (context, plansState) {
        final isResolving = plansState.status == PlansStatus.initial || plansState.status == PlansStatus.loading;
        final showActiveCard = isResolving || plansState.addOnsApiPrimaryPlans.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: showActiveCard ? (
              config.isPostpaid ?
              const PostpaidCurrentPlan() :
              const PrepaidActivePlanCardWithData(
                showRenewButton: false
              )
          ) :
          const NoActivePlanCard(),
        );
      },
    );
  }
}
