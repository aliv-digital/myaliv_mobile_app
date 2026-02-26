// lib/login/login_state.dart
import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  static const Object _noChange = Object();

  final String phone;
  final String password;
  final LoginStatus status;
  final String? errorMessage;
  final bool phoneFieldError;
  final bool passwordFieldError;

  const LoginState({
    this.phone = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.phoneFieldError = false,
    this.passwordFieldError = false,
  });

  LoginState copyWith({
    String? phone,
    String? password,
    LoginStatus? status,
    Object? errorMessage = _noChange,
    bool? phoneFieldError,
    bool? passwordFieldError,
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      phoneFieldError: phoneFieldError ?? this.phoneFieldError,
      passwordFieldError: passwordFieldError ?? this.passwordFieldError,
    );
  }

  @override
  List<Object?> get props => [
        phone,
        password,
        status,
        errorMessage,
        phoneFieldError,
        passwordFieldError,
      ];
}
