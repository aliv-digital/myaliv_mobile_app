import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';

import '../bloc/purchase_add_ons_state.dart';

/// Bottom pay bar copied from PlanScreen's add-ons tab behavior.
///
/// It appears only after API data is ready and totals selected add-ons with VAT,
/// matching `HomePlanAddOnsBottomPayBar`.
class PurchaseAddOnsBottomPayBar extends StatelessWidget {
  const PurchaseAddOnsBottomPayBar({
    super.key,
    required this.state,
    required this.onPayNow,
  });

  final PurchaseAddOnsState state;
  final VoidCallback onPayNow;

  @override
  Widget build(BuildContext context) {
    if (state.status != PurchaseAddOnsStatus.ready) {
      return const SizedBox.shrink();
    }

    return DefaultBottomPayBar(
      isVatExclusive: false,
      buttonText: 'proceed',
      amountText: '\$ ${state.selectedAddOnsTotal.toStringAsFixed(2)}',
      onPayNow: onPayNow,
    );
  }
}
