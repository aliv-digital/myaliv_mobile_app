import 'package:equatable/equatable.dart';
import '../models/roaming_plan_confirmation_models.dart';

sealed class RoamingPlanConfirmationEvent extends Equatable {
  const RoamingPlanConfirmationEvent();
  @override
  List<Object?> get props => [];
}

final class RoamingPlanConfirmationStarted
    extends RoamingPlanConfirmationEvent {
  final RoamingPlanConfirmationRouteArgs args;
  const RoamingPlanConfirmationStarted(this.args);

  @override
  List<Object?> get props => [args];
}

final class RoamingPlanConfirmationRemoveItemPressed
    extends RoamingPlanConfirmationEvent {
  final String itemId;
  const RoamingPlanConfirmationRemoveItemPressed(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

final class RoamingPlanConfirmationBeginDateChanged
    extends RoamingPlanConfirmationEvent {
  final DateTime beginDate;
  const RoamingPlanConfirmationBeginDateChanged(this.beginDate);

  @override
  List<Object?> get props => [beginDate];
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
