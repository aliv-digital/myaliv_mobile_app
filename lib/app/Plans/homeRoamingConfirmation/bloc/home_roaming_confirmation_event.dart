import 'package:equatable/equatable.dart';
import '../models/home_roaming_confirmation_models.dart';

sealed class HomeRoamingConfirmationEvent extends Equatable {
  const HomeRoamingConfirmationEvent();
  @override
  List<Object?> get props => [];
}

final class HomeRoamingConfirmationStarted
    extends HomeRoamingConfirmationEvent {
  final HomeRoamingConfirmationRouteArgs args;
  const HomeRoamingConfirmationStarted(this.args);

  @override
  List<Object?> get props => [args];
}

final class HomeRoamingConfirmationRemoveItemPressed
    extends HomeRoamingConfirmationEvent {
  final String itemId;
  const HomeRoamingConfirmationRemoveItemPressed(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

final class HomeRoamingConfirmationBeginDateChanged
    extends HomeRoamingConfirmationEvent {
  final DateTime beginDate;
  const HomeRoamingConfirmationBeginDateChanged(this.beginDate);

  @override
  List<Object?> get props => [beginDate];
}

final class HomeRoamingConfirmationTermsPressed
    extends HomeRoamingConfirmationEvent {
  const HomeRoamingConfirmationTermsPressed();
}

final class HomeRoamingConfirmationTermsCheckboxToggled
    extends HomeRoamingConfirmationEvent {
  final bool isChecked;

  const HomeRoamingConfirmationTermsCheckboxToggled(this.isChecked);

  @override
  List<Object?> get props => [isChecked];
}

final class HomeRoamingConfirmationPayNowPressed
    extends HomeRoamingConfirmationEvent {
  const HomeRoamingConfirmationPayNowPressed();
}
