import 'package:equatable/equatable.dart';

enum CreatePasswordStatus { initial, invalid, valid, submitting, success, failure }

class CreatePasswordState extends Equatable {
  const CreatePasswordState({
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.status = CreatePasswordStatus.initial,
    this.errorMessage,
  });

  final String password;
  final String confirmPassword;
  final bool obscurePassword;
  final bool obscureConfirm;
  final CreatePasswordStatus status;
  final String? errorMessage;

  bool get isMinValid => password.trim().length >= 4;
  bool get isMatch => password.trim() == confirmPassword.trim();
  bool get canSubmit => isMinValid && isMatch;

  CreatePasswordState copyWith({
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? obscureConfirm,
    CreatePasswordStatus? status,
    String? errorMessage,
  }) {
    return CreatePasswordState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    password,
    confirmPassword,
    obscurePassword,
    obscureConfirm,
    status,
    errorMessage,
  ];
}
