import 'package:equatable/equatable.dart';

enum OTPPostpaidStatus { initial, loading, success, failure }
enum OTPPostpaidResendStatus { idle, loading, done }

class OTPPostpaidState extends Equatable {
  final String code;
  final OTPPostpaidStatus status;
  final OTPPostpaidResendStatus resendStatus;
  final String? errorMessage;

  const OTPPostpaidState({
    this.code = '',
    this.status = OTPPostpaidStatus.initial,
    this.resendStatus = OTPPostpaidResendStatus.idle,
    this.errorMessage,
  });

  OTPPostpaidState copyWith({
    String? code,
    OTPPostpaidStatus? status,
    OTPPostpaidResendStatus? resendStatus,
    String? errorMessage,
  }) {
    return OTPPostpaidState(
      code: code ?? this.code,
      status: status ?? this.status,
      resendStatus: resendStatus ?? this.resendStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [code, status, resendStatus, errorMessage];
}
