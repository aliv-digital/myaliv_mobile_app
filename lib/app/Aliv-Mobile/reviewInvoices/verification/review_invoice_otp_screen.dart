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

import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_otp_repository.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_access_session_completion_service.dart';
import 'review_invoice_verification_repository.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';

class ReviewInvoiceOtpScreen extends StatelessWidget {
  const ReviewInvoiceOtpScreen({
    super.key,
    required this.initialMfaToken,
    required this.apiPhoneNumber,
  });

  final String initialMfaToken;
  final String apiPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginOtpBloc(
        repository: CallLogsOtpRepository(
          verificationRepository:
              instance<ReviewInvoiceVerificationRepository>(),
        ),
        appUiConfigCubit: context.read<AppUiConfigCubit>(),
        authCompletionService: ProtectedAccessSessionCompletionService(),
        analyticsService: _ReviewInvoiceNoOpAnalyticsService(),
        initialMfaToken: initialMfaToken,
        initialPhoneNumber: apiPhoneNumber,
        initialApiPhoneNumber: apiPhoneNumber,
        preventDuplicateSubmissions: true,
        offlineVerificationMessage:
            "We couldn't verify the OTP due to a network error. Please try again later",
      ),
      child: const _ReviewInvoiceOtpView(),
    );
  }
}

class _ReviewInvoiceOtpView extends StatefulWidget {
  const _ReviewInvoiceOtpView();

  @override
  State<_ReviewInvoiceOtpView> createState() => _ReviewInvoiceOtpViewState();
}

class _ReviewInvoiceOtpViewState extends State<_ReviewInvoiceOtpView> {
  late final ProtectedAccountAccessVerificationSession _session;
  late final int _generation;

  @override
  void initState() {
    super.initState();
    _session = instance<ProtectedAccountAccessVerificationSession>();
    _generation = _session.generation;
  }

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
              if (!mounted ||
                  ModalRoute.of(context)?.isCurrent != true ||
                  _session.generation != _generation) {
                return;
              }
              // LoginOtpBloc emits success only after saveSession completes.
              AppToast.show(
                message: 'Verification successful.',
                type: ToastType.success,
              );
              context.pushReplacement(AppRoutes.reviewInvoicePostPaidScreen);
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

class _ReviewInvoiceNoOpAnalyticsService extends AnalyticsService {
  @override
  Future<void> logLogin() async {}
}
