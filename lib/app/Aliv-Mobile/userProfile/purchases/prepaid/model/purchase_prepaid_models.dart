import 'package:equatable/equatable.dart';

enum PurchasePrepaidAction {
  addEditCreditCards,
  topUpPrepaidNumber,
  buyPlans,
  futurePlans,
  myLimits,
  reviewInvoices,
  transactionHistory,
  makePayment,
  topUp,
}

class PurchasePrepaidMenuItem extends Equatable {
  final String title;
  final PurchasePrepaidAction action;

  const PurchasePrepaidMenuItem({
    required this.title,
    required this.action,
  });

  @override
  List<Object?> get props => [title, action];
}
