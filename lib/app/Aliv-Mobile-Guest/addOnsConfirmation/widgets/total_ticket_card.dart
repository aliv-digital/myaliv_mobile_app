import 'package:flutter/material.dart';
import '../models/add_ons_confirmation_models.dart';
import '../theme/add_ons_confirmation_theme.dart';
import 'dashed_divider.dart';
import 'scallop_clip.dart';

class TotalTicketCard extends StatelessWidget {
  final PurchaseTotals totals;

  const TotalTicketCard({
    super.key,
    required this.totals,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ScallopBottomClipper(radius: 10),
      child: Container(
        color: AddOnsConfirmationTheme.purple,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          children: [
            _row('sub total', totals.subTotal),
            const SizedBox(height: 10),
            _row('vat', totals.vat),
            const SizedBox(height: 14),
            DashedDivider(
              height: 1,
              dashWidth: 6,
              dashGap: 6,
              color: Colors.white.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 14),
            _row('total', totals.total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double value, {bool isTotal = false}) {
    return Row(
      children: [
        Text(
          label,
          style: AddOnsConfirmationTheme.t(
            13,
            weight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Text(
          '\$ ${value.toStringAsFixed(2)}',
          style: AddOnsConfirmationTheme.t(
            13,
            weight: isTotal ? FontWeight.w900 : FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
