import 'package:equatable/equatable.dart';

enum PurchasesAction {
  addEditCreditCards,
  topUpPrepaidNumber,
  buyPlans,
  futurePlans,
  myLimits,
  reviewInvoices,
  transactionHistory,
  makePayment,
  topUp,
  autoRenew,
  autoTopUp,
  sendTopUp,
  addOns,
  autoPay,
}

class PurchasesMenuItem extends Equatable {
  final String title;
  final PurchasesAction action;

  const PurchasesMenuItem({required this.title, required this.action});

  @override
  List<Object?> get props => [title, action];
}
