import 'package:equatable/equatable.dart';

import '../models/invoice_item.dart';


abstract class ReviewInvoicePostpaidEvent extends Equatable {
  const ReviewInvoicePostpaidEvent();

  @override
  List<Object?> get props => [];
}

class ReviewInvoicePostpaidStarted extends ReviewInvoicePostpaidEvent {
  const ReviewInvoicePostpaidStarted();
}

class PostpaidInvoicePressed extends ReviewInvoicePostpaidEvent {
  final InvoiceItem invoice;

  const PostpaidInvoicePressed(this.invoice);

  @override
  List<Object?> get props => [invoice];
}
