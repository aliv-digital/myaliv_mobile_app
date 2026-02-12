import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/confirmGuestTopUp/theme/theme.dart';

class TopUpSummaryCard extends StatelessWidget {
  const TopUpSummaryCard({
    super.key,
    required this.phoneNumber,
    required this.amountText,
    this.title = 'top-up',
    this.actionLabel = 'top up',
  });

  final String title;
  final String phoneNumber;
  final String actionLabel;
  final String amountText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: TopUpConfirmTheme.summaryCardMinHeight,
      ),
      decoration: BoxDecoration(
        color: TopUpConfirmTheme.cardBackgroundColor,
        borderRadius:
            BorderRadius.circular(TopUpConfirmTheme.summaryCardRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: TopUpConfirmTheme.cardShadowColor,
            blurRadius: TopUpConfirmTheme.summaryCardShadowBlur,
            offset: Offset(0, TopUpConfirmTheme.summaryCardShadowOffsetY),
          ),
        ],
      ),

      // Keep outer container unpadded so divider spans full width.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section content.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TopUpConfirmTheme.summaryHorizontalInset,
              TopUpConfirmTheme.summaryTopSectionVerticalPadding,
              TopUpConfirmTheme.summaryHorizontalInset,
              TopUpConfirmTheme.summaryTopSectionVerticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TopUpConfirmTheme.summaryTitle,
                ),
                const SizedBox(
                    height: TopUpConfirmTheme.summaryTitleToPhoneGap),
                Text(
                  phoneNumber,
                  style: TopUpConfirmTheme.summaryPhone,
                ),
              ],
            ),
          ),

          // Full-width divider.
          const _ThinLine(),

          // Bottom section content.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TopUpConfirmTheme.summaryHorizontalInset,
              TopUpConfirmTheme.summaryBottomSectionVerticalPadding,
              TopUpConfirmTheme.summaryHorizontalInset,
              TopUpConfirmTheme.summaryBottomSectionVerticalPadding,
            ),
            child: Row(
              children: [
                Text(
                  actionLabel,
                  style: TopUpConfirmTheme.summaryAction,
                ),
                const Spacer(),
                _AmountPill(text: amountText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinLine extends StatelessWidget {
  const _ThinLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: TopUpConfirmTheme.summaryDividerHeight,
      width: double.infinity,
      color: TopUpConfirmTheme.summaryDividerColor,
    );
  }
}

class _AmountPill extends StatelessWidget {
  const _AmountPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TopUpConfirmTheme.summaryAmountPillHorizontalPadding,
        vertical: TopUpConfirmTheme.summaryAmountPillVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: TopUpConfirmTheme.summaryAmountPillBackgroundColor,
        borderRadius:
            BorderRadius.circular(TopUpConfirmTheme.summaryAmountPillRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TopUpConfirmTheme.summaryAmountPill,
          ),
        ],
      ),
    );
  }
}
