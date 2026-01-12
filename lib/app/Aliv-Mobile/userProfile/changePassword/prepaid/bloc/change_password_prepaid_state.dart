import 'package:equatable/equatable.dart';

enum ChangePasswordPrepaidStatus { initial, ready, submitting, success, failure }

class ChangePasswordPrepaidState extends Equatable {
  final ChangePasswordPrepaidStatus status;

  final String newPassword;
  final String confirmPassword;

  final bool obscureNew;
  final bool obscureConfirm;

  final String? errorMessage;

  const ChangePasswordPrepaidState({
    required this.status,
    required this.newPassword,
    required this.confirmPassword,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.errorMessage,
  });

  factory ChangePasswordPrepaidState.initial() {
    return const ChangePasswordPrepaidState(
      status: ChangePasswordPrepaidStatus.initial,
      newPassword: '',
      confirmPassword: '',
      obscureNew: true,
      obscureConfirm: true,
      errorMessage: null,
    );
  }

  bool get isValid {
    final a = newPassword.trim();
    final b = confirmPassword.trim();
    if (a.length < 4) return false;
    if (b.length < 4) return false;
    return a == b;
  }

  ChangePasswordPrepaidState copyWith({
    ChangePasswordPrepaidStatus? status,
    String? newPassword,
    String? confirmPassword,
    bool? obscureNew,
    bool? obscureConfirm,
    String? errorMessage,
  }) {
    return ChangePasswordPrepaidState(
      status: status ?? this.status,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscureNew: obscureNew ?? this.obscureNew,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    newPassword,
    confirmPassword,
    obscureNew,
    obscureConfirm,
    errorMessage,
  ];
}
