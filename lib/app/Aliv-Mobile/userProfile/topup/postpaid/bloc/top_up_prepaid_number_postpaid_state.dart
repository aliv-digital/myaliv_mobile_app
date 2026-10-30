import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';

enum TopUpPrepaidNumberPostPaidLoadStatus { initial, loading, ready, failure }

enum TopUpPrepaidNumberPostPaidApplyStatus { idle, loading, success, failure }

class TopUpPrepaidNumberPostPaidState extends Equatable {
  static const LoginPhoneNumberHelper _phoneNumberHelper =
      LoginPhoneNumberHelper();
  static const LoginCountrySelection _selectedCountry =
      LoginCountrySelection.defaultBahamas;

  final TopUpPrepaidNumberPostPaidLoadStatus loadStatus;

  final String number;
  final String confirmNumber;
  final String amountText;

  final TopUpPrepaidNumberPostPaidApplyStatus applyStatus;
  final String? errorMessage;

  /// Case B / TOP-002 copy rendered under the amount box (not as a toast).
  final String? amountInlineError;

  /// Remaining 24h headroom from `GET /Account/top-up-limit-left`.
  /// Null until the fetch completes; also null when the fetch has failed.
  final double? limitLeft;

  /// True when the limit-left fetch failed on screen load; the A/B/C/D gate
  /// treats this as Case D (fail-closed) when the user taps apply.
  final bool limitFetchFailed;

  const TopUpPrepaidNumberPostPaidState({
    required this.loadStatus,
    required this.number,
    required this.confirmNumber,
    required this.amountText,
    required this.applyStatus,
    required this.errorMessage,
    required this.amountInlineError,
    required this.limitLeft,
    required this.limitFetchFailed,
  });

  factory TopUpPrepaidNumberPostPaidState.initial() =>
      const TopUpPrepaidNumberPostPaidState(
        loadStatus: TopUpPrepaidNumberPostPaidLoadStatus.initial,
        number: '',
        confirmNumber: '',
        amountText: '',
        applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.idle,
        errorMessage: null,
        amountInlineError: null,
        limitLeft: null,
        limitFetchFailed: false,
      );

  double get amountValue {
    final cleaned = amountText.trim().replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  LoginPhoneValidationResult get numberValidation =>
      _phoneNumberHelper.validateAndBuildApiUsername(
        rawPhoneNumber: number,
        selectedCountry: _selectedCountry,
      );

  LoginPhoneValidationResult get confirmNumberValidation =>
      _phoneNumberHelper.validateAndBuildApiUsername(
        rawPhoneNumber: confirmNumber,
        selectedCountry: _selectedCountry,
      );

  String? get numberForApi => numberValidation.phoneNumberForApi;

  bool get numbersMatch =>
      numberValidation.isValid &&
      confirmNumberValidation.isValid &&
      numberValidation.phoneNumberForApi ==
          confirmNumberValidation.phoneNumberForApi;

  /// Mirrors the guest "purchase a plan" bottom sheet: mismatch surfaces as
  /// soon as the confirm field is non-empty and its digits differ from the
  /// main number's digits — independent of either field's own validity.
  bool get hasConfirmMismatchError {
    if (confirmNumber.isEmpty) return false;
    final digitsOnly = RegExp(r'[^0-9]');
    return number.replaceAll(digitsOnly, '') !=
        confirmNumber.replaceAll(digitsOnly, '');
  }

  bool get canApply =>
      loadStatus == TopUpPrepaidNumberPostPaidLoadStatus.ready &&
      applyStatus != TopUpPrepaidNumberPostPaidApplyStatus.loading &&
      numbersMatch &&
      amountValue > 0;

  TopUpPrepaidNumberPostPaidState copyWith({
    TopUpPrepaidNumberPostPaidLoadStatus? loadStatus,
    String? number,
    String? confirmNumber,
    String? amountText,
    TopUpPrepaidNumberPostPaidApplyStatus? applyStatus,
    String? errorMessage,
    String? amountInlineError,
    double? limitLeft,
    bool? limitFetchFailed,
    bool clearError = false,
    bool clearAmountInlineError = false,
  }) {
    return TopUpPrepaidNumberPostPaidState(
      loadStatus: loadStatus ?? this.loadStatus,
      number: number ?? this.number,
      confirmNumber: confirmNumber ?? this.confirmNumber,
      amountText: amountText ?? this.amountText,
      applyStatus: applyStatus ?? this.applyStatus,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      amountInlineError: clearAmountInlineError
          ? null
          : amountInlineError ?? this.amountInlineError,
      limitLeft: limitLeft ?? this.limitLeft,
      limitFetchFailed: limitFetchFailed ?? this.limitFetchFailed,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    number,
    confirmNumber,
    amountText,
    applyStatus,
    errorMessage,
    amountInlineError,
    limitLeft,
    limitFetchFailed,
  ];
}
