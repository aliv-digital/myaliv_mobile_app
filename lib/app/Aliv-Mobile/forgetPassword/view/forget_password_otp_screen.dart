import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/login_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/view/login_otp_screen.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../model/password_recovery_otp_challenge.dart';
import '../repository/password_recovery_otp_repository.dart';

class ForgetPasswordOtpScreen extends LoginOtpScreen {
  ForgetPasswordOtpScreen({super.key, required this.challenge})
    : super(
        initialMfaToken: challenge.attempts.mfaToken,
        initialPhoneNumber: challenge.phoneNumber,
        initialApiPhoneNumber: challenge.apiPhoneNumber,
        clearCodeOnResend: true,
        resetValidationOnResend: true,
        successMessage: 'Code verified.',
        onSuccess: _continueToPasswordReset,
      );

  final PasswordRecoveryOtpChallenge challenge;

  @override
  LoginOtpBloc createBloc(BuildContext context) => LoginOtpBloc(
    repository: PasswordRecoveryOtpRepository(
      delegate: LoginOtpRepository(),
      attempts: challenge.attempts,
    ),
    appUiConfigCubit: context.read<AppUiConfigCubit>(),
    initialMfaToken: challenge.attempts.mfaToken,
    initialPhoneNumber: initialPhoneNumber,
    initialApiPhoneNumber: initialApiPhoneNumber,
    preventDuplicateSubmissions: true,
    resetValidationOnResend: true,
  );

  static void _continueToPasswordReset(BuildContext context) {
    context.push(AppRoutes.createPassword, extra: true);
  }
}
