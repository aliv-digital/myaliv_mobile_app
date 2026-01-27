import 'package:equatable/equatable.dart';

sealed class EnterPasswordPostpaidEvent extends Equatable {
  const EnterPasswordPostpaidEvent();

  @override
  List<Object?> get props => [];
}

class EnterPasswordPostpaidStarted extends EnterPasswordPostpaidEvent {
  const EnterPasswordPostpaidStarted();
}

class EnterPasswordPostpaidBackPressed extends EnterPasswordPostpaidEvent {
  const EnterPasswordPostpaidBackPressed();
}

class EnterPasswordPostpaidPasswordChanged extends EnterPasswordPostpaidEvent {
  final String value;
  const EnterPasswordPostpaidPasswordChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class EnterPasswordPostpaidToggleObscure extends EnterPasswordPostpaidEvent {
  const EnterPasswordPostpaidToggleObscure();
}

class EnterPasswordPostpaidContinuePressed extends EnterPasswordPostpaidEvent {
  const EnterPasswordPostpaidContinuePressed();
}

class EnterPasswordPostpaidFaceIdPressed extends EnterPasswordPostpaidEvent {
  const EnterPasswordPostpaidFaceIdPressed();
}

class EnterPasswordPostpaidFingerprintPressed extends EnterPasswordPostpaidEvent {
  const EnterPasswordPostpaidFingerprintPressed();
}
