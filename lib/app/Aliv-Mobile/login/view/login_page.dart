// lib/login/login_screen.dart
import 'package:core/core.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../loginOtp/model/login_otp_route_args.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../repository/auth_repository.dart';
import '../theme/login_theme.dart';
import '../widgets/login_bottom_texts.dart';
import '../widgets/login_header.dart';
import '../widgets/login_password_field.dart';
import '../widgets/login_phone_row.dart';
import '../widgets/login_social_buttons.dart';

enum _LoginBiometricMethod { faceId, fingerprint }

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        repository: LoginRepository(),
        appUiConfigCubit: context.read<AppUiConfigCubit>(),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  Future<void> _authenticateWithBiometrics(
    BuildContext context,
    _LoginBiometricMethod method,
  ) async {
    final cubit = instance<FingerFaceSecurityCubit>();
    final biometricData = cubit.state.data;
    final methodIsAvailable = switch (method) {
      _LoginBiometricMethod.faceId => biometricData?.isFaceIdAvailable == true,
      _LoginBiometricMethod.fingerprint =>
        biometricData?.isFingerprintAvailable == true,
    };

    if (cubit.state.isAuthenticating ||
        !cubit.state.isBiometricEnabled ||
        !methodIsAvailable) {
      return;
    }

    final result = await cubit.authenticate(
      reason: switch (method) {
        _LoginBiometricMethod.faceId => 'Use Face ID to sign in to MyAliv',
        _LoginBiometricMethod.fingerprint =>
          'Use your fingerprint to sign in to MyAliv',
      },
      biometricOnly: true,
    );

    if (!context.mounted) return;

    final message = switch (result) {
      BiometricAuthResult.failed when method == _LoginBiometricMethod.faceId =>
        'Face not detected. Try again.',
      BiometricAuthResult.failed =>
        'Fingerprint not recognized. Please try again.',
      BiometricAuthResult.temporaryLockout ||
      BiometricAuthResult.biometricLockout
          when method == _LoginBiometricMethod.fingerprint =>
        'Too many failed attempts. Please log in with your password.',
      _ => null,
    };

    if (message != null) {
      AppToast.show(message: message, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AuthModuleColors.pageBackground,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AuthModuleColors.pageBackground,
        systemNavigationBarDividerColor: AuthModuleColors.pageBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    return StripedScaffold(
      // ✅ Keyboard উঠলেও body resize হবে না (BottomStripes নড়বে না)
      resizeToAvoidBottomInset: false,
      stripesReserveSpace: true,

      body: SafeArea(
        child: BlocListener<LoginBloc, LoginState>(
          listenWhen: (previous, current) {
            final bool loginSuccessChanged =
                previous.status != current.status &&
                    current.status == LoginStatus.success;

            final bool errorToastTriggered =
                previous.errorToastId != current.errorToastId;

            return loginSuccessChanged || errorToastTriggered;
          },
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              // Direct-login path: server returned a Ticket, session already
              // completed by LoginBloc via AuthCompletionService.
              if (state.outcome == LoginOutcome.authenticated) {
                AppToast.show(
                  message: 'Logged in successfully',
                  type: ToastType.success,
                );
                context.go(AppRoutes.home);
                return;
              }

              // 2FA path: forward mfa_token to the OTP screen.
              AppToast.show(
                  message: 'OTP sent successfully', type: ToastType.success);

              final String? mfaToken = state.mfaToken;
              if (mfaToken == null || mfaToken.isEmpty) {
                AppToast.show(
                  message: 'MFA token is missing from login response.',
                  type: ToastType.error,
                );
                return;
              }

              final String? apiPhoneNumber = state.apiPhoneNumber;
              if (apiPhoneNumber == null || apiPhoneNumber.isEmpty) {
                AppToast.show(
                  message: 'Phone number is missing from login state.',
                  type: ToastType.error,
                );
                return;
              }

              context.push(
                AppRoutes.loginOtp,
                extra: LoginOtpRouteArgs(
                  mfaToken: mfaToken,
                  phoneNumber: state.phone.trim(),
                  apiPhoneNumber: apiPhoneNumber,
                ),
              );
            }
            if (state.status == LoginStatus.failure &&
                state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              AppToast.show(
                message: state.errorMessage.toString(),
                type: ToastType.error,
              );
              //context.push(AppRoutes.loginOtp);
            }
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: LoginHeader(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: AuthModulePaddings.pageHorizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AuthModuleSizes.welcomeToPhoneGap),
                      const LoginPhoneRow(),
                      const SizedBox(
                          height: AuthModuleSizes.phoneToPasswordGap),
                      const LoginPasswordField(),
                      const SizedBox(
                          height: AuthModuleSizes.passwordToErrorRowGap),
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          final hasError =
                              state.status == LoginStatus.failure &&
                                  state.passwordFieldError;
                          return Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Visibility(
                                    visible: hasError,
                                    maintainSize: true,
                                    maintainState: true,
                                    maintainAnimation: true,
                                    //child: Text(''),
                                    child: Text(
                                      'enter your password',
                                      style: AuthModuleTextStyles
                                          .invalidCredentials,
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                style: AuthModuleButtonStyles.inlineTextLink,
                                onPressed: () {
                                  context.push(AppRoutes.forgetPassword);
                                },
                                child: const Text(
                                  'forgot password?',
                                  style: AuthModuleTextStyles.forgotPassword,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(
                          height: AuthModuleSizes.errorRowToSignInGap),
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          final loading = state.status == LoginStatus.loading;
                          return DefaultButton(
                            label: 'sign in',
                            isLoading: loading,
                            height: AuthModuleSizes.fieldHeight,
                            textStyle: AuthModuleTextStyles.signInButton,
                            onPressed: () {
                              context
                                  .read<LoginBloc>()
                                  .add(const LoginSubmitted());
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AuthModuleSizes.signInToSocialGap),
                      BlocBuilder<FingerFaceSecurityCubit,
                          FingerFaceSecurityState>(
                        bloc: instance<FingerFaceSecurityCubit>(),
                        builder: (context, state) {
                          final data = state.data;
                          final canAuthenticate = state.isBiometricEnabled &&
                              !state.isAuthenticating;

                          return LoginSocialButtons(
                            onFaceIdPressed: canAuthenticate &&
                                    data?.isFaceIdAvailable == true
                                ? () => _authenticateWithBiometrics(
                                      context,
                                      _LoginBiometricMethod.faceId,
                                    )
                                : null,
                            onFingerprintPressed: canAuthenticate &&
                                    data?.isFingerprintAvailable == true
                                ? () => _authenticateWithBiometrics(
                                      context,
                                      _LoginBiometricMethod.fingerprint,
                                    )
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: AuthModuleSizes.socialToBottomGap),
                      LoginBottomTexts(),
                      const SizedBox(
                          height: AuthModuleSizes.bottomScrollSafeGap),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
