import 'package:equatable/equatable.dart';

enum ChangePasswordPrepaidStatus { initial, ready, submitting, success, failure }

class ChangePasswordPrepaidState extends Equatable {
  final ChangePasswordPrepaidStatus status;

  final String newPassword;
  final String confirmPassword;

  final bool obscureNew;
  final bool obscureConfirm;

  final String? errorMessage;
  final String? newPasswordError;
  final String? confirmPasswordError;

  const ChangePasswordPrepaidState({
    required this.status,
    required this.newPassword,
    required this.confirmPassword,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.errorMessage,
    required this.newPasswordError,
    required this.confirmPasswordError,
  });

  factory ChangePasswordPrepaidState.initial() {
    return const ChangePasswordPrepaidState(
      status: ChangePasswordPrepaidStatus.initial,
      newPassword: '',
      confirmPassword: '',
      obscureNew: true,
      obscureConfirm: true,
      errorMessage: null,
      newPasswordError: null,
      confirmPasswordError: null,
    );
  }

  bool get isValid {
    final a = newPassword.trim();
    final b = confirmPassword.trim();
    if (a.length < 4) return false;
    if (b.length < 4) return false;
    return a == b;
  }

  static const Object _kSame = Object();

  ChangePasswordPrepaidState copyWith({
    ChangePasswordPrepaidStatus? status,
    String? newPassword,
    String? confirmPassword,
    bool? obscureNew,
    bool? obscureConfirm,
    String? errorMessage,
    Object? newPasswordError = _kSame,
    Object? confirmPasswordError = _kSame,
  }) {
    return ChangePasswordPrepaidState(
      status: status ?? this.status,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscureNew: obscureNew ?? this.obscureNew,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      errorMessage: errorMessage,
      newPasswordError: identical(newPasswordError, _kSame)
          ? this.newPasswordError
          : newPasswordError as String?,
      confirmPasswordError: identical(confirmPasswordError, _kSame)
          ? this.confirmPasswordError
          : confirmPasswordError as String?,
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
    newPasswordError,
    confirmPasswordError,
  ];
}
