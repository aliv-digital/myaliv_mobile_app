import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../login/model/login_country_selection.dart';
import '../../login/utils/login_phone_number_helper.dart';

import '../repository/forgetpassword_repository.dart';
import 'forget_password_event.dart';
import 'forget_password_state.dart';

class ForgetPasswordBloc
    extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final ForgetPasswordRepository repository;
  final AnalyticsService _analyticsService;
  static const _phoneNumberHelper = LoginPhoneNumberHelper();

  ForgetPasswordBloc({
    required this.repository,
    AnalyticsService? analyticsService,
  })  : _analyticsService = analyticsService ??
            (instance.isRegistered<AnalyticsService>()
                ? instance<AnalyticsService>()
                : AnalyticsService()),
        super(const ForgetPasswordState()) {
    on<ForgetPasswordPhoneChanged>((event, emit) {
      emit(
        state.copyWith(
          phone: event.phone,
          status: ForgetPasswordStatus.initial,
          errorMessage: null,
          isEmptyNumberError: false,
          isInvalidNumberLengthError: false,
        ),
      );
    });

    on<ForgetPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ForgetPasswordSubmitted event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    final apiPhone = state.phone.replaceAll(RegExp(r'\D'), '');

    if (apiPhone.isEmpty) {
      // FPW-001 applies only to the empty field; other digitless values keep
      // their existing failure message and toast behavior.
      final isEmptyNumber = state.phone.isEmpty;
      emit(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: isEmptyNumber
              ? 'enter your mobile number'
              : 'Please enter your phone number.',
          isEmptyNumberError: isEmptyNumber,
          isInvalidNumberLengthError: false,
        ),
      );
      return;
    }

    final phoneValidation = _phoneNumberHelper.validateAndBuildApiUsername(
      rawPhoneNumber: state.phone,
      selectedCountry: LoginCountrySelection.defaultBahamas,
    );
    if (!phoneValidation.isValid || phoneValidation.phoneNumberForApi == null) {
      emit(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: 'invalid Format',
          isEmptyNumberError: false,
          isInvalidNumberLengthError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: ForgetPasswordStatus.loading,
        errorMessage: null,
        isEmptyNumberError: false,
        isInvalidNumberLengthError: false,
      ),
    );

    try {
      final validatedApiPhone = phoneValidation.phoneNumberForApi!;
      final mfaToken = await repository.sendRequest(
        apiPhone: validatedApiPhone,
      );
      await _analyticsService.logPasswordResetStarted();
      await _analyticsService.logOtpRequested();
      emit(
        state.copyWith(
          status: ForgetPasswordStatus.success,
          mfaToken: mfaToken,
          apiPhoneNumber: validatedApiPhone,
          isEmptyNumberError: false,
          isInvalidNumberLengthError: false,
        ),
      );
    } catch (e) {
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Something went wrong. Please try again.';
      await _analyticsService.logPasswordResetFailed(
        failureReason: AnalyticsPasswordResetFailureReason.classify(e),
      );
      emit(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: message.trim().toLowerCase() == 'password reset failed'
              ? 'number is invalid'
              : message,
          isEmptyNumberError: false,
          isInvalidNumberLengthError: false,
        ),
      );
    }
  }
}
