// lib/login/login_state.dart
import 'package:equatable/equatable.dart';

enum ForgetPasswordStatus { initial, loading, success, failure }

class ForgetPasswordState extends Equatable {
  final String phone;
  final String password;
  final ForgetPasswordStatus status;
  final String? errorMessage;

  const ForgetPasswordState({
    this.phone = '',
    this.password = '',
    this.status = ForgetPasswordStatus.initial,
    this.errorMessage,
  });

  ForgetPasswordState copyWith({
    String? phone,
    String? password,
    ForgetPasswordStatus? status,
    String? errorMessage,
  }) {
    return ForgetPasswordState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [phone, password, status, errorMessage];
}
