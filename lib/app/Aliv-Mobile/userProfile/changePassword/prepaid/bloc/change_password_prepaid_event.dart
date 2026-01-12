import 'package:equatable/equatable.dart';

sealed class ChangePasswordPrepaidEvent extends Equatable {
  const ChangePasswordPrepaidEvent();
  @override
  List<Object?> get props => [];
}

class ChangePasswordPrepaidStarted extends ChangePasswordPrepaidEvent {
  const ChangePasswordPrepaidStarted();
}

class ChangePasswordPrepaidNewChanged extends ChangePasswordPrepaidEvent {
  final String value;
  const ChangePasswordPrepaidNewChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class ChangePasswordPrepaidConfirmChanged extends ChangePasswordPrepaidEvent {
  final String value;
  const ChangePasswordPrepaidConfirmChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class ChangePasswordPrepaidToggleNewVisibility extends ChangePasswordPrepaidEvent {
  const ChangePasswordPrepaidToggleNewVisibility();
}

class ChangePasswordPrepaidToggleConfirmVisibility extends ChangePasswordPrepaidEvent {
  const ChangePasswordPrepaidToggleConfirmVisibility();
}

class ChangePasswordPrepaidSubmitPressed extends ChangePasswordPrepaidEvent {
  const ChangePasswordPrepaidSubmitPressed();
}
