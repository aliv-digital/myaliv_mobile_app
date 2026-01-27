import 'package:flutter/material.dart';

class TransactionsTab extends StatelessWidget {
  const TransactionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Transactions',
        style: TextStyle(
          fontFamily: 'CircularPro',
          color: Colors.grey,
        ),
      ),
    );
  }
}
