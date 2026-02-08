import 'package:flutter/material.dart';
import '../theme/theme.dart';

class WalletPaymentActivateOrFutureBottomSheet extends StatelessWidget {
  const WalletPaymentActivateOrFutureBottomSheet({
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

  static const double _sheetTopBottomPadding = 24;
  static const double _sheetHorizontalPadding = 16;
  static const double _sectionGap = 20;
  static const double _warningInnerPadding = 10;
  static const double _planCardHeight = 76;
  static const double _pricePillHeight = 40;
  static const double _actionButtonHeight = 50;
  static const double _cornerRadius = 24;
  static const double _actionGap = 12;
  static const double _backIconSize = 24;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GuestPurchasePlanTheme.bottomSheetBackground,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(_cornerRadius)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _sheetHorizontalPadding,
            _sheetTopBottomPadding,
            _sheetHorizontalPadding,
            _sheetTopBottomPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: onBackPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox(
                    width: _backIconSize,
                    height: _backIconSize,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: _backIconSize,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _sectionGap),
              Container(
                padding: const EdgeInsets.all(_warningInnerPadding),
                decoration: BoxDecoration(
                  color: GuestPurchasePlanTheme.warningBackground,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: GuestPurchasePlanTheme.warningBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  warningText,
                  style: GuestPurchasePlanTheme.bottomSheetWarning,
                ),
              ),
              const SizedBox(height: _sectionGap),
              _SelectedPlanSummaryCard(
                planName: planName,
                planDurationText: planDurationText,
                planPriceText: planPriceText,
              ),
              const SizedBox(height: _sectionGap),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: _actionButtonHeight,
                      child: ElevatedButton(
                        onPressed: onActivateNowPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              GuestPurchasePlanTheme.activateNowButton,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(_actionButtonHeight / 2),
                          ),
                        ),
                        child: Text(
                          'activate now',
                          style: GuestPurchasePlanTheme.bottomSheetPrimaryAction
                              .copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: _actionGap),
                  Expanded(
                    child: SizedBox(
                      height: _actionButtonHeight,
                      child: OutlinedButton(
                        onPressed: onFuturePlanPressed,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: GuestPurchasePlanTheme.planPriceBorder,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(_actionButtonHeight / 2),
                          ),
                        ),
                        child: Text(
                          'future plan',
                          style: GuestPurchasePlanTheme
                              .bottomSheetSecondaryAction
                              .copyWith(
                            fontSize: 16,
                          ),
                        ),
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
      height: WalletPaymentActivateOrFutureBottomSheet._planCardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: GuestPurchasePlanTheme.planSummaryBackground,
        borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 4),
                Text(
                  planDurationText,
                  style: GuestPurchasePlanTheme.bottomSheetPlanDuration,
                ),
              ],
            ),
          ),
          Container(
            height: WalletPaymentActivateOrFutureBottomSheet._pricePillHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GuestPurchasePlanTheme.planPriceBorder,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              planPriceText,
              style: GuestPurchasePlanTheme.bottomSheetPrice,
            ),
          ),
        ],
      ),
    );
  }
}
