import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../resources/widgets/defaultButton.dart';
import '../bloc/forget_password_otp_bloc.dart';
import '../bloc/forget_password_otp_event.dart';
import '../bloc/forget_password_otp_state.dart';
import '../theme/forget_password_otp_theme.dart';


class ForgetPasswordOtpBottomActions extends StatelessWidget {
  const ForgetPasswordOtpBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // verify button
        BlocBuilder<ForgetPasswordOtpBloc, ForgetPasswordOtpState>(
          builder: (context, state) {
            final loading = state.status == ForgetPasswordOtpStatus.loading;
            return DefaultButton(
              label: 'verify',
              isLoading: loading,
              onPressed: () {
                context.read<ForgetPasswordOtpBloc>().add(const ForgetPasswordOtpSubmitted());
                context.push(AppRoutes.createPassword);
              },
            );
          },
        ),

        const SizedBox(height: 20),

        // didn't receive / resend
        BlocBuilder<ForgetPasswordOtpBloc, ForgetPasswordOtpState>(
          builder: (context, state) {
            final resendLoading = state.resendStatus == ForgetPasswordOtpResendStatus.loading;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "didn't receive a code? ",
                  style: ForgetPasswordOtpTheme.helperText,
                ),
                GestureDetector(
                  onTap: resendLoading ? null : () => context.read<ForgetPasswordOtpBloc>().add(const ForgetPasswordOtpResendRequested()),
                  child: Text(
                    resendLoading ? 'sending...' : 'resend code',
                    style: ForgetPasswordOtpTheme.resendText,
                  ),
                ),
              ],
            );
          },
        ),

      ],
    );
  }
}
