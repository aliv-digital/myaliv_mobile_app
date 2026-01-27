import 'package:equatable/equatable.dart';
import '../models/invoice_item.dart';

enum ReviewInvoicePostpaidStatus { initial, loading, success, failure }

class ReviewInvoicePostpaidState extends Equatable {
  final ReviewInvoicePostpaidStatus status;
  final List<InvoiceItem> invoices;
  final String? errorMessage;
  final InvoiceItem? lastPressed;

  const ReviewInvoicePostpaidState({
    required this.status,
    required this.invoices,
    this.errorMessage,
    this.lastPressed,
  });

  factory ReviewInvoicePostpaidState.initial() => const ReviewInvoicePostpaidState(
    status: ReviewInvoicePostpaidStatus.initial,
    invoices: [],
  );

  ReviewInvoicePostpaidState copyWith({
    ReviewInvoicePostpaidStatus? status,
    List<InvoiceItem>? invoices,
    String? errorMessage,
    InvoiceItem? lastPressed,
  }) {
    return ReviewInvoicePostpaidState(
      status: status ?? this.status,
      invoices: invoices ?? this.invoices,
      errorMessage: errorMessage,
      lastPressed: lastPressed ?? this.lastPressed,
    );
  }

  @override
  List<Object?> get props => [status, invoices, errorMessage, lastPressed];
}
