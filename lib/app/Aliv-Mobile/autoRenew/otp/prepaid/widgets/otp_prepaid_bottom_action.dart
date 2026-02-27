import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/home/home_screen.dart';
import '../../../../../../core/utils/app_session.dart';
import '../../../../../../resources/widgets/defaultButton.dart';
import '../../../../../../resources/widgets/top_toast.dart';
import '../../../../../../router/app_routes.dart';
import '../bloc/otp_prepaid_bloc.dart';
import '../bloc/otp_prepaid_event.dart';
import '../bloc/otp_prepaid_state.dart';
import '../theme/otp_prepaid_theme.dart';

class OtpAutoRenewPrepaidBottomActions extends StatelessWidget {
  const OtpAutoRenewPrepaidBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // verify button
        BlocBuilder<OtpAutoRenewPrepaidBloc, OtpAutoRenewPrepaidState>(
          builder: (context, state) {
            final loading = state.status == OtpAutoRenewPrepaidStatus.loading;

            return DefaultButton(
              label: 'verify',
              isLoading: loading,
              height: OtpAutoRenewPrepaidTheme.verifyButtonHeight,
              elevation: OtpAutoRenewPrepaidTheme.verifyButtonElevation,
              backgroundColor:
                  OtpAutoRenewPrepaidTheme.verifyButtonBackgroundColor,
              borderRadius: OtpAutoRenewPrepaidTheme.verifyButtonBorderRadius,
              textStyle: OtpAutoRenewPrepaidTheme.verifyButtonTextStyle,
              onPressed: () {
                // context.read<OtpAutoRenewPrepaidBloc>().add(const OtpAutoRenewPrepaidSubmitted());
                if (config.isPostpaid == true) {
                  AppToast.show(
                    message: "Success! Your card is now set for auto renew",
                    type: ToastType.success,
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Future.delayed(const Duration(seconds: 1), () {
                      if (context.mounted) {
                        context.go(AppRoutes.home);
                      }
                    });
                  });
                }
                if (config.isPrepaid == true) {
                  if (AppSession.appRoute == 'autoTopUp') {
                    AppToast.show(
                      message: "auto top-up successfully started",
                      type: ToastType.success,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Future.delayed(const Duration(seconds: 1), () {
                        if (context.mounted) {
                          AppSession.resetAppRoute();
                          // context.go(AppRoutes.purchasesPrepaidScreen);
                          context.pop();
                          context.pop();
                          context.pop();
                        }
                      });
                    });
                  } else {
                    AppToast.show(
                      message:
                          "We’re working on it! Auto renew takes a few minutes to update. Thank you for your patience.",
                      type: ToastType.success,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Future.delayed(const Duration(seconds: 1), () {
                        if (context.mounted) {
                          context.go(AppRoutes.home);
                        }
                      });
                    });
                  }
                }

                // ✅ Update this route if your flow uses another screen
              },
            );
          },
        ),

        const SizedBox(
          height: OtpAutoRenewPrepaidTheme.verifyButtonToResendRowGap,
        ),

        // didn't receive / resend
        BlocBuilder<OtpAutoRenewPrepaidBloc, OtpAutoRenewPrepaidState>(
          builder: (context, state) {
            final resendLoading =
                state.resendStatus == OtpAutoRenewPrepaidResendStatus.loading;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'didn\'t receive a code?',
                  textAlign: TextAlign.center,
                  style: OtpAutoRenewPrepaidTheme.resendPromptTextStyle,
                ),
                const SizedBox(
                  width: OtpAutoRenewPrepaidTheme.resendPromptToActionGap,
                ),
                GestureDetector(
                  onTap: resendLoading
                      ? null
                      : () => context.read<OtpAutoRenewPrepaidBloc>().add(
                          const OtpAutoRenewPrepaidResendRequested(),
                        ),
                  child: Text(
                    resendLoading ? 'sending...' : 'resend code',
                    style: OtpAutoRenewPrepaidTheme.resendActionTextStyle,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: OtpAutoRenewPrepaidTheme.resendRowToBottomGap),

        // change phone number (bottom orange text)
        // GestureDetector(
        //   onTap: () {
        //     Navigator.of(context).maybePop();
        //   },
        //   child: Text(
        //     'change phone number',
        //     style: TextStyle(
        //       fontSize: 14,
        //       height: 1.43,
        //       fontFamily: 'CircularPro',
        //       color: ColorManager.orangeColor,
        //       fontWeight: FontWeight.w500,
        //     ),
        //   ),
        //),
      ],
    );
  }
}
