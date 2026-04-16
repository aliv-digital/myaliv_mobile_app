import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/future_plan_card.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';

class FuturePlansTab extends StatelessWidget {
  const FuturePlansTab({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;

    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        children: [
          // For postpaid: show future plans from API (PrimaryPlans[1...n])
          // For prepaid: keep existing static behavior
          if (config.isPostpaid)
            const _PostpaidFuturePlans()
          else ...[
            // Prepaid: Static first plan
            const _PrepaidStaticFuturePlan(),
            const SizedBox(height: 16),
            const _StartPlanButton(),
            const SizedBox(height: 16),
            const _PrepaidDynamicFuturePlans(),
          ],
        ],
      ),
    );
  }
}

/// Future plans for postpaid users - uses PrimaryPlans[1...n] from API
class _PostpaidFuturePlans extends StatelessWidget {
  const _PostpaidFuturePlans();

  static const List<String> _planImages = [
    'assets/images/Future Plan 1.png',
    'assets/images/Future Plan 2.png',
    'assets/images/Future Plan 3.png',
  ];

  String _formatCardDate(DateTime? date) {
    if (date == null) {
      return '--/--/--';
    }
    return DateFormat('dd/MM/yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (previous, current) {
        return previous.addOnsApiPrimaryPlans != current.addOnsApiPrimaryPlans ||
            previous.addOnsApiLastSyncedAt != current.addOnsApiLastSyncedAt;
      },
      builder: (context, state) {
        final allPrimaryPlans = state.addOnsApiPrimaryPlans;

        // Skip first plan (active plan), show rest as future plans
        final futurePlans =
            allPrimaryPlans.length > 1 ? allPrimaryPlans.sublist(1) : <BasePlanModel>[];

        if (futurePlans.isEmpty) {
          return const _EmptyFuturePlansMessage();
        }

        return Column(
          children: futurePlans.asMap().entries.map((entry) {
            final index = entry.key;
            final plan = entry.value;
            final imageIndex = index % _planImages.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FuturePlanCard(
                title: plan.planName,
                startDate: _formatCardDate(plan.startDateTime),
                endDate: _formatCardDate(plan.endDateTime),
                image: _planImages[imageIndex],
                isActivePlan: false,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// Empty state when no future plans are available
class _EmptyFuturePlansMessage extends StatelessWidget {
  const _EmptyFuturePlansMessage();

  @override
  Widget build(BuildContext context) {
    // Calculate available height for centering
    final screenHeight = MediaQuery.of(context).size.height;
    // Approximate height: screen - appBar(~140) - tabBar(~82) - padding(~60)
    final availableHeight = screenHeight - 282;

    return SizedBox(
      height: availableHeight > 200 ? availableHeight : 200,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 48,
              color: Color(0xFF9E9E9E),
            ),
            SizedBox(height: 16),
            Text(
              'no future plans scheduled',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF707070),
                fontSize: 16,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static first plan for prepaid users (existing behavior)
class _PrepaidStaticFuturePlan extends StatelessWidget {
  const _PrepaidStaticFuturePlan();

  @override
  Widget build(BuildContext context) {
    return const FuturePlanCard(
      title: 'liberty45',
      startDate: '06/01/25',
      endDate: '05/02/25',
      image: 'assets/images/Future Plan 1.png',
      isActivePlan: true,
    );
  }
}

class _StartPlanButton extends StatelessWidget {
  const _StartPlanButton();

  static const Color purple = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Start plan logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: const Text(
          'start plan',
          style: TextStyle(
            color: Color(0xFFF1F1F8),
            fontSize: 15,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Dynamic future plans for prepaid users (existing behavior)
class _PrepaidDynamicFuturePlans extends StatelessWidget {
  const _PrepaidDynamicFuturePlans();

  @override
  Widget build(BuildContext context) {
    final plans = [
      {
        'title': 'freedom8',
        'start': '20/02/25',
        'end': '19/03/25',
        'image': 'assets/images/Future Plan 2.png',
      },
      {
        'title': 'travel50',
        'start': '20/01/25',
        'end': '19/02/25',
        'image': 'assets/images/Future Plan 3.png',
      },
    ];

    return Column(
      children: plans
          .map(
            (plan) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FuturePlanCard(
                title: plan['title'] as String,
                startDate: plan['start'] as String,
                endDate: plan['end'] as String,
                image: plan['image'] as String,
                isActivePlan: false,
              ),
            ),
          )
          .toList(),
    );
  }
}
