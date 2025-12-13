// lib/login/login_state.dart
import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final String phone;
  final String password;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.phone = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith({
    String? phone,
    String? password,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [phone, password, status, errorMessage];
}
