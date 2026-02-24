import 'package:equatable/equatable.dart';

sealed class HomeRoamingConfirmationEvent extends Equatable {
  const HomeRoamingConfirmationEvent();
  @override
  List<Object?> get props => [];
}

final class HomeRoamingConfirmationStarted
    extends HomeRoamingConfirmationEvent {
  final String phoneNumber;
  const HomeRoamingConfirmationStarted(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

final class HomeRoamingConfirmationRemoveItemPressed
    extends HomeRoamingConfirmationEvent {
  final String itemId;
  const HomeRoamingConfirmationRemoveItemPressed(this.itemId);

  @override
  List<Object?> get props => [itemId];
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
