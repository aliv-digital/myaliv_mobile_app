import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../../../resources/widgets/defaultButton.dart';
import '../../../../login/theme/login_theme.dart';
import '../bloc/otp_postpaid_bloc.dart';
import '../bloc/otp_postpaid_event.dart';
import '../bloc/otp_postpaid_state.dart';

class OTPPostpaidBottomActions extends StatelessWidget {
  const OTPPostpaidBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width; // (kept as-is for parity)
    // ignore: unused_local_variable
    final _ = width;

    return Column(
      children: [
        // verify button
        BlocBuilder<OTPPostpaidBloc, OTPPostpaidState>(
          builder: (context, state) {
            final loading = state.status == OTPPostpaidStatus.loading;

            return DefaultButton(
              label: 'verify',
              isLoading: loading,
              onPressed: () {
               // context.read<OTPPostpaidBloc>().add(const OTPPostpaidSubmitted());


                // ✅ Update this route if your postpaid flow uses another screen
                context.push(AppRoutes.reviewInvoicePostPaidScreen);
              },
            );
          },
        ),

        const SizedBox(height: 20),

        // didn't receive / resend
        BlocBuilder<OTPPostpaidBloc, OTPPostpaidState>(
          builder: (context, state) {
            final resendLoading =
                state.resendStatus == OTPPostpaidResendStatus.loading;

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
                      .read<OTPPostpaidBloc>()
                      .add(const OTPPostpaidResendRequested()),
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
