import 'package:equatable/equatable.dart';

abstract class OtpProfilePrepaidEvent extends Equatable {
  const OtpProfilePrepaidEvent();

  @override
  List<Object?> get props => [];
}

class OtpProfilePrepaidCodeChanged extends OtpProfilePrepaidEvent {
  final String code;
  const OtpProfilePrepaidCodeChanged(this.code);

  @override
  List<Object?> get props => [code];
}

class OtpProfilePrepaidSubmitted extends OtpProfilePrepaidEvent {
  const OtpProfilePrepaidSubmitted();
}

class OtpProfilePrepaidResendRequested extends OtpProfilePrepaidEvent {
  const OtpProfilePrepaidResendRequested();
}
