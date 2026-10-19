import 'package:equatable/equatable.dart';
import '../models/guest_purchase_plan_confirmation_models.dart';

sealed class GuestPurchasePlanConfirmationEvent extends Equatable {
  const GuestPurchasePlanConfirmationEvent();
  @override
  List<Object?> get props => [];
}

final class GuestPurchasePlanConfirmationStarted
    extends GuestPurchasePlanConfirmationEvent {
  final GuestPurchasePlanConfirmationRouteArgs args;
  const GuestPurchasePlanConfirmationStarted(this.args);

  @override
  List<Object?> get props => [args];
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

final class GuestPurchasePlanConfirmationTermsCheckboxToggled
    extends GuestPurchasePlanConfirmationEvent {
  final bool isChecked;

  const GuestPurchasePlanConfirmationTermsCheckboxToggled(this.isChecked);

  @override
  List<Object?> get props => [isChecked];
}

final class GuestPurchasePlanConfirmationPayNowPressed
    extends GuestPurchasePlanConfirmationEvent {
  const GuestPurchasePlanConfirmationPayNowPressed();
}
