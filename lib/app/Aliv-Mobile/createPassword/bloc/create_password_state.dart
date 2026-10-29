import 'package:equatable/equatable.dart';

enum CreatePasswordStatus {
  initial,
  invalid,
  valid,
  submitting,
  success,
  failure,
}

class CreatePasswordState extends Equatable {
  const CreatePasswordState({
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.obscureConfirm = true,
    this.hasEditedPassword = false,
    this.hasEditedConfirmation = false,
    this.showEmptyFieldErrors = false,
    this.status = CreatePasswordStatus.initial,
    this.errorMessage,
  });

  final String password;
  final String confirmPassword;
  final bool obscurePassword;
  final bool obscureConfirm;
  final bool hasEditedPassword;
  final bool hasEditedConfirmation;
  final bool showEmptyFieldErrors;
  final CreatePasswordStatus status;
  final String? errorMessage;

  bool get isMinValid => password.trim().length >= 8;
  bool get isMatch => password.trim() == confirmPassword.trim();
  bool get canSubmit => passwordValidationError == null && isMatch;

  // Submission and live feedback share the existing trimmed-length policy.
  String? get passwordValidationError {
    if (!isMinValid) {
      return 'Password must be 8 characters long';
    }
    if (password.trim().length > 64) {
      return 'Password must be 64 characters or fewer.';
    }
    return null;
  }

  String? get confirmationValidationError =>
      isMatch ? null : 'Passwords do not match.';

  String? get passwordError {
    if (showEmptyFieldErrors && password.trim().isEmpty) {
      return 'password must be 8 characters long';
    }
    return hasEditedPassword ? passwordValidationError : null;
  }

  String? get confirmPasswordError {
    if (showEmptyFieldErrors && confirmPassword.trim().isEmpty) {
      return 'please re-enter your password.';
    }
    return hasEditedConfirmation ? confirmationValidationError : null;
  }

  CreatePasswordState copyWith({
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? obscureConfirm,
    bool? hasEditedPassword,
    bool? hasEditedConfirmation,
    bool? showEmptyFieldErrors,
    CreatePasswordStatus? status,
    String? errorMessage,
  }) {
    return CreatePasswordState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirm: obscureConfirm ?? this.obscureConfirm,
      hasEditedPassword: hasEditedPassword ?? this.hasEditedPassword,
      hasEditedConfirmation:
          hasEditedConfirmation ?? this.hasEditedConfirmation,
      showEmptyFieldErrors: showEmptyFieldErrors ?? this.showEmptyFieldErrors,
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
    hasEditedPassword,
    hasEditedConfirmation,
    showEmptyFieldErrors,
    status,
    errorMessage,
  ];
}
