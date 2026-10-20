import 'package:flutter/material.dart';
import '../model/add_on_models.dart';
import '../theme/guest_purchase_plan_add_ons_theme.dart';

/// FairUsePolicyCard
/// - Screenshot মতো: শুধু text block, কোন card shadow না
/// - Top-right "fair use policy" underlined + clickable
class FairUsePolicyCard extends StatelessWidget {
  final FairUsePolicy policy;
  final VoidCallback onTap;

  const FairUsePolicyCard({
    super.key,
    required this.policy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Only the top-right title acts as the tappable link — matches
    // prepaid PlanPurchaseFairUsePolicyCard
    // (plan_purchase_fair_use_policy_card.dart:19-45). Having the whole
    // card tappable (previous behaviour) picked up stray taps on the
    // description text, which prepaid never did.
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 4, 0, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onTap,
                child: Text(
                  policy.title,
                  style: GuestPurchasePlanAddOnsTheme.fairUsePolicyLink,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              policy.description,
              style: GuestPurchasePlanAddOnsTheme.fairUsePolicyDescription,
            ),
          ],
        ),
      ),
    );
  }
}
