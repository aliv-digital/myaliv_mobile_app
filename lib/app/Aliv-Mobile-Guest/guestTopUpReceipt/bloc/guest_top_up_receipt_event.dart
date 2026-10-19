import 'package:equatable/equatable.dart';
import 'guest_top_up_receipt_state.dart';

sealed class GuestTopUpReceiptEvent extends Equatable {
  const GuestTopUpReceiptEvent();

  @override
  List<Object?> get props => [];
}

final class GuestTopUpReceiptStarted extends GuestTopUpReceiptEvent {
  final GuestTopUpReceiptData data;
  const GuestTopUpReceiptStarted(this.data);

  @override
  List<Object?> get props => [data];
}

final class GuestTopUpReceiptBackToHomePressed extends GuestTopUpReceiptEvent {
  const GuestTopUpReceiptBackToHomePressed();
}
