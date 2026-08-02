import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/core/utils/app_session.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class PurchaseAddOnButton extends StatelessWidget {
  const PurchaseAddOnButton({super.key});

  static const Color purple = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (a, b) =>
          a.status != b.status ||
          a.earliestAddOnsPrimaryPlan != b.earliestAddOnsPrimaryPlan,
      builder: (context, state) {
        final resolving = state.status == PlansStatus.initial ||
            state.status == PlansStatus.loading;
        if (resolving || state.earliestAddOnsPrimaryPlan == null) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                AppSession.appRoute = 'addOnsPrepaid';
                context.push(AppRoutes.purchaseAddOns);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'purchase an add-on',
                style: TextStyle(
                  color: Color(0xFFF1F1F8),
                  fontSize: 15,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
