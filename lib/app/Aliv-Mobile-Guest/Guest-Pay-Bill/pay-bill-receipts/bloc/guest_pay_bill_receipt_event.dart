import 'package:equatable/equatable.dart';
import 'guest_pay_bill_receipt_state.dart';

sealed class GuestPayBillReceiptEvent extends Equatable {
  const GuestPayBillReceiptEvent();

  @override
  List<Object?> get props => [];
}

final class GuestPayBillReceiptStarted extends GuestPayBillReceiptEvent {
  final GuestPayBillReceiptData data;
  const GuestPayBillReceiptStarted(this.data);

  @override
  List<Object?> get props => [data];
}

final class GuestPayBillReceiptBackToHomePressed extends GuestPayBillReceiptEvent {
  const GuestPayBillReceiptBackToHomePressed();
}
