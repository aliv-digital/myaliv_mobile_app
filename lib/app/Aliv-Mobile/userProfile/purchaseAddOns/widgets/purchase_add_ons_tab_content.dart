// __PARKED_PURCHASE_ADD_ONS__
// Parked: superseded by PlanScreen widgets reused via PurchaseAddOnsScreen.
// Kept (commented-out) for reversibility; safe to delete after QA.
/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/purchase_add_ons_models.dart';
import 'purchase_add_ons_add_on_tile.dart';
import 'purchase_add_ons_fair_use_policy_card.dart';
import 'purchase_add_ons_plan_red_image_card.dart';

/// Purchase add-ons version of `HomePlanAddOnsTabContent`.
///
/// The layout is intentionally the same as the PlanScreen add-ons tab: active
/// primary plan card, fair-use policy text, then one selectable tile per API
/// add-on from `AvailableBoltOns`.
class PurchaseAddOnsTabContent extends StatelessWidget {
  const PurchaseAddOnsTabContent({
    super.key,
    required this.activePrimaryPlan,
    required this.addOns,
    required this.selectedAddOnIds,
    required this.onToggleAddOn,
    required this.onAutoRenewChanged,
  });

  static const double _addOnsTabHorizontalPadding = 25;

  final PurchaseAddOnsPrimaryPlan? activePrimaryPlan;
  final List<PurchaseAddOnsItem> addOns;
  final Set<String> selectedAddOnIds;
  final ValueChanged<PurchaseAddOnsItem> onToggleAddOn;
  final ValueChanged<bool> onAutoRenewChanged;

  PurchaseAddOnsActivePlanSummary _buildActivePlanSummary() {
    return PurchaseAddOnsActivePlanSummary(
      label: 'active plan',
      name: activePrimaryPlan?.name.trim().isNotEmpty == true
          ? activePrimaryPlan!.name
          : '--',
      autoRenew: activePrimaryPlan?.autoRenew ?? false,
      activeDateLabel: 'active',
      activeDate: _formatCardDate(activePrimaryPlan?.startDateTime),
      expireDateLabel: 'expire',
      expireDate: _formatCardDate(activePrimaryPlan?.endDateTime),
    );
  }

  PurchaseAddOnsFairUsePolicy _fairUsePolicy() {
    return const PurchaseAddOnsFairUsePolicy(
      title: 'fair use policy',
      description:
          'add-ons can only be added to your active primary plan and expires when it ends.',
    );
  }

  String _formatCardDate(DateTime? date) {
    if (date == null) {
      return '--/--/--';
    }

    return DateFormat('dd/MM/yy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final activePlan = _buildActivePlanSummary();
    final fairUsePolicy = _fairUsePolicy();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        _addOnsTabHorizontalPadding,
        20,
        _addOnsTabHorizontalPadding,
        16,
      ),
      children: <Widget>[
        PurchaseAddOnsPlanRedImageCard(
          planLabel: activePlan.label,
          planName: activePlan.name,
          activeLabel: activePlan.activeDateLabel,
          activeDate: activePlan.activeDate,
          expireLabel: activePlan.expireDateLabel,
          expireDate: activePlan.expireDate,
          autoRenew: activePlan.autoRenew,
          onAutoRenewChanged: onAutoRenewChanged,
        ),
        const SizedBox(height: 16),
        PurchaseAddOnsFairUsePolicyCard(policy: fairUsePolicy, onTap: () {}),
        const SizedBox(height: 16),
        ...addOns.map((addOn) {
          final selected = selectedAddOnIds.contains(addOn.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PurchaseAddOnsAddOnTile(
              item: addOn,
              selected: selected,
              onChanged: (_) => onToggleAddOn(addOn),
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}

*/
