import 'package:flutter_bloc/flutter_bloc.dart';

import '../../login/model/login_country_selection.dart';
import '../../login/utils/login_phone_number_helper.dart';
import '../repository/forgetpassword_repository.dart';
import 'forget_password_event.dart';
import 'forget_password_state.dart';

class ForgetPasswordBloc
    extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final ForgetPasswordRepository repository;
  final LoginPhoneNumberHelper phoneNumberHelper;

  ForgetPasswordBloc({
    required this.repository,
    LoginPhoneNumberHelper? phoneNumberHelper,
  })  : phoneNumberHelper = phoneNumberHelper ?? const LoginPhoneNumberHelper(),
        super(const ForgetPasswordState()) {
    on<ForgetPasswordPhoneChanged>((event, emit) {
      emit(state.copyWith(
        phone: event.phone,
        status: ForgetPasswordStatus.initial,
        errorMessage: null,
        phoneFieldError: false,
      ));
    });

    on<ForgetPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ForgetPasswordSubmitted event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    if (state.phone.trim().isEmpty) {
      emit(state.copyWith(
        status: ForgetPasswordStatus.failure,
        errorMessage: 'enter your mobile number',
        phoneFieldError: true,
      ));
      return;
    }

    final phoneValidation = phoneNumberHelper.validateAndBuildApiUsername(
      rawPhoneNumber: state.phone,
      selectedCountry: LoginCountrySelection.defaultBahamas,
    );
    final apiPhone = phoneValidation.phoneNumberForApi;

    if (!phoneValidation.isValid || apiPhone == null) {
      emit(state.copyWith(
        status: ForgetPasswordStatus.failure,
        errorMessage: LoginPhoneNumberHelper.invalidPhoneNumberMessage,
        phoneFieldError: true,
      ));
      return;
    }

    emit(state.copyWith(
      status: ForgetPasswordStatus.loading,
      errorMessage: null,
      phoneFieldError: false,
    ));

    try {
      final mfaToken = await repository.sendRequest(apiPhone: apiPhone);
      emit(state.copyWith(
        status: ForgetPasswordStatus.success,
        mfaToken: mfaToken,
        apiPhoneNumber: apiPhone,
        phoneFieldError: false,
      ));
    } catch (e) {
      final message = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Something went wrong. Please try again.';
      emit(state.copyWith(
        status: ForgetPasswordStatus.failure,
        errorMessage: message,
        phoneFieldError: false,
      ));
    }
  }
}
