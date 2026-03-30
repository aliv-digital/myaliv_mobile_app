// lib/login/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../loginOtp/model/login_otp_route_args.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../repository/auth_repository.dart';
import '../theme/login_theme.dart';
import '../widgets/login_bottom_stripes.dart';
import '../widgets/login_bottom_texts.dart';
import '../widgets/login_header.dart';
import '../widgets/login_password_field.dart';
import '../widgets/login_phone_row.dart';
import '../widgets/login_social_buttons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(repository: LoginRepository()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  // BottomStripes height fixed na hole, eta constant hishebe estimate kore rekho.
  // Better: BottomStripes er vitore exact height const kore expose kora (e.g. BottomStripes.kHeight)
  static const double _bottomStripeHeight = BottomStripes.kHeight;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AuthModuleColors.pageBackground,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AuthModuleColors.pageBackground,

      // ✅ Keyboard উঠলেও body resize হবে না (BottomStripes নড়বে না)
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: BlocListener<LoginBloc, LoginState>(
          listenWhen: (previous, current) {
            final bool loginSuccessChanged = previous.status != current.status && current.status == LoginStatus.success;

            final bool errorToastTriggered = previous.errorToastId != current.errorToastId;

            return loginSuccessChanged || errorToastTriggered;
          },
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              AppToast.show(message: 'OTP sent successfully', type: ToastType.success);

              // Read 2FA key from login state and forward it to OTP route.
              final String? twoFactorKey = state.twoFactorKey;
              if (twoFactorKey == null || twoFactorKey.isEmpty) {
                AppToast.show(
                  message: 'Two-factor key is missing from login response.',
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
                  twoFactorKey: twoFactorKey,
                  phoneNumber: apiPhoneNumber,
                ),
              );
            }
            if (state.status == LoginStatus.failure && state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              AppToast.show(
                message: state.errorMessage.toString(),
                type: ToastType.error,
              );
              //context.push(AppRoutes.loginOtp);
            }
          },
          child: Stack(
            children: [
              // ----------- Main content (scrollable) -----------
              Padding(
                // ✅ stripes overlay করবে, তাই নিচে space reserve করে দিলাম
                padding: const EdgeInsets.only(bottom: _bottomStripeHeight),
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
                            const SizedBox(height: AuthModuleSizes.phoneToPasswordGap),
                            const LoginPasswordField(),
                            const SizedBox(height: AuthModuleSizes.passwordToErrorRowGap),
                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                final hasError = state.status == LoginStatus.failure && state.errorMessage != null;
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
                                            state.errorMessage ?? 'invalid credentials!',
                                            style: AuthModuleTextStyles.invalidCredentials,
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
                                final loading =
                                    state.status == LoginStatus.loading;
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
                            const SizedBox(
                                height: AuthModuleSizes.signInToSocialGap),
                            const LoginSocialButtons(),
                            const SizedBox(
                                height: AuthModuleSizes.socialToBottomGap),
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

              // ----------- Bottom stripes (always pinned) -----------
              const Positioned(
                left: 0,
                right: 0,
                bottom: AuthModuleSizes.bottomTextsBottomOffset,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AuthModuleSizes.bottomTextsHorizontalPadding,
                  ),
                  child: SizedBox(),
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: BottomStripes(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
