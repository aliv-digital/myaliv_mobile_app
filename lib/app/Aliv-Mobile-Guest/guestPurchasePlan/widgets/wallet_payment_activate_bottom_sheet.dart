import 'package:flutter/material.dart';
import '../theme/theme.dart';

class WalletPaymentActivateBottomSheet extends StatelessWidget {
  const WalletPaymentActivateBottomSheet({
    super.key,
    required this.warningText,
    required this.planName,
    required this.planDurationText,
    required this.planPriceText,
    required this.onBackPressed,
    required this.onActivateNowPressed,
  });

  final String warningText;
  final String planName;
  final String planDurationText;
  final String planPriceText;
  final VoidCallback onBackPressed;
  final VoidCallback onActivateNowPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GuestPurchasePlanTheme.bottomSheetBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
              GuestPurchasePlanTheme.bottomSheetTopCornerRadius),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: GuestPurchasePlanTheme.bottomSheetContentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header back action.
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: onBackPressed,
                  borderRadius: BorderRadius.circular(
                    GuestPurchasePlanTheme.bottomSheetBackTapRadius,
                  ),
                  child: SizedBox(
                    width: GuestPurchasePlanTheme.bottomSheetBackIconSize,
                    height: GuestPurchasePlanTheme.bottomSheetBackIconSize,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: GuestPurchasePlanTheme.bottomSheetBackIconSize,
                      color: GuestPurchasePlanTheme.bottomSheetBackIconColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                  height: GuestPurchasePlanTheme.bottomSheetSectionGap),
              // Warning box.
              Container(
                padding: GuestPurchasePlanTheme.bottomSheetWarningPadding,
                decoration: BoxDecoration(
                  color: GuestPurchasePlanTheme.warningBackground,
                  borderRadius: BorderRadius.circular(
                    GuestPurchasePlanTheme.bottomSheetWarningRadius,
                  ),
                  border: Border.all(
                    color: GuestPurchasePlanTheme.warningBorder,
                    width: GuestPurchasePlanTheme.bottomSheetWarningBorderWidth,
                  ),
                ),
                child: Text(
                  warningText,
                  style: GuestPurchasePlanTheme.bottomSheetWarning,
                ),
              ),
              const SizedBox(
                  height: GuestPurchasePlanTheme.bottomSheetSectionGap),
              // Selected plan summary card.
              _SelectedPlanSummaryCard(
                planName: planName,
                planDurationText: planDurationText,
                planPriceText: planPriceText,
              ),
              const SizedBox(
                  height: GuestPurchasePlanTheme.bottomSheetSectionGap),
              // Primary CTA: activate now.
              SizedBox(
                height: GuestPurchasePlanTheme.bottomSheetActionButtonHeight,
                child: ElevatedButton(
                  onPressed: onActivateNowPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GuestPurchasePlanTheme.activateNowButton,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        GuestPurchasePlanTheme
                            .bottomSheetActionButtonCornerRadius,
                      ),
                    ),
                  ),
                  child: Text(
                    GuestPurchasePlanTheme.bottomSheetActivateNowLabel,
                    style: GuestPurchasePlanTheme
                        .bottomSheetPrimaryActionSingleStyle,
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

class _SelectedPlanSummaryCard extends StatelessWidget {
  const _SelectedPlanSummaryCard({
    required this.planName,
    required this.planDurationText,
    required this.planPriceText,
  });

  final String planName;
  final String planDurationText;
  final String planPriceText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: GuestPurchasePlanTheme.bottomSheetSummaryCardHeight,
      padding: GuestPurchasePlanTheme.bottomSheetSummaryCardInnerPadding,
      decoration: BoxDecoration(
        color: GuestPurchasePlanTheme.planSummaryBackground,
        borderRadius: BorderRadius.circular(
          GuestPurchasePlanTheme.bottomSheetSummaryCardRadius,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planName,
                  style: GuestPurchasePlanTheme.bottomSheetPlanName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: GuestPurchasePlanTheme
                      .bottomSheetSummaryNameToDurationGap,
                ),
                Text(
                  planDurationText,
                  style: GuestPurchasePlanTheme.bottomSheetPlanDuration,
                ),
              ],
            ),
          ),
          Container(
            height: GuestPurchasePlanTheme.bottomSheetSummaryPricePillHeight,
            padding: GuestPurchasePlanTheme.bottomSheetSummaryPricePillPadding,
            decoration: BoxDecoration(
              color:
                  GuestPurchasePlanTheme.bottomSheetSummaryPricePillBackground,
              borderRadius: BorderRadius.circular(
                GuestPurchasePlanTheme.bottomSheetSummaryPricePillRadius,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              planPriceText,
              style: GuestPurchasePlanTheme.bottomSheetSummaryPriceTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
