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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          // Screenshot এর মতো light background feel (page bg এর সাথে blend)
          padding: const EdgeInsets.fromLTRB(5, 4, 4, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  policy.title,
                  style: TextStyle(
                    color: const Color(0xFF222222),
                    fontSize: 12,
                    fontFamily: 'Circular Pro',
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                policy.description,
                style: TextStyle(
                  color: const Color(0xFF222222),
                  fontSize: 12,
                  fontFamily: 'Circular Pro',
                  fontWeight: FontWeight.w700,
                ), //GuestPurchasePlanAddOnsTheme.addOnHelper,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
