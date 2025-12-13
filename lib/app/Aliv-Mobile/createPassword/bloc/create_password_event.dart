import 'package:equatable/equatable.dart';

sealed class CreatePasswordEvent extends Equatable {
  const CreatePasswordEvent();

  @override
  List<Object?> get props => [];
}

final class PasswordChanged extends CreatePasswordEvent {
  const PasswordChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class ConfirmPasswordChanged extends CreatePasswordEvent {
  const ConfirmPasswordChanged(this.value);
  final String value;

  @override
  List<Object?> get props => [value];
}

final class TogglePasswordVisibility extends CreatePasswordEvent {
  const TogglePasswordVisibility();
}

final class ToggleConfirmPasswordVisibility extends CreatePasswordEvent {
  const ToggleConfirmPasswordVisibility();
}

final class SubmitCreatePassword extends CreatePasswordEvent {
  const SubmitCreatePassword();
}
