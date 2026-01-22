import 'package:equatable/equatable.dart';

enum OtpAutoRenewPrepaidStatus { initial, loading, success, failure }
enum OtpAutoRenewPrepaidResendStatus { idle, loading, done }

class OtpAutoRenewPrepaidState extends Equatable {
  final String code;
  final OtpAutoRenewPrepaidStatus status;
  final OtpAutoRenewPrepaidResendStatus resendStatus;
  final String? errorMessage;

  const OtpAutoRenewPrepaidState({
    this.code = '',
    this.status = OtpAutoRenewPrepaidStatus.initial,
    this.resendStatus = OtpAutoRenewPrepaidResendStatus.idle,
    this.errorMessage,
  });

  OtpAutoRenewPrepaidState copyWith({
    String? code,
    OtpAutoRenewPrepaidStatus? status,
    OtpAutoRenewPrepaidResendStatus? resendStatus,
    String? errorMessage,
  }) {
    return OtpAutoRenewPrepaidState(
      code: code ?? this.code,
      status: status ?? this.status,
      resendStatus: resendStatus ?? this.resendStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [code, status, resendStatus, errorMessage];
}
