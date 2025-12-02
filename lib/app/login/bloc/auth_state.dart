import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  final String phoneNumber;
  final String password;
  final AuthStatus status;
  final String? error;
  final String? userId;  // Add userId for success state

  // AuthState constructor
  const AuthState({
    this.phoneNumber = '',
    this.password = '',
    this.status = AuthStatus.initial,
    this.error,
    this.userId,  // For success state
  });

  // initial state method
  static AuthState initial() {
    return const AuthState();  // initial state
  }

  // success state method
  AuthState success({required String userId}) {
    return AuthState(
      status: AuthStatus.success,
      userId: userId,
    );
  }

  // failure state method
  AuthState failure({required String error}) {
    return AuthState(
      status: AuthStatus.failure,
      error: error,
    );
  }

  // copyWith method
  AuthState copyWith({
    String? phoneNumber,
    String? password,
    AuthStatus? status,
    String? error,
    String? userId,
  }) {
    return AuthState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      status: status ?? this.status,
      error: error ?? this.error,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [phoneNumber, password, status, error, userId];
}
