import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import '../theme/theme.dart';

class HomePlanWalletPaymentActivateOrFutureBottomSheet extends StatelessWidget {
  const HomePlanWalletPaymentActivateOrFutureBottomSheet({
    super.key,
    required this.warningText,
    required this.planName,
    required this.planDurationText,
    required this.planPriceText,
    required this.onBackPressed,
    required this.onActivateNowPressed,
    required this.onFuturePlanPressed,
  });

  final String warningText;
  final String planName;
  final String planDurationText;
  final String planPriceText;
  final VoidCallback onBackPressed;
  final VoidCallback onActivateNowPressed;
  final VoidCallback onFuturePlanPressed;

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
              // Dual CTAs: activate now + future plan.
              Row(
                children: [
                  Expanded(
                    child: DefaultButton(
                      label: HomePlanTheme.bottomSheetActivateNowLabel,
                      isLoading: false,
                      onPressed: onActivateNowPressed,
                      height:
                          HomePlanTheme.bottomSheetActionButtonHeight,
                      backgroundColor: HomePlanTheme.activateNowButton,
                      textStyle: HomePlanTheme
                          .bottomSheetPrimaryActionDualStyle,
                      borderRadius: BorderRadius.circular(
                        HomePlanTheme
                            .bottomSheetActionButtonCornerRadius,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width:
                        HomePlanTheme.bottomSheetDualActionButtonsGap,
                  ),
                  Expanded(
                    child: DefaultButton(
                      label: HomePlanTheme.bottomSheetFuturePlanLabel,
                      isLoading: false,
                      onPressed: onFuturePlanPressed,
                      height:
                          HomePlanTheme.bottomSheetActionButtonHeight,
                      backgroundColor: HomePlanTheme
                          .bottomSheetSecondaryButtonBackgroundColor,
                      textStyle: HomePlanTheme
                          .bottomSheetSecondaryActionDualStyle,
                      borderSide: BorderSide(
                        color: HomePlanTheme.planPriceBorder,
                        width: HomePlanTheme
                            .bottomSheetSecondaryButtonBorderWidth,
                      ),
                      borderRadius: BorderRadius.circular(
                        HomePlanTheme
                            .bottomSheetActionButtonCornerRadius,
                      ),
                    ),
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
