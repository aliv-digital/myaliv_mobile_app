import 'package:equatable/equatable.dart';

enum EnterPasswordPostpaidStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

class EnterPasswordPostpaidState extends Equatable {
  final EnterPasswordPostpaidStatus status;
  final String password;
  final bool obscure;
  final String? errorMessage;

  const EnterPasswordPostpaidState({
    required this.status,
    required this.password,
    required this.obscure,
    required this.errorMessage,
  });

  factory EnterPasswordPostpaidState.initial() {
    return const EnterPasswordPostpaidState(
      status: EnterPasswordPostpaidStatus.initial,
      password: '',
      obscure: true,
      errorMessage: null,
    );
  }

  bool get isValid => password.trim().isNotEmpty;

  EnterPasswordPostpaidState copyWith({
    EnterPasswordPostpaidStatus? status,
    String? password,
    bool? obscure,
    String? errorMessage,
  }) {
    return EnterPasswordPostpaidState(
      status: status ?? this.status,
      password: password ?? this.password,
      obscure: obscure ?? this.obscure,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, password, obscure, errorMessage];
}
