

import '../models/invoice_item.dart';

abstract class ReviewInvoicePostpaidRepository {
  Future<List<InvoiceItem>> fetchInvoices();
}

class ReviewInvoicePostpaidRepositoryImpl implements ReviewInvoicePostpaidRepository {
  @override
  Future<List<InvoiceItem>> fetchInvoices() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final date = DateTime(2024, 9, 2);

    return [
      InvoiceItem(invoiceNo: 'inv.2301', invoiceDate: date, dueDate: date, amount: 105.00),
      InvoiceItem(invoiceNo: 'inv.7441', invoiceDate: date, dueDate: date, amount: 110.16),
      InvoiceItem(invoiceNo: 'inv.9003', invoiceDate: date, dueDate: date, amount: 113.07),
      InvoiceItem(invoiceNo: 'inv.8612', invoiceDate: date, dueDate: date, amount: 109.99),
      InvoiceItem(invoiceNo: 'inv.1535', invoiceDate: date, dueDate: date, amount: 105.00),
      InvoiceItem(invoiceNo: 'inv.7400', invoiceDate: date, dueDate: date, amount: 110.32),
      InvoiceItem(invoiceNo: 'Inv.3518', invoiceDate: date, dueDate: date, amount: 187.20),
    ];
  }
}
