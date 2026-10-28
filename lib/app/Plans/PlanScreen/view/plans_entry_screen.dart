import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/home_plan_screen.dart';

class PlansEntryScreen extends StatelessWidget {
  final HomePlanTab? initialTab;
  final String? rewardSugName;

  const PlansEntryScreen({super.key, this.initialTab, this.rewardSugName});

  @override
  Widget build(BuildContext context) {
    return HomePlanScreen(initialTab: initialTab, rewardSugName: rewardSugName);
  }
}
