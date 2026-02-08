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
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),

      // no padding here (so divider can be full width)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // top content (padded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TopUpConfirmTheme.summaryTitle,
                ),
                const SizedBox(height: 6),
                Text(
                  phoneNumber,
                  style: TopUpConfirmTheme.summaryPhone,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          //  FULL WIDTH divider (left edge -> right edge)
          const _ThinLine(),

          const SizedBox(height: 22),

          // bottom content (padded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
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

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ThinLine extends StatelessWidget {
  const _ThinLine();

  static const _divider = Color(0xFFB7B2DA);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: _divider,
    );
  }
}

class _AmountPill extends StatelessWidget {
  const _AmountPill({required this.text});

  final String text;

  static const _pillBorder = Color(0xFF6B63A7);
  static const _pillText = Color(0xFF6B63A7);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: TopUpConfirmTheme.boxColor,//Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: _pillBorder),
      ),
      child: Text(
        text,
        style: TopUpConfirmTheme.summaryAmountPill.copyWith(
            color: _pillText,
            fontSize: 16,
            fontWeight: FontWeight.w400
        ),
      ),
    );
  }
}
