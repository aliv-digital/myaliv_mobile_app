import 'package:equatable/equatable.dart';

enum ForgetPasswordStatus { initial, loading, success, failure }

class ForgetPasswordState extends Equatable {
  final String phone;
  final String mfaToken;
  final String apiPhoneNumber;
  final ForgetPasswordStatus status;
  final String? errorMessage;
  final bool phoneFieldError;
  final bool isTermsLoading;
  final bool isPrivacyLoading;

  const ForgetPasswordState({
    this.phone = '',
    this.mfaToken = '',
    this.apiPhoneNumber = '',
    this.status = ForgetPasswordStatus.initial,
    this.errorMessage,
    this.phoneFieldError = false,
    this.isTermsLoading = false,
    this.isPrivacyLoading = false,
  });

  ForgetPasswordState copyWith({
    String? phone,
    String? mfaToken,
    String? apiPhoneNumber,
    ForgetPasswordStatus? status,
    String? errorMessage,
    bool? phoneFieldError,
    bool? isTermsLoading,
    bool? isPrivacyLoading,
  }) {
    return ForgetPasswordState(
      phone: phone ?? this.phone,
      mfaToken: mfaToken ?? this.mfaToken,
      apiPhoneNumber: apiPhoneNumber ?? this.apiPhoneNumber,
      status: status ?? this.status,
      errorMessage: errorMessage,
      phoneFieldError: phoneFieldError ?? this.phoneFieldError,
      isTermsLoading: isTermsLoading ?? this.isTermsLoading,
      isPrivacyLoading: isPrivacyLoading ?? this.isPrivacyLoading,
    );
  }

  @override
  List<Object?> get props => [
        phone,
        mfaToken,
        apiPhoneNumber,
        status,
        errorMessage,
        phoneFieldError,
        isTermsLoading,
        isPrivacyLoading,
      ];
}
