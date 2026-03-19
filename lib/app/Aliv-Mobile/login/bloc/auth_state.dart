// lib/login/login_state.dart
import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  static const Object _noChange = Object();

  final String phone;
  final String password;
  final LoginStatus status;
  final String? errorMessage;
  final String? twoFactorKey;
  final bool phoneFieldError;
  final bool passwordFieldError;
  final int errorToastId;

  const LoginState({
    this.phone = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.twoFactorKey,
    this.phoneFieldError = false,
    this.passwordFieldError = false,
    this.errorToastId = 0,
  });

  LoginState copyWith({
    String? phone,
    String? password,
    LoginStatus? status,
    Object? errorMessage = _noChange,
    Object? twoFactorKey = _noChange,
    bool? phoneFieldError,
    bool? passwordFieldError,
    int? errorToastId,
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      twoFactorKey: identical(twoFactorKey, _noChange)
          ? this.twoFactorKey
          : twoFactorKey as String?,
      phoneFieldError: phoneFieldError ?? this.phoneFieldError,
      passwordFieldError: passwordFieldError ?? this.passwordFieldError,
      errorToastId: errorToastId ?? this.errorToastId,
    );
  }

  @override
  List<Object?> get props => [
        phone,
        password,
        status,
        errorMessage,
        twoFactorKey,
        phoneFieldError,
        passwordFieldError,
        errorToastId,
      ];
}
