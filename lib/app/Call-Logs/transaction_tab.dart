import 'package:flutter/cupertino.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/transaction_tile.dart';

import 'data/transactions.dart';

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = <TransactionItem>[
      TransactionItem(
        type: TransactionType.sendMoney,
        title: 'send money',
        subtitle: '242-808-1459',
        date: DateTime(2024, 9, 2),
        amount: -15,
      ),
      TransactionItem(
        type: TransactionType.planPurchase,
        title: 'plan purchase',
        subtitle: 'roameasy USA',
        date: DateTime(2024, 9, 2),
        amount: -25,
      ),
      TransactionItem(
        type: TransactionType.billPayment,
        title: 'bill payment',
        subtitle: 'REV',
        date: DateTime(2024, 8, 23),
        amount: -100,
      ),
      TransactionItem(
        type: TransactionType.topUp,
        title: 'top-up',
        subtitle: 'my number',
        date: DateTime(2024, 8, 23),
        amount: 15,
      ),
      TransactionItem(
        type: TransactionType.redeemCode,
        title: 'redeem code',
        date: DateTime(2024, 9, 2),
        amount: -5,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: transactions
          .map((item) => TransactionTile(item: item))
          .toList(),
    );
  }
}
