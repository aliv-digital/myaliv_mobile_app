import 'package:equatable/equatable.dart';

abstract class ForgetPasswordOtpEvent extends Equatable {
  const ForgetPasswordOtpEvent();

  @override
  List<Object?> get props => [];
}

class ForgetPasswordOtpCodeChanged extends ForgetPasswordOtpEvent {
  final String code;
  const ForgetPasswordOtpCodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

class ForgetPasswordOtpSubmitted extends ForgetPasswordOtpEvent {
  const ForgetPasswordOtpSubmitted();
}

class ForgetPasswordOtpResendRequested extends ForgetPasswordOtpEvent {
  const ForgetPasswordOtpResendRequested();
}
