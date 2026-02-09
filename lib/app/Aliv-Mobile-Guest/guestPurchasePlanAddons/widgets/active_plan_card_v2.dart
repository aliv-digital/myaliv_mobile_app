import 'package:flutter/material.dart';
import '../model/add_on_models.dart';
import '../theme/guest_purchase_plan_add_ons_theme.dart';

/// ActivePlanCardV2
/// Fresh implementation for pixel-perfect Figma matching.
/// Does not touch or replace the existing ActivePlanCard.
class ActivePlanCardV2 extends StatelessWidget {
  const ActivePlanCardV2({
    super.key,
    required this.plan,
    required this.onAutoRenewChanged,
  });

  final ActivePlanSummary plan;
  final ValueChanged<bool> onAutoRenewChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GuestPurchasePlanAddOnsTheme.planRed,
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage('assets/icons/Home Active Plan.png'),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 10),
            color: GuestPurchasePlanAddOnsTheme.shadow,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    plan.label,
                    style: TextStyle(
                      color: Colors.white /* White-100% */,
                      fontSize: 12,
                      fontFamily: 'Circular Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  _AutoRenewPill(
                    value: plan.autoRenew,
                    onChanged: onAutoRenewChanged,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'auto renew',
                    style: GuestPurchasePlanAddOnsTheme.t(
                      12,
                      weight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 0),
              Text(
                plan.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white /* White-100% */,
                  fontSize: 24,
                  fontFamily: 'Circular Pro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  _DateBlock(
                    label: plan.activeDateLabel,
                    value: plan.activeDate,
                    alignEnd: false,
                  ),
                  const Spacer(),
                  _DateBlock(
                    label: plan.expireDateLabel,
                    value: plan.expireDate,
                    alignEnd: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoRenewPill extends StatelessWidget {
  const _AutoRenewPill({required this.value, required this.onChanged});

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
                    fontFamily: GuestPurchasePlanAddOnsTheme.font,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: GuestPurchasePlanAddOnsTheme.textBlack,
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
                      ? GuestPurchasePlanAddOnsTheme.planRedDark
                      : GuestPurchasePlanAddOnsTheme.toggleOffCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value ? Icons.check : Icons.close,
                  size: 12,
                  color: value
                      ? Colors.white
                      : GuestPurchasePlanAddOnsTheme.planRedDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({
    required this.label,
    required this.value,
    required this.alignEnd,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GuestPurchasePlanAddOnsTheme.t(
            12,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GuestPurchasePlanAddOnsTheme.t(
            15,
            weight: FontWeight.w900,
            color: Colors.white,
            height: 1.0,
          ).copyWith(letterSpacing: 2.25),
        ),
      ],
    );
  }
}
