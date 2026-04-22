import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';

sealed class PurchaseAddOnsEvent extends Equatable {
  const PurchaseAddOnsEvent();

  @override
  List<Object?> get props => [];
}

final class PurchaseAddOnsStarted extends PurchaseAddOnsEvent {
  final PlansState plansState;

  const PurchaseAddOnsStarted({required this.plansState});

  @override
  List<Object?> get props => [plansState];
}

final class PurchaseAddOnsAutoRenewToggled extends PurchaseAddOnsEvent {
  final bool value;
  const PurchaseAddOnsAutoRenewToggled(this.value);

  @override
  List<Object?> get props => [value];
}

final class PurchaseAddOnsSelectionToggled extends PurchaseAddOnsEvent {
  final String addOnId;
  final bool selected;
  const PurchaseAddOnsSelectionToggled({
    required this.addOnId,
    required this.selected,
  });

  @override
  List<Object?> get props => [addOnId, selected];
}

final class PurchaseAddOnsSkipPressed extends PurchaseAddOnsEvent {
  const PurchaseAddOnsSkipPressed();
}

final class PurchaseAddOnsProceedPressed extends PurchaseAddOnsEvent {
  const PurchaseAddOnsProceedPressed();
}
