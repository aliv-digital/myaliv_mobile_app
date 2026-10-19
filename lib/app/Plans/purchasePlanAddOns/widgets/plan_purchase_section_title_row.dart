import 'package:flutter/material.dart';
import '../theme/plan_purchase_plan_add_ons_theme.dart';

class PlanPurchaseSectionTitleRow extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const PlanPurchaseSectionTitleRow({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: PlanPurchasePlanAddOnsTheme.t(14, weight: FontWeight.w700),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
