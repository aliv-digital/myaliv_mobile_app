import 'package:flutter/material.dart';
import '../model/plan_purchase_add_on_models.dart';
import 'plan_purchase_plan_red_image_card.dart';

/// PlanPurchaseActivePlanCardV2
/// Fresh implementation for pixel-perfect Figma matching.
/// Does not touch or replace the existing PlanPurchaseActivePlanCard.
class PlanPurchaseActivePlanCardV2 extends StatelessWidget {
  const PlanPurchaseActivePlanCardV2({
    super.key,
    required this.plan,
    required this.onAutoRenewChanged,
  });

  final PlanPurchaseActivePlanSummary plan;
  final ValueChanged<bool> onAutoRenewChanged;
  static const double _cardWidth = 340;
  static const double _cardHeight = 150;
  static const double _cardRadius = 12;

  @override
  Widget build(BuildContext context) {
    return PlanPurchasePlanRedImageCard(
      planLabel: plan.label,
      planName: plan.name,
      activeLabel: plan.activeDateLabel,
      activeDate: plan.activeDate,
      expireLabel: plan.expireDateLabel,
      expireDate: plan.expireDate,
      autoRenew: plan.autoRenew,
      onAutoRenewChanged: onAutoRenewChanged,
      maxWidth: _cardWidth,
      height: _cardHeight,
      borderRadius: _cardRadius,
    );
  }
}
