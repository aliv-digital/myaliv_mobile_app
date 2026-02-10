import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'data/transactions.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem item;

  const TransactionTile({super.key, required this.item});

  static const Color purple = Color(0xFF645D9C);
  static const Color credit = Color(0xFF27AE60);
  static const Color debit = Color(0xFFE94408);
  static const Color iconBg = Color(0xFFF2F1FB);

  @override
  Widget build(BuildContext context) {
    final amountColor = item.isCredit ? credit : debit;

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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle!,
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
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(item.date),
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF707070),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),

          ],
        ),
      ),
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  final TransactionType type;

  const _TransactionIcon({required this.type});

  Widget get icon {
    switch (type) {
      case TransactionType.sendMoney:
        return SvgPicture.asset('assets/icons/send_money.svg');
      case TransactionType.planPurchase:
        return SvgPicture.asset('assets/icons/plan_purchanse.svg');
      case TransactionType.redeemCode:
        return SvgPicture.asset('assets/icons/redeem_code.svg');
      case TransactionType.billPayment:
        return SvgPicture.asset('assets/icons/bill_payment.svg');
      case TransactionType.topUp:
        return SvgPicture.asset('assets/icons/top_up.svg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: icon,
      ),
    );
  }
}
