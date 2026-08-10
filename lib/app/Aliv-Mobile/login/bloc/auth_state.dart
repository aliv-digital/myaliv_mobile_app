// lib/login/login_state.dart
import 'package:equatable/equatable.dart';

import '../model/login_country_selection.dart';

enum LoginStatus { initial, loading, success, failure }

/// Distinguishes the two success shapes of the login API:
///  - [needsOtp]: server returned a TwoFactorKey and dispatched a PIN.
///  - [authenticated]: server returned a Ticket + AccountId directly (no 2FA).
enum LoginOutcome { none, needsOtp, authenticated }

class LoginState extends Equatable {
  static const Object _noChange = Object();

  final String phone;
  final String password;
  final LoginStatus status;
  final LoginOutcome outcome;
  final String? errorMessage;
  final String? mfaToken;
  final String? apiPhoneNumber;
  final LoginCountrySelection selectedCountry;
  final bool phoneFieldError;
  final bool passwordFieldError;
  final int errorToastId;

  const LoginState({
    this.phone = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.outcome = LoginOutcome.none,
    this.errorMessage,
    this.mfaToken,
    this.apiPhoneNumber,
    this.selectedCountry = LoginCountrySelection.defaultBahamas,
    this.phoneFieldError = false,
    this.passwordFieldError = false,
    this.errorToastId = 0,
  });

  LoginState copyWith({
    String? phone,
    String? password,
    LoginStatus? status,
    LoginOutcome? outcome,
    Object? errorMessage = _noChange,
    Object? mfaToken = _noChange,
    Object? apiPhoneNumber = _noChange,
    LoginCountrySelection? selectedCountry,
    bool? phoneFieldError,
    bool? passwordFieldError,
    int? errorToastId,
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      password: password ?? this.password,
      status: status ?? this.status,
      outcome: outcome ?? this.outcome,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      mfaToken: identical(mfaToken, _noChange)
          ? this.mfaToken
          : mfaToken as String?,
      apiPhoneNumber: identical(apiPhoneNumber, _noChange)
          ? this.apiPhoneNumber
          : apiPhoneNumber as String?,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      phoneFieldError: phoneFieldError ?? this.phoneFieldError,
      passwordFieldError: passwordFieldError ?? this.passwordFieldError,
      errorToastId: errorToastId ?? this.errorToastId,
    );
  }

  @override
  List<Object?> get props => [
        phone,
        password,
        status,
        outcome,
        errorMessage,
        mfaToken,
        apiPhoneNumber,
        selectedCountry,
        phoneFieldError,
        passwordFieldError,
        errorToastId,
      ];
}
