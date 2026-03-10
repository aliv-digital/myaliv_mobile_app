import 'package:equatable/equatable.dart';

enum LoginOtpStatus { initial, loading, success, failure }
enum LoginOtpResendStatus { idle, loading, done }
enum LoginOtpErrorType {
  none,
  emptyCode,
  incompleteCode,
  invalidCode,
  missingVerificationContext,
  unknown,
}

class LoginOtpState extends Equatable {
  final String code;
  final String twoFactorKey;
  final String phoneNumber;
  final LoginOtpStatus status;
  final LoginOtpResendStatus resendStatus;
  final LoginOtpErrorType errorType;
  final bool codeFieldError;
  final String? errorMessage;

  const LoginOtpState({
    this.code = '',
    this.twoFactorKey = '',
    this.phoneNumber = '',
    this.status = LoginOtpStatus.initial,
    this.resendStatus = LoginOtpResendStatus.idle,
    this.errorType = LoginOtpErrorType.none,
    this.codeFieldError = false,
    this.errorMessage,
  });

  LoginOtpState copyWith({
    String? code,
    String? twoFactorKey,
    String? phoneNumber,
    LoginOtpStatus? status,
    LoginOtpResendStatus? resendStatus,
    LoginOtpErrorType? errorType,
    bool? codeFieldError,
    String? errorMessage,
  }) {
    return LoginOtpState(
      code: code ?? this.code,
      twoFactorKey: twoFactorKey ?? this.twoFactorKey,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      resendStatus: resendStatus ?? this.resendStatus,
      errorType: errorType ?? this.errorType,
      codeFieldError: codeFieldError ?? this.codeFieldError,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    code,
    twoFactorKey,
    phoneNumber,
    status,
    resendStatus,
    errorType,
    codeFieldError,
    errorMessage,
  ];
}
