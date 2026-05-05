// __PARKED_PURCHASE_ADD_ONS__
// Parked: superseded by PlanScreen widgets reused via PurchaseAddOnsScreen.
// Kept (commented-out) for reversibility; safe to delete after QA.
/*
import 'package:flutter/material.dart';

import '../model/purchase_add_ons_models.dart';
import '../theme/purchase_add_ons_theme.dart';

/// Fair-use policy block matching the PlanScreen add-ons tab.
class PurchaseAddOnsFairUsePolicyCard extends StatelessWidget {
  final PurchaseAddOnsFairUsePolicy policy;
  final VoidCallback onTap;

  const PurchaseAddOnsFairUsePolicyCard({
    super.key,
    required this.policy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  style: PurchaseAddOnsTheme.fairUsePolicyLink,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              policy.description,
              style: PurchaseAddOnsTheme.fairUsePolicyDescription,
            ),
          ],
        ),
      ),
    );
  }
}

*/
