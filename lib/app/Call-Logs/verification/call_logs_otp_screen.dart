import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/theme/login_otp_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_bottom_actions.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_header.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import 'call_logs_otp_repository.dart';
import 'call_logs_otp_route_args.dart';
import 'call_logs_session_completion_service.dart';
import 'call_logs_verification_repository.dart';
import 'call_logs_verification_session.dart';

class CallLogsOtpScreen extends StatelessWidget {
  const CallLogsOtpScreen({
    super.key,
    required this.initialMfaToken,
    required this.apiPhoneNumber,
    this.destination = HistoryDestination.callLogs,
  });

  final String initialMfaToken;
  final String apiPhoneNumber;
  final HistoryDestination destination;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginOtpBloc(
        repository: CallLogsOtpRepository(
          verificationRepository: instance<CallLogsVerificationRepository>(),
        ),
        appUiConfigCubit: context.read<AppUiConfigCubit>(),
        authCompletionService: CallLogsSessionCompletionService(),
        analyticsService: _CallLogsNoOpAnalyticsService(),
        initialMfaToken: initialMfaToken,
        initialPhoneNumber: apiPhoneNumber,
        initialApiPhoneNumber: apiPhoneNumber,
        preventDuplicateSubmissions: true,
        offlineVerificationMessage:
            "We couldn't verify the OTP due to a network error. Please try again later",
      ),
      child: _CallLogsOtpView(destination: destination),
    );
  }
}

class _CallLogsOtpView extends StatelessWidget {
  const _CallLogsOtpView({required this.destination});

  final HistoryDestination destination;

  @override
  Widget build(BuildContext context) {
    return StripedScaffold(
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
              if (ModalRoute.of(context)?.isCurrent == false) {
                return;
              }
              instance<CallLogsVerificationSession>().markVerified();
              AppToast.show(
                message: 'Verification successful.',
                type: ToastType.success,
              );
              context.pushReplacement(destination.location);
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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      SizedBox(height: LoginOtpSizes.otpToBottomActionsGap),
                      OtpBottomActions(),
                      SizedBox(height: 198),
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

class _CallLogsNoOpAnalyticsService extends AnalyticsService {
  @override
  Future<void> logLogin() async {}
}
