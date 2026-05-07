import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../../../resources/widgets/defaultButton.dart';
import '../bloc/forgetPass_otp_bloc.dart';
import '../bloc/forgetPass_otp_event.dart';
import '../bloc/forgetPass_otp_state.dart';


class OtpProfilePrepaidBottomActions extends StatelessWidget {
  const OtpProfilePrepaidBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // verify button
        BlocBuilder<OtpProfilePrepaidBloc, OtpProfilePrepaidState>(
          builder: (context, state) {
            final loading = state.status == OtpProfilePrepaidStatus.loading;

            return DefaultButton(
              label: 'verify',
              isLoading: loading,
              onPressed: () {
                // context
                //     .read<OtpProfilePrepaidBloc>()
                //     .add(const OtpProfilePrepaidSubmitted());

                // TODO: update route if your profile prepaid flow uses another screen
                context.push(AppRoutes.changePasswordPrepaidScreen);
              },
            );
          },
        ),

        const SizedBox(height: 20),

        // didn't receive / resend
        BlocBuilder<OtpProfilePrepaidBloc, OtpProfilePrepaidState>(
          builder: (context, state) {
            final resendLoading =
                state.resendStatus == OtpProfilePrepaidResendStatus.loading;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "didn't receive a code? ",
                  style: TextStyle(
                    color: Color(0xFF121212),
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
                GestureDetector(
                  onTap: resendLoading
                      ? null
                      : () => context
                      .read<OtpProfilePrepaidBloc>()
                      .add(const OtpProfilePrepaidResendRequested()),
                  child: Text(
                    resendLoading ? 'sending...' : 'resend code',
                    style: TextStyle(
                      color: const Color(0xFF645D9C),
                      fontSize: 13,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF645D9C),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 113),

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
        // ),
      ],
    );
  }
}
