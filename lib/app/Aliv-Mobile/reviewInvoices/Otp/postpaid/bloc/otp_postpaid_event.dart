import 'package:equatable/equatable.dart';

abstract class OTPPostpaidEvent extends Equatable {
  const OTPPostpaidEvent();

  @override
  List<Object?> get props => [];
}

class OTPPostpaidCodeChanged extends OTPPostpaidEvent {
  final String code;
  const OTPPostpaidCodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

class OTPPostpaidSubmitted extends OTPPostpaidEvent {
  const OTPPostpaidSubmitted();
}

class OTPPostpaidResendRequested extends OTPPostpaidEvent {
  const OTPPostpaidResendRequested();
}
