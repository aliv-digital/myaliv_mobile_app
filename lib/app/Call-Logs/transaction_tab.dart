import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/transaction_tile.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

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

    return Scaffold(
      backgroundColor: Color(0xFFF1F2FA),
      bottomNavigationBar: SafeArea(
        child: GestureDetector(
          onTap: (){
            context.go(AppRoutes.home);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 68.0,vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Container(
                 width: 200, // ✅ fixed width
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'back to home page',
                  style: TextStyle(
                    color: Color(0xFF645D9C),
                    fontSize: 15,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: transactions
            .map((item) => TransactionTile(item: item))
            .toList(),
      ),
    );
  }
}
