import 'package:equatable/equatable.dart';

sealed class EnterPasswordPrepaidEvent extends Equatable {
  const EnterPasswordPrepaidEvent();
  @override
  List<Object?> get props => [];
}

class EnterPasswordPrepaidStarted extends EnterPasswordPrepaidEvent {
  const EnterPasswordPrepaidStarted();
}

class EnterPasswordPrepaidBackPressed extends EnterPasswordPrepaidEvent {
  const EnterPasswordPrepaidBackPressed();
}

class EnterPasswordPrepaidPasswordChanged extends EnterPasswordPrepaidEvent {
  final String value;
  const EnterPasswordPrepaidPasswordChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class EnterPasswordPrepaidToggleObscure extends EnterPasswordPrepaidEvent {
  const EnterPasswordPrepaidToggleObscure();
}

class EnterPasswordPrepaidContinuePressed extends EnterPasswordPrepaidEvent {
  const EnterPasswordPrepaidContinuePressed();
}

class EnterPasswordPrepaidFaceIdPressed extends EnterPasswordPrepaidEvent {
  const EnterPasswordPrepaidFaceIdPressed();
}

class EnterPasswordPrepaidFingerprintPressed extends EnterPasswordPrepaidEvent {
  const EnterPasswordPrepaidFingerprintPressed();
}
