import 'package:equatable/equatable.dart';

enum OtpProfilePrepaidStatus { initial, loading, success, failure }
enum OtpProfilePrepaidResendStatus { idle, loading, done }

class OtpProfilePrepaidState extends Equatable {
  final String code;
  final OtpProfilePrepaidStatus status;
  final OtpProfilePrepaidResendStatus resendStatus;
  final String? errorMessage;

  const OtpProfilePrepaidState({
    this.code = '',
    this.status = OtpProfilePrepaidStatus.initial,
    this.resendStatus = OtpProfilePrepaidResendStatus.idle,
    this.errorMessage,
  });

  OtpProfilePrepaidState copyWith({
    String? code,
    OtpProfilePrepaidStatus? status,
    OtpProfilePrepaidResendStatus? resendStatus,
    String? errorMessage,
  }) {
    return OtpProfilePrepaidState(
      code: code ?? this.code,
      status: status ?? this.status,
      resendStatus: resendStatus ?? this.resendStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [code, status, resendStatus, errorMessage];
}
