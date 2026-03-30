// lib/login/login_state.dart
import 'package:equatable/equatable.dart';

import '../model/login_country_selection.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  static const Object _noChange = Object();

  final String phone;
  final String password;
  final LoginStatus status;
  final String? errorMessage;
  final String? twoFactorKey;
  final String? apiPhoneNumber;
  final LoginCountrySelection selectedCountry;
  final bool phoneFieldError;
  final bool passwordFieldError;
  final int errorToastId;

  const LoginState({
    this.phone = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.twoFactorKey,
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
    Object? errorMessage = _noChange,
    Object? twoFactorKey = _noChange,
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
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      twoFactorKey: identical(twoFactorKey, _noChange)
          ? this.twoFactorKey
          : twoFactorKey as String?,
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
        errorMessage,
        twoFactorKey,
        apiPhoneNumber,
        selectedCountry,
        phoneFieldError,
        passwordFieldError,
        errorToastId,
      ];
}
