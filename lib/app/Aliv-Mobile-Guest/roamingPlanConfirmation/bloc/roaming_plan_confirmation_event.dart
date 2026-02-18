import 'package:equatable/equatable.dart';

sealed class RoamingPlanConfirmationEvent extends Equatable {
  const RoamingPlanConfirmationEvent();
  @override
  List<Object?> get props => [];
}

final class RoamingPlanConfirmationStarted
    extends RoamingPlanConfirmationEvent {
  final String phoneNumber;
  const RoamingPlanConfirmationStarted(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

final class RoamingPlanConfirmationRemoveItemPressed
    extends RoamingPlanConfirmationEvent {
  final String itemId;
  const RoamingPlanConfirmationRemoveItemPressed(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

final class RoamingPlanConfirmationTermsPressed
    extends RoamingPlanConfirmationEvent {
  const RoamingPlanConfirmationTermsPressed();
}

final class RoamingPlanConfirmationTermsCheckboxToggled
    extends RoamingPlanConfirmationEvent {
  final bool isChecked;

  const RoamingPlanConfirmationTermsCheckboxToggled(this.isChecked);

  @override
  List<Object?> get props => [isChecked];
}

final class RoamingPlanConfirmationPayNowPressed
    extends RoamingPlanConfirmationEvent {
  const RoamingPlanConfirmationPayNowPressed();
}
