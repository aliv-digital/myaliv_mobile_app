import 'package:equatable/equatable.dart';

enum EnterPasswordAutoRenewPrepaidStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

class EnterPasswordAutoRenewPrepaidState extends Equatable {
  final EnterPasswordAutoRenewPrepaidStatus status;
  final String password;
  final bool obscure;
  final String? errorMessage;

  const EnterPasswordAutoRenewPrepaidState({
    required this.status,
    required this.password,
    required this.obscure,
    required this.errorMessage,
  });

  factory EnterPasswordAutoRenewPrepaidState.initial() {
    return const EnterPasswordAutoRenewPrepaidState(
      status: EnterPasswordAutoRenewPrepaidStatus.initial,
      password: '',
      obscure: true,
      errorMessage: null,
    );
  }

  bool get isValid => password.trim().isNotEmpty;

  EnterPasswordAutoRenewPrepaidState copyWith({
    EnterPasswordAutoRenewPrepaidStatus? status,
    String? password,
    bool? obscure,
    String? errorMessage,
  }) {
    return EnterPasswordAutoRenewPrepaidState(
      status: status ?? this.status,
      password: password ?? this.password,
      obscure: obscure ?? this.obscure,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, password, obscure, errorMessage];
}
