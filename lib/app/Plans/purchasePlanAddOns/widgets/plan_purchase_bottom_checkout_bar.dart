import 'package:flutter/material.dart';
import '../theme/plan_purchase_plan_add_ons_theme.dart';

class PlanPurchaseBottomPayBar extends StatelessWidget {
  const PlanPurchaseBottomPayBar({
    super.key,
    required this.amountText,
    required this.onPayNow,
    this.isLoading = false,
    this.buttonText = 'pay now',
    this.backgroundColor = PlanPurchasePlanAddOnsTheme.cardWhite,
    this.buttonColor = PlanPurchasePlanAddOnsTheme.bottomBarButton,
  });

  final String amountText;
  final VoidCallback onPayNow;

  final bool isLoading;
  final String buttonText;

  final Color backgroundColor;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      elevation: 10,
      shadowColor: PlanPurchasePlanAddOnsTheme.bottomBarShadow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left amount column
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      amountText,
                      style: PlanPurchasePlanAddOnsTheme.bottomBarAmountText,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'vat exclusive',
                      style: PlanPurchasePlanAddOnsTheme.bottomBarVatText,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Right pill button
              SizedBox(
                height: 40,
                width: 169, // screenshot এর মতো বড় pill look
                child: ElevatedButton(
                  onPressed: isLoading ? null : onPayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    disabledBackgroundColor: buttonColor.withValues(alpha: 0.7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          buttonText,
                          style:
                              PlanPurchasePlanAddOnsTheme.bottomBarButtonText,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
