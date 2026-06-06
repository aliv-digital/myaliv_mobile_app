import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/active_add_ons_chips.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/current_plan_active_card.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/postpaid_usage_section.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/prepaid_usage_section.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/purchase_addon_button.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/roaming_plan_section.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_fair_use_link.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

/// Top-level layout for the Usage → current plan tab. Pure
/// composition — each section is its own widget under
/// `lib/app/Usage/widgets/` so this file stays a one-glance overview of
/// the tab's structure.
class CurrentPlanTab extends StatelessWidget {
  const CurrentPlanTab({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;
    final bool isPrepaid = !config.isPostpaid;

    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          // will work on it
          CurrentPlanActiveCard(config: config),
          const UsageFairUseLink(),
          if (config.isPostpaid) const PostpaidUsageSection(),
          if (isPrepaid) ..._prepaidSections,
          const RoamingPlanSection(),
        ],
      ),
    );
  }

  /// Prepaid-only stack: chips → usage list → add-on CTA. Each child
  /// handles its own padding so this list reads as a flat outline of
  /// the tab. Roaming is rendered unconditionally below for both
  /// payment types and self-hides when there are no stand-alone plans.
  static const List<Widget> _prepaidSections = [
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: ActiveAddOnsChips(),
    ),
    SizedBox(height: 16),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: PrepaidUsageSection(),
    ),
    Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: PurchaseAddOnButton(),
    ),
  ];
}
