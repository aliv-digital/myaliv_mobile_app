import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import '../../../../router/app_routes.dart';
import '../../login/widgets/login_bottom_stripes.dart';
import '../bloc/login_otp_bloc.dart';
import '../bloc/login_otp_state.dart';
import '../repository/login_otp_repository.dart';
import '../theme/login_otp_theme.dart';
import '../widgets/otp_header.dart';
import '../widgets/otp_code_fields.dart';
import '../widgets/otp_bottom_actions.dart';

class LoginOtpScreen extends StatelessWidget {
  const LoginOtpScreen({
    super.key,
    this.initialTwoFactorKey = '',
    this.initialPhoneNumber = '',
    this.initialApiPhoneNumber = '',
  });

  /// Two-factor key passed from login route.
  final String initialTwoFactorKey;

  /// Phone number passed from login route.
  final String initialPhoneNumber;

  /// API-formatted phone number used for OTP verify/resend requests.
  final String initialApiPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Seed OTP bloc state with route-provided twoFactorKey.
      create: (context) => LoginOtpBloc(
        repository: LoginOtpRepository(),
        appUiConfigCubit: context.read<AppUiConfigCubit>(),
        initialTwoFactorKey: initialTwoFactorKey,
        initialPhoneNumber: initialPhoneNumber,
        initialApiPhoneNumber: initialApiPhoneNumber,
      ),
      child: const _LoginOtpView(),
    );
  }
}

class _LoginOtpView extends StatelessWidget {
  const _LoginOtpView();

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: LoginOtpColors.screenBackground,

      // ✅ Default behavior back (keyboard উঠলে body resize হবে + auto scroll works)
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: BlocListener<LoginOtpBloc, LoginOtpState>(
          listenWhen: (previous, current) {
            return previous.status != current.status ||
                previous.resendStatus != current.resendStatus ||
                previous.errorMessage != current.errorMessage;
          },
          listener: (context, state) {
            if (state.status == LoginOtpStatus.success) {
              AppToast.show(
                message: 'OTP verified successfully',
                type: ToastType.success,
              );
              context.go(AppRoutes.home);
            }

            if (state.status == LoginOtpStatus.failure &&
                state.errorMessage != null) {
              AppToast.show(
                message: state.errorMessage!,
                type: ToastType.error,
              );
            }

            if (state.resendStatus == LoginOtpResendStatus.done) {
              AppToast.show(
                message: 'Verification code resent successfully.',
                type: ToastType.success,
              );
            }

            if (state.resendStatus == LoginOtpResendStatus.idle &&
                state.status != LoginOtpStatus.failure &&
                state.errorMessage != null) {
              AppToast.show(
                message: state.errorMessage!,
                type: ToastType.error,
              );
            }
          },
          child: Stack(
            children: [
              Column(
                children: [
                  // ---------- Scrollable content ----------
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      slivers: [
                        const SliverToBoxAdapter(child: OtpHeader()),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: LoginOtpPaddings.contentHorizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: LoginOtpSizes.contentTopGap),
                                OtpCodeFields(),
                                SizedBox(
                                  height: LoginOtpSizes.otpToBottomActionsGap,
                                ),
                                OtpBottomActions(),
                                SizedBox(
                                  height: LoginOtpSizes.contentBottomGap,
                                ),
                                _ChangePhoneNumberAction(),
                                // ElevatedButton(
                                //     onPressed: (){
                                //       context.read<LoginOtpBloc>().add(PrintStorage());
                                //     },
                                //     child: Text("print storage")
                                // ),
                                SizedBox(height: 113),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Bottom stripes will VANISH when keyboard opens (no moving up)
                  AnimatedSwitcher(
                    duration: LoginOtpMotion.stripeSwitcherDuration,
                    switchInCurve: LoginOtpMotion.stripeSwitcherInCurve,
                    switchOutCurve: LoginOtpMotion.stripeSwitcherOutCurve,
                    child: keyboardOpen
                        ? const SizedBox.shrink()
                        : const BottomStripes(),
                  ),
                ],
              ),

              // if (!keyboardOpen)
              //   const Positioned(
              //     left: 0,
              //     right: 0,
              //     bottom: BottomStripes.kHeight + LoginOtpSizes.changePhoneBottomOffset,
              //     child: _ChangePhoneNumberAction(),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangePhoneNumberAction extends StatelessWidget {
  const _ChangePhoneNumberAction();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Text(
        'change phone number',
        textAlign: TextAlign.center,
        style: LoginOtpTheme.changePhoneText,
      ),
    );
  }
}
