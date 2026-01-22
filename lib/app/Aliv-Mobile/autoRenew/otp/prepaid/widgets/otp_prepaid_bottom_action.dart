import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import '../../../../../../resources/widgets/defaultButton.dart';
import '../../../../login/theme/login_theme.dart';
import '../bloc/otp_prepaid_bloc.dart';
import '../bloc/otp_prepaid_event.dart';
import '../bloc/otp_prepaid_state.dart';


class OtpAutoRenewPrepaidBottomActions extends StatelessWidget {
  const OtpAutoRenewPrepaidBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width; // (kept as-is for parity)
    // ignore: unused_local_variable
    final _ = width;

    return Column(
      children: [
        // verify button
        BlocBuilder<OtpAutoRenewPrepaidBloc, OtpAutoRenewPrepaidState>(
          builder: (context, state) {
            final loading = state.status == OtpAutoRenewPrepaidStatus.loading;

            return DefaultButton(
              label: 'verify',
              isLoading: loading,
              onPressed: () {
                 context.read<OtpAutoRenewPrepaidBloc>().add(const OtpAutoRenewPrepaidSubmitted());

                // ✅ Update this route if your flow uses another screen
               // context.push(AppRoutes.reviewInvoicePostPaidScreen);
              },
            );
          },
        ),

        const SizedBox(height: 20),

        // didn't receive / resend
        BlocBuilder<OtpAutoRenewPrepaidBloc, OtpAutoRenewPrepaidState>(
          builder: (context, state) {
            final resendLoading =
                state.resendStatus == OtpAutoRenewPrepaidResendStatus.loading;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "didn't receive a code? ",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'CircularPro',
                    height: 1.43,
                    color: AuthModuleColors.textBlack,
                  ),
                ),
                GestureDetector(
                  onTap: resendLoading
                      ? null
                      : () => context
                      .read<OtpAutoRenewPrepaidBloc>()
                      .add(const OtpAutoRenewPrepaidResendRequested()),
                  child: Text(
                    resendLoading ? 'sending...' : 'resend code',
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorManager.textLinkColor,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'CircularPro',
                      height: 1.43,
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 113),

        // change phone number (bottom orange text)
        GestureDetector(
          onTap: () {
            Navigator.of(context).maybePop();
          },
          child: Text(
            'change phone number',
            style: TextStyle(
              fontSize: 14,
              height: 1.43,
              fontFamily: 'CircularPro',
              color: ColorManager.orangeColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
