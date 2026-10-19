import 'package:equatable/equatable.dart';

abstract class OtpAutoRenewPrepaidEvent extends Equatable {
  const OtpAutoRenewPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class OtpAutoRenewPrepaidCodeChanged extends OtpAutoRenewPrepaidEvent {
  final String code;
  const OtpAutoRenewPrepaidCodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

class OtpAutoRenewPrepaidSubmitted extends OtpAutoRenewPrepaidEvent {
  const OtpAutoRenewPrepaidSubmitted();
}

class OtpAutoRenewPrepaidResendRequested extends OtpAutoRenewPrepaidEvent {
  const OtpAutoRenewPrepaidResendRequested();
}
