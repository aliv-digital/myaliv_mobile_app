import 'package:equatable/equatable.dart';

enum ForgetPasswordOtpStatus { initial, loading, success, failure }
enum ForgetPasswordOtpResendStatus { idle, loading, done }

class ForgetPasswordOtpState extends Equatable {
  final String code;
  final ForgetPasswordOtpStatus status;
  final ForgetPasswordOtpResendStatus resendStatus;
  final String? errorMessage;

  const ForgetPasswordOtpState({
    this.code = '',
    this.status = ForgetPasswordOtpStatus.initial,
    this.resendStatus = ForgetPasswordOtpResendStatus.idle,
    this.errorMessage,
  });

  ForgetPasswordOtpState copyWith({
    String? code,
    ForgetPasswordOtpStatus? status,
    ForgetPasswordOtpResendStatus? resendStatus,
    String? errorMessage,
  }) {
    return ForgetPasswordOtpState(
      code: code ?? this.code,
      status: status ?? this.status,
      resendStatus: resendStatus ?? this.resendStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [code, status, resendStatus, errorMessage];
}
