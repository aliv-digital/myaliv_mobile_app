import 'package:equatable/equatable.dart';
import '../models/home_plan_confirmation_models.dart';

sealed class HomePlanConfirmationEvent extends Equatable {
  const HomePlanConfirmationEvent();
  @override
  List<Object?> get props => [];
}

final class HomePlanConfirmationStarted extends HomePlanConfirmationEvent {
  final HomePlanConfirmationRouteArgs args;
  const HomePlanConfirmationStarted(this.args);

  @override
  List<Object?> get props => [args];
}

final class HomePlanConfirmationRemoveItemPressed
    extends HomePlanConfirmationEvent {
  final String itemId;
  const HomePlanConfirmationRemoveItemPressed(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

final class HomePlanConfirmationPromoCodeChanged
    extends HomePlanConfirmationEvent {
  final String value;

  const HomePlanConfirmationPromoCodeChanged(this.value);

  @override
  List<Object?> get props => [value];
}

final class HomePlanConfirmationPromoApplyPressed
    extends HomePlanConfirmationEvent {
  const HomePlanConfirmationPromoApplyPressed();
}

final class HomePlanConfirmationTermsPressed extends HomePlanConfirmationEvent {
  const HomePlanConfirmationTermsPressed();
}

final class HomePlanConfirmationTermsCheckboxToggled
    extends HomePlanConfirmationEvent {
  final bool isChecked;

  const HomePlanConfirmationTermsCheckboxToggled(this.isChecked);

  @override
  List<Object?> get props => [isChecked];
}

final class HomePlanConfirmationPayNowPressed
    extends HomePlanConfirmationEvent {
  const HomePlanConfirmationPayNowPressed();
}
