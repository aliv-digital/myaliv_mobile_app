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

  const TopUpPrepaidNumberPostPaidState({
    required this.loadStatus,
    required this.number,
    required this.confirmNumber,
    required this.amountText,
    required this.applyStatus,
    required this.errorMessage,
  });

  factory TopUpPrepaidNumberPostPaidState.initial() =>
      const TopUpPrepaidNumberPostPaidState(
        loadStatus: TopUpPrepaidNumberPostPaidLoadStatus.initial,
        number: '',
        confirmNumber: '',
        amountText: '',
        applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.idle,
        errorMessage: null,
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

  /// True when both fields hold individually-valid phone numbers that
  /// don't match — surfaces an inline error under the confirm field.
  bool get hasConfirmMismatchError =>
      numberValidation.isValid &&
      confirmNumberValidation.isValid &&
      numberValidation.phoneNumberForApi !=
          confirmNumberValidation.phoneNumberForApi;

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
    bool clearError = false,
  }) {
    return TopUpPrepaidNumberPostPaidState(
      loadStatus: loadStatus ?? this.loadStatus,
      number: number ?? this.number,
      confirmNumber: confirmNumber ?? this.confirmNumber,
      amountText: amountText ?? this.amountText,
      applyStatus: applyStatus ?? this.applyStatus,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
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
      ];
}
