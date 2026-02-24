import 'package:flutter/material.dart';
import '../theme/theme.dart';

class HomePlanWalletPaymentActivateBottomSheet extends StatelessWidget {
  const HomePlanWalletPaymentActivateBottomSheet({
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
        color: HomePlanTheme.bottomSheetBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
              HomePlanTheme.bottomSheetTopCornerRadius),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: HomePlanTheme.bottomSheetContentPadding,
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
                    HomePlanTheme.bottomSheetBackTapRadius,
                  ),
                  child: SizedBox(
                    width: HomePlanTheme.bottomSheetBackIconSize,
                    height: HomePlanTheme.bottomSheetBackIconSize,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: HomePlanTheme.bottomSheetBackIconSize,
                      color: HomePlanTheme.bottomSheetBackIconColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                  height: HomePlanTheme.bottomSheetSectionGap),
              // Warning box.
              Container(
                padding: HomePlanTheme.bottomSheetWarningPadding,
                decoration: BoxDecoration(
                  color: HomePlanTheme.warningBackground,
                  borderRadius: BorderRadius.circular(
                    HomePlanTheme.bottomSheetWarningRadius,
                  ),
                  border: Border.all(
                    color: HomePlanTheme.warningBorder,
                    width: HomePlanTheme.bottomSheetWarningBorderWidth,
                  ),
                ),
                child: Text(
                  warningText,
                  style: HomePlanTheme.bottomSheetWarning,
                ),
              ),
              const SizedBox(
                  height: HomePlanTheme.bottomSheetSectionGap),
              // Selected plan summary card.
              _SelectedPlanSummaryCard(
                planName: planName,
                planDurationText: planDurationText,
                planPriceText: planPriceText,
              ),
              const SizedBox(
                  height: HomePlanTheme.bottomSheetSectionGap),
              // Primary CTA: activate now.
              SizedBox(
                height: HomePlanTheme.bottomSheetActionButtonHeight,
                child: ElevatedButton(
                  onPressed: onActivateNowPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomePlanTheme.activateNowButton,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        HomePlanTheme
                            .bottomSheetActionButtonCornerRadius,
                      ),
                    ),
                  ),
                  child: Text(
                    HomePlanTheme.bottomSheetActivateNowLabel,
                    style: HomePlanTheme
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
      height: HomePlanTheme.bottomSheetSummaryCardHeight,
      padding: HomePlanTheme.bottomSheetSummaryCardInnerPadding,
      decoration: BoxDecoration(
        color: HomePlanTheme.planSummaryBackground,
        borderRadius: BorderRadius.circular(
          HomePlanTheme.bottomSheetSummaryCardRadius,
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
                  style: HomePlanTheme.bottomSheetPlanName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: HomePlanTheme
                      .bottomSheetSummaryNameToDurationGap,
                ),
                Text(
                  planDurationText,
                  style: HomePlanTheme.bottomSheetPlanDuration,
                ),
              ],
            ),
          ),
          Container(
            height: HomePlanTheme.bottomSheetSummaryPricePillHeight,
            padding: HomePlanTheme.bottomSheetSummaryPricePillPadding,
            decoration: BoxDecoration(
              color:
                  HomePlanTheme.bottomSheetSummaryPricePillBackground,
              borderRadius: BorderRadius.circular(
                HomePlanTheme.bottomSheetSummaryPricePillRadius,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              planPriceText,
              style: HomePlanTheme.bottomSheetSummaryPriceTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
