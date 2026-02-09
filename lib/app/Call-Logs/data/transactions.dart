enum TransactionType {
  sendMoney,
  planPurchase,
  billPayment,
  topUp,
  redeemCode,
}

class TransactionItem {
  final TransactionType type;
  final String title;
  final String? subtitle;
  final DateTime date;
  final double amount;

  const TransactionItem({
    required this.type,
    required this.title,
    this.subtitle,
    required this.date,
    required this.amount,
  });

  bool get isCredit => amount > 0;
}
