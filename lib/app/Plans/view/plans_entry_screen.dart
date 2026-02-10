import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Plans/view/postpaid_roaming_screen.dart';

import '../../Home/home/data/home_ui_config.dart';
import 'home_plan_screen.dart';

class PlansEntryScreen extends StatelessWidget {
  final HomeUiConfig config;

  const PlansEntryScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    switch (config.userType) {
      case UserType.postpaid:
        return const PostpaidRoamingAddOnsScreen();

      case UserType.prepaid:
        return const HomePlanScreen();
    }
  }
}
