import 'package:equatable/equatable.dart';

sealed class EnterPasswordAutoRenewPrepaidEvent extends Equatable {
  const EnterPasswordAutoRenewPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class EnterPasswordAutoRenewPrepaidStarted
    extends EnterPasswordAutoRenewPrepaidEvent {
  const EnterPasswordAutoRenewPrepaidStarted();
}

class EnterPasswordAutoRenewPrepaidBackPressed
    extends EnterPasswordAutoRenewPrepaidEvent {
  const EnterPasswordAutoRenewPrepaidBackPressed();
}

class EnterPasswordAutoRenewPrepaidPasswordChanged
    extends EnterPasswordAutoRenewPrepaidEvent {
  final String value;
  const EnterPasswordAutoRenewPrepaidPasswordChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class EnterPasswordAutoRenewPrepaidToggleObscure
    extends EnterPasswordAutoRenewPrepaidEvent {
  const EnterPasswordAutoRenewPrepaidToggleObscure();
}

class EnterPasswordAutoRenewPrepaidContinuePressed
    extends EnterPasswordAutoRenewPrepaidEvent {
  const EnterPasswordAutoRenewPrepaidContinuePressed();
}

class EnterPasswordAutoRenewPrepaidFaceIdPressed
    extends EnterPasswordAutoRenewPrepaidEvent {
  const EnterPasswordAutoRenewPrepaidFaceIdPressed();
}

class EnterPasswordAutoRenewPrepaidFingerprintPressed
    extends EnterPasswordAutoRenewPrepaidEvent {
  const EnterPasswordAutoRenewPrepaidFingerprintPressed();
}
