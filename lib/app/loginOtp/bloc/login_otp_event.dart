import 'package:equatable/equatable.dart';

abstract class LoginOtpEvent extends Equatable {
  const LoginOtpEvent();

  @override
  List<Object?> get props => [];
}

class LoginOtpCodeChanged extends LoginOtpEvent {
  final String code;
  const LoginOtpCodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

class LoginOtpSubmitted extends LoginOtpEvent {
  const LoginOtpSubmitted();
}

class LoginOtpResendRequested extends LoginOtpEvent {
  const LoginOtpResendRequested();
}
