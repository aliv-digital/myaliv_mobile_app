import 'package:equatable/equatable.dart';

sealed class GuestPurchasePlanConfirmationEvent extends Equatable {
  const GuestPurchasePlanConfirmationEvent();
  @override
  List<Object?> get props => [];
}

final class GuestPurchasePlanConfirmationStarted
    extends GuestPurchasePlanConfirmationEvent {
  final String phoneNumber;
  const GuestPurchasePlanConfirmationStarted(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

final class GuestPurchasePlanConfirmationRemoveItemPressed
    extends GuestPurchasePlanConfirmationEvent {
  final String itemId;
  const GuestPurchasePlanConfirmationRemoveItemPressed(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

final class GuestPurchasePlanConfirmationTermsPressed
    extends GuestPurchasePlanConfirmationEvent {
  const GuestPurchasePlanConfirmationTermsPressed();
}

final class GuestPurchasePlanConfirmationPayNowPressed
    extends GuestPurchasePlanConfirmationEvent {
  const GuestPurchasePlanConfirmationPayNowPressed();
}
