class InvoiceItem {
  final String invoiceNo; // e.g. inv.2301
  final DateTime invoiceDate;
  final DateTime dueDate;
  final double amount;
  final String currencySymbol; // "$"

  const InvoiceItem({
    required this.invoiceNo,
    required this.invoiceDate,
    required this.dueDate,
    required this.amount,
    this.currencySymbol = r'$',
  });
}
