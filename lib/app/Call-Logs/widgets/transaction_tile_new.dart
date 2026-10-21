import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/models/transaction_model.dart';

/// Reusable tile widget for displaying a transaction entry
class TransactionTileNew extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTileNew({super.key, required this.transaction});

  static const Color _credit = Color(0xFF00C4B3);
  static const Color _debit = Color(0xFFE94408);
  static const Color _iconBg = Color(0xFFF2F1FB);
  static const TextStyle _primaryTextStyle = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 18 / 14,
    color: Color(0xFF1C1C1C),
  );
  static const TextStyle _secondaryTextStyle = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.25,
    color: Color(0xFF707070),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(width: 52, height: 52, child: Center(child: _buildIcon())),
            const SizedBox(width: 16),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _iconBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(_getIconPath()),
      ),
    );
  }

  String _getIconPath() {
    final type = transaction.type.toLowerCase();
    if (type.contains('payment')) return 'assets/icons/bill_payment.svg';
    if (type.contains('topup') || type.contains('top-up')) {
      return 'assets/icons/top_up.svg';
    }
    if (type.contains('plan') || type.contains('purchase')) {
      return 'assets/icons/plan_purchanse.svg';
    }
    if (type.contains('send') || type.contains('transfer')) {
      return 'assets/icons/send_money.svg';
    }
    if (type.contains('redeem')) return 'assets/icons/redeem_code.svg';
    return 'assets/icons/bill_payment.svg';
  }

  Widget _buildContent() {
    final amountColor = transaction.isCredit ? _credit : _debit;
    final absAmount = transaction.amount.abs();
    final formattedAmount = NumberFormat('#,##0.00').format(absAmount);
    final displayAmount = transaction.isCredit
        ? '+\$$formattedAmount'
        : '-\$$formattedAmount';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                transaction.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _primaryTextStyle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              displayAmount,
              style: _primaryTextStyle.copyWith(color: amountColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildSecondaryRow(),
      ],
    );
  }

  Widget _buildSecondaryRow() {
    final subtitle = transaction.displaySubtitle;
    final isChannel = subtitle != null && subtitle == transaction.channel;
    final subtitleSpan = TextSpan(
      style: _secondaryTextStyle.copyWith(letterSpacing: -0.3),
      text: isChannel ? 'Channel: ' : subtitle,
      children: [
        if (isChannel)
          TextSpan(
            text: transaction.channel,
            style: const TextStyle(color: Colors.black),
          ),
      ],
    );
    final date = transaction.date.formatDdMmmYyyyHm();
    final dateText = Text(
      date,
      textAlign: TextAlign.end,
      style: _secondaryTextStyle,
    );
    if (subtitle == null) {
      return dateText;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScaler = MediaQuery.textScalerOf(context);
        final direction = Directionality.of(context);
        double measure(InlineSpan text) {
          final painter = TextPainter(
            text: text,
            textDirection: direction,
            textScaler: textScaler,
          )..layout();
          final width = painter.width;
          painter.dispose();
          return width;
        }

        final subtitleText = Text.rich(subtitleSpan);
        final requiredWidth =
            measure(subtitleSpan) +
            8 +
            measure(TextSpan(text: date, style: _secondaryTextStyle));

        // Keep the Figma row intact when it fits; preserve full text on
        // smaller screens and when accessibility text scaling is enabled.
        if (requiredWidth > constraints.maxWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [subtitleText, const SizedBox(height: 4), dateText],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [subtitleText, const SizedBox(width: 8), dateText],
        );
      },
    );
  }
}
