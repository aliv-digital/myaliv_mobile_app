import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/transactions.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem item;

  const TransactionTile({super.key, required this.item});

  static const Color purple = Color(0xFF6C63A6);
  static const Color credit = Color(0xFF27AE60);
  static const Color debit = Color(0xFFE5532D);
  static const Color iconBg = Color(0xFFF2F1FB);

  @override
  Widget build(BuildContext context) {
    final amountColor = item.isCredit ? credit : debit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _TransactionIcon(type: item.type),
            const SizedBox(width: 12),

            /// LEFT TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle!,
                      style: const TextStyle(
                        fontFamily: 'CircularPro',
                        fontSize: 12,
                        color: Color(0xFF7A7A7A),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            /// RIGHT AMOUNT + DATE
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.isCredit ? '+' : '-'}\$${item.amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(item.date),
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 11,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _TransactionIcon extends StatelessWidget {
  final TransactionType type;

  const _TransactionIcon({required this.type});

  IconData get icon {
    switch (type) {
      case TransactionType.sendMoney:
        return Icons.replay;
      case TransactionType.planPurchase:
        return Icons.monetization_on_outlined;
      case TransactionType.redeemCode:
        return Icons.attach_money_rounded;
      case TransactionType.billPayment:
        return Icons.payments_outlined;
      case TransactionType.topUp:
        return Icons.refresh_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 20,
        color: const Color(0xFF6C63A6),
      ),
    );
  }
}
