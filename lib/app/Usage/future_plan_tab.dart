import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/future_plan_card.dart';

class FuturePlansTab extends StatelessWidget {
  const FuturePlansTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        children: [
          // 🔹 STATIC FIRST PLAN
          const _StaticFuturePlan(),

          const SizedBox(height: 16),

          // 🔹 STATIC BUTTON
          const _StartPlanButton(),

          const SizedBox(height: 16),

          // 🔹 DYNAMIC SECTION
          const _DynamicFuturePlans(),
        ],
      ),
    );
  }
}

class _StaticFuturePlan extends StatelessWidget {
  const _StaticFuturePlan();

  @override
  Widget build(BuildContext context) {
    return const FuturePlanCard(
      title: 'liberty45',
      startDate: '06/01/25',
      endDate: '05/01/25',
      image: 'assets/images/Future Plan 1.png',
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
        child: Text(
          'start plan',
          style: TextStyle(
            color: const Color(0xFFF1F1F8),
            fontSize: 13,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        )
      ),
    );
  }
}

class _DynamicFuturePlans extends StatelessWidget {
  const _DynamicFuturePlans();

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
        'title': 'travel50.',
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
              ),
            ),
          )
          .toList(),
    );
  }
}
