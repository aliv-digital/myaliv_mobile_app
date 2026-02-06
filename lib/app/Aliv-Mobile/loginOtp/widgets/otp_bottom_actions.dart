import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../resources/widgets/defaultButton.dart';
import '../bloc/login_otp_bloc.dart';
import '../bloc/login_otp_state.dart';
import '../bloc/login_otp_event.dart';
import '../theme/login_otp_theme.dart';

class OtpBottomActions extends StatelessWidget {
  const OtpBottomActions({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        // verify button
        BlocBuilder<LoginOtpBloc, LoginOtpState>(
          builder: (context, state) {
            final loading = state.status == LoginOtpStatus.loading;
            return DefaultButton(
              label: 'verify',
              isLoading: loading,
              onPressed: () {
               context.read<LoginOtpBloc>().add(const LoginOtpSubmitted());
              },
            );
          },
        ),

        const SizedBox(height: 20),

        // didn't receive / resend
        BlocBuilder<LoginOtpBloc, LoginOtpState>(
          builder: (context, state) {
            final resendLoading = state.resendStatus == LoginOtpResendStatus.loading;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "didn't receive a code? ",
                  style: LoginOtpTheme.helperText,
                ),
                GestureDetector(
                  onTap: resendLoading ? null : () => context.read<LoginOtpBloc>().add(const LoginOtpResendRequested()),
                  child: Text(
                    resendLoading ? 'sending...' : 'resend code',
                    style: LoginOtpTheme.resendText,
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
