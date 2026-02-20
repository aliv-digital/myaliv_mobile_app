import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
                AppToast.show(
                  message: "Success! Your card is now set for auto renew",
                  type: ToastType.success,
                );
                context.go(AppRoutes.home);

                // ✅ Update this route if your flow uses another screen
              },
            );
          },
        ),

        const SizedBox(
            height: OtpAutoRenewPrepaidTheme.verifyButtonToResendRowGap),

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
                    width: OtpAutoRenewPrepaidTheme.resendPromptToActionGap),
                GestureDetector(
                  onTap: resendLoading
                      ? null
                      : () => context
                          .read<OtpAutoRenewPrepaidBloc>()
                          .add(const OtpAutoRenewPrepaidResendRequested()),
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
