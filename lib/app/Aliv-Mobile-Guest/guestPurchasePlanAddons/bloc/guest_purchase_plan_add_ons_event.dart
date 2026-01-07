import 'package:equatable/equatable.dart';

sealed class GuestPurchasePlanAddOnsEvent extends Equatable {
  const GuestPurchasePlanAddOnsEvent();

  @override
  List<Object?> get props => [];
}

final class GuestPurchasePlanAddOnsStarted extends GuestPurchasePlanAddOnsEvent {
  const GuestPurchasePlanAddOnsStarted();
}

final class GuestPurchasePlanAddOnsAutoRenewToggled extends GuestPurchasePlanAddOnsEvent {
  final bool value;
  const GuestPurchasePlanAddOnsAutoRenewToggled(this.value);

  @override
  List<Object?> get props => [value];
}

final class GuestPurchasePlanAddOnsSelectionToggled extends GuestPurchasePlanAddOnsEvent {
  final String addOnId;
  final bool selected;
  const GuestPurchasePlanAddOnsSelectionToggled({
    required this.addOnId,
    required this.selected,
  });

  @override
  List<Object?> get props => [addOnId, selected];
}

final class GuestPurchasePlanAddOnsSkipPressed extends GuestPurchasePlanAddOnsEvent {
  const GuestPurchasePlanAddOnsSkipPressed();
}

final class GuestPurchasePlanAddOnsProceedPressed extends GuestPurchasePlanAddOnsEvent {
  const GuestPurchasePlanAddOnsProceedPressed();
}
