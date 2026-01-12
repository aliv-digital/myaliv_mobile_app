import 'package:equatable/equatable.dart';

enum EnterPasswordPrepaidStatus { initial, loading, ready, submitting, success, failure }

class EnterPasswordPrepaidState extends Equatable {
  final EnterPasswordPrepaidStatus status;
  final String password;
  final bool obscure;
  final String? errorMessage;

  const EnterPasswordPrepaidState({
    required this.status,
    required this.password,
    required this.obscure,
    required this.errorMessage,
  });

  factory EnterPasswordPrepaidState.initial() {
    return const EnterPasswordPrepaidState(
      status: EnterPasswordPrepaidStatus.initial,
      password: '',
      obscure: true,
      errorMessage: null,
    );
  }

  bool get isValid => password.trim().isNotEmpty;

  EnterPasswordPrepaidState copyWith({
    EnterPasswordPrepaidStatus? status,
    String? password,
    bool? obscure,
    String? errorMessage,
  }) {
    return EnterPasswordPrepaidState(
      status: status ?? this.status,
      password: password ?? this.password,
      obscure: obscure ?? this.obscure,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, password, obscure, errorMessage];
}
