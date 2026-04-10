import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/home_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/home_plan_state.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/widgets/plan_purchase_plan_red_image_card.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';

/// Active plan card connected to HomePlanCubit for real-time data.
///
/// This widget uses the same [PlanPurchasePlanRedImageCard] component
/// that's used in the Plans Addons tab, ensuring consistent UI.
class PrepaidActivePlanCardWithData extends StatelessWidget {
  const PrepaidActivePlanCardWithData({super.key});

  String _formatCardDate(DateTime? date) {
    if (date == null) {
      return '--/--/--';
    }
    return DateFormat('dd/MM/yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePlanCubit, HomePlanState>(
      buildWhen: (previous, current) {
        // Rebuild when active plan data changes
        return previous.earliestAddOnsPrimaryPlan !=
                current.earliestAddOnsPrimaryPlan ||
            previous.addOnsApiLastSyncedAt != current.addOnsApiLastSyncedAt;
      },
      builder: (context, state) {
        final activePlan = state.earliestAddOnsPrimaryPlan;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Using the same card component as Plans Addons tab
              PlanPurchasePlanRedImageCard(
                planLabel: 'active plan',
                planName: activePlan?.planName.trim().isNotEmpty == true
                    ? activePlan!.planName
                    : 'no active plan',
                activeLabel: 'active',
                activeDate: _formatCardDate(activePlan?.startDateTime),
                expireLabel: 'expire',
                expireDate: _formatCardDate(activePlan?.endDateTime),
                autoRenew: activePlan?.autoRenew ?? false,
                onAutoRenewChanged: null, // Read-only for now
                height: 150,
              ),
              const SizedBox(height: 14),
              const _RenewPlanButton(),
            ],
          ),
        );
      },
    );
  }
}

/// Renew button for active plan card
class _RenewPlanButton extends StatelessWidget {
  const _RenewPlanButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withValues(alpha: 0.5),
            builder: (_) => const AutoRenewBottomSheet(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4FA),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/card-add.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Color(0xFFEF3A4B),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'renew your plan',
              style: TextStyle(
                color: Color(0xFFEF3A4B),
                fontSize: 15,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
