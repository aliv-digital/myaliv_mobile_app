import 'package:flutter/material.dart';
import '../model/plan_purchase_add_on_models.dart';
import '../theme/plan_purchase_plan_add_ons_theme.dart';

/// PlanPurchaseFairUsePolicyCard
/// - Screenshot মতো: শুধু text block, কোন card shadow না
/// - Top-right "fair use policy" underlined + clickable
class PlanPurchaseFairUsePolicyCard extends StatelessWidget {
  final PlanPurchaseFairUsePolicy policy;
  final VoidCallback onTap;

  const PlanPurchaseFairUsePolicyCard({
    super.key,
    required this.policy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(5, 4, 0, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  policy.title,
                  style: PlanPurchasePlanAddOnsTheme.fairUsePolicyLink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                policy.description,
                style: PlanPurchasePlanAddOnsTheme.fairUsePolicyDescription,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
