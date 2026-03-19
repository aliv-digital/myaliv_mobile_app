import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/postpaid_roaming_screen.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import '../../../Home/home/data/home_ui_config.dart';
import 'home_plan_screen.dart';

class PlansEntryScreen extends StatelessWidget {
  const PlansEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;

    switch (config.userType) {
      case UserType.postpaid:
        return const PostpaidRoamingAddOnsScreen();

      case UserType.prepaid:
        return const HomePlanScreen();
    }
  }
}
