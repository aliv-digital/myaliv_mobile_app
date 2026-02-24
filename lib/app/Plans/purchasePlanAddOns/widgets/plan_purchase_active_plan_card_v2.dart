import 'package:flutter/material.dart';
import '../model/plan_purchase_add_on_models.dart';
import '../theme/plan_purchase_plan_add_ons_theme.dart';
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
      maxWidth: _cardWidth,
      height: _cardHeight,
      borderRadius: _cardRadius,
      topRight: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AutoRenewPill(value: plan.autoRenew, onChanged: onAutoRenewChanged),
          const SizedBox(width: 8),
          Text(
            'auto renew',
            style: PlanPurchasePlanAddOnsTheme.t(
              12,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoRenewPill extends StatelessWidget {
  const _AutoRenewPill({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, right: 6),
                child: Text(
                  value ? 'on' : 'off',
                  style: const TextStyle(
                    fontFamily: PlanPurchasePlanAddOnsTheme.font,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: PlanPurchasePlanAddOnsTheme.textBlack,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: value
                      ? PlanPurchasePlanAddOnsTheme.planRedDark
                      : PlanPurchasePlanAddOnsTheme.toggleOffCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value ? Icons.check : Icons.close,
                  size: 12,
                  color: value
                      ? Colors.white
                      : PlanPurchasePlanAddOnsTheme.planRedDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
