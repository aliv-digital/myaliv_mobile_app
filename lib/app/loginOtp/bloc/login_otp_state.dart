import 'package:equatable/equatable.dart';

enum LoginOtpStatus { initial, loading, success, failure }
enum LoginOtpResendStatus { idle, loading, done }

class LoginOtpState extends Equatable {
  final String code;
  final LoginOtpStatus status;
  final LoginOtpResendStatus resendStatus;
  final String? errorMessage;

  const LoginOtpState({
    this.code = '',
    this.status = LoginOtpStatus.initial,
    this.resendStatus = LoginOtpResendStatus.idle,
    this.errorMessage,
  });

  LoginOtpState copyWith({
    String? code,
    LoginOtpStatus? status,
    LoginOtpResendStatus? resendStatus,
    String? errorMessage,
  }) {
    return LoginOtpState(
      code: code ?? this.code,
      status: status ?? this.status,
      resendStatus: resendStatus ?? this.resendStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [code, status, resendStatus, errorMessage];
}
