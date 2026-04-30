import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/home_plan_screen.dart';

class PlansEntryScreen extends StatelessWidget {
  final HomePlanTab? initialTab;

  const PlansEntryScreen({super.key, this.initialTab});

  @override
  Widget build(BuildContext context) {
    return HomePlanScreen(initialTab: initialTab);
  }
}
