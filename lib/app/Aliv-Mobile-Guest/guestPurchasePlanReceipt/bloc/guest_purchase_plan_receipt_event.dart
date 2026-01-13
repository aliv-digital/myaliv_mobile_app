import 'package:equatable/equatable.dart';

import 'guest_purchase_plan_receipt_state.dart';




sealed class GuestPurchasePlanReceiptEvent extends Equatable {
  const GuestPurchasePlanReceiptEvent();

  @override
  List<Object?> get props => [];
}

final class GuestPurchasePlanReceiptStarted extends GuestPurchasePlanReceiptEvent {
  final GuestPurchasePlanReceiptData data;
  const GuestPurchasePlanReceiptStarted(this.data);

  @override
  List<Object?> get props => [data];
}

final class GuestPurchasePlanReceiptBackToHomePressed extends GuestPurchasePlanReceiptEvent {
  const GuestPurchasePlanReceiptBackToHomePressed();
}
