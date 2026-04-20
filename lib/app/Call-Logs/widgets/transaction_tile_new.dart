import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/models/transaction_model.dart';

/// Reusable tile widget for displaying a transaction entry
class TransactionTileNew extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTileNew({super.key, required this.transaction});

  static const Color _credit = Color(0xFF27AE60);
  static const Color _debit = Color(0xFFE94408);
  static const Color _iconBg = Color(0xFFF2F1FB);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            _buildContent(),
            _buildAmountAndDate(),
            const SizedBox(width: 8),
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.displayTitle,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (transaction.displaySubtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              transaction.displaySubtitle!,
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7A7A7A),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountAndDate() {
    final amountColor = transaction.isCredit ? _credit : _debit;
    final sign = transaction.isCredit ? '+' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$sign\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: amountColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('dd MMM yyyy').format(transaction.date),
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF707070),
          ),
        ),
      ],
    );
  }
}
