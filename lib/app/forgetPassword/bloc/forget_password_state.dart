// lib/login/login_state.dart
import 'package:equatable/equatable.dart';

enum ForgetPasswordStatus { initial, loading, success, failure }

class ForgetPasswordState extends Equatable {
  final String phone;
  final String password;
  final ForgetPasswordStatus status;
  final String? errorMessage;

  // 🔹 new fields
  final bool isTermsLoading;
  final bool isPrivacyLoading;

  const ForgetPasswordState({
    this.phone = '',
    this.password = '',
    this.status = ForgetPasswordStatus.initial,
    this.errorMessage,
    this.isTermsLoading = false,
    this.isPrivacyLoading = false,
  });

  ForgetPasswordState copyWith({
    String? phone,
    String? password,
    ForgetPasswordStatus? status,
    String? errorMessage,
    bool? isTermsLoading,
    bool? isPrivacyLoading,
  }) {
    return ForgetPasswordState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      status: status ?? this.status,
      // same behaviour as before: override even with null if given
      errorMessage: errorMessage,
      isTermsLoading: isTermsLoading ?? this.isTermsLoading,
      isPrivacyLoading: isPrivacyLoading ?? this.isPrivacyLoading,
    );
  }

  @override
  List<Object?> get props => [
    phone,
    password,
    status,
    errorMessage,
    isTermsLoading,
    isPrivacyLoading,
  ];
}
