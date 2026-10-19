import 'package:equatable/equatable.dart';

import 'home_plan_purchase_receipt_state.dart';

sealed class HomePlanPurchaseReceiptEvent extends Equatable {
  const HomePlanPurchaseReceiptEvent();

  @override
  List<Object?> get props => [];
}

final class HomePlanPurchaseReceiptStarted
    extends HomePlanPurchaseReceiptEvent {
  final HomePlanPurchaseReceiptData data;
  const HomePlanPurchaseReceiptStarted(this.data);

  @override
  List<Object?> get props => [data];
}

final class HomePlanPurchaseReceiptBackToHomePressed
    extends HomePlanPurchaseReceiptEvent {
  const HomePlanPurchaseReceiptBackToHomePressed();
}
