import 'package:flutter/material.dart';
import '../models/home_roaming_confirmation_models.dart';
import '../theme/home_roaming_confirmation_theme.dart';
import 'home_roaming_confirmation_dashed_divider.dart';
import 'home_roaming_confirmation_scallop_clip.dart';

class HomeRoamingConfirmationTotalTicketCard extends StatelessWidget {
  final HomeRoamingConfirmationPurchaseTotals totals;

  const HomeRoamingConfirmationTotalTicketCard({
    super.key,
    required this.totals,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HomeRoamingConfirmationScallopBottomClipper(radius: 10),
      child: Container(
        color: HomeRoamingConfirmationTheme.purple,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          children: [
            _row('sub total', totals.subTotal),
            const SizedBox(height: 10),
            _row('vat', totals.vat),
            const SizedBox(height: 14),
            HomeRoamingConfirmationDashedDivider(
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
          style: HomeRoamingConfirmationTheme.t(
            13,
            weight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Text(
          '\$ ${value.toStringAsFixed(2)}',
          style: HomeRoamingConfirmationTheme.t(
            13,
            weight: isTotal ? FontWeight.w900 : FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
