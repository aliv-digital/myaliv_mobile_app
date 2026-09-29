import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import 'call_logs_otp_route_args.dart';
import 'call_logs_verification_repository.dart';
import 'call_logs_verification_session.dart';

class CallLogsVerificationGateScreen extends StatefulWidget {
  const CallLogsVerificationGateScreen({
    super.key,
    this.repository,
    this.verificationSession,
  });

  final CallLogsVerificationRepository? repository;
  final CallLogsVerificationSession? verificationSession;

  @override
  State<CallLogsVerificationGateScreen> createState() =>
      _CallLogsVerificationGateScreenState();
}

class _CallLogsVerificationGateScreenState
    extends State<CallLogsVerificationGateScreen> {
  bool _started = false;

  CallLogsVerificationRepository get _repository =>
      widget.repository ?? instance<CallLogsVerificationRepository>();

  CallLogsVerificationSession get _verificationSession =>
      widget.verificationSession ?? instance<CallLogsVerificationSession>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  Future<void> _begin() async {
    if (_verificationSession.isVerified) {
      _openCallLogs();
      return;
    }

    try {
      final challenge = await _repository.requestChallenge();
      if (!mounted) return;
      context.pushReplacement(
        AppRoutes.callLogsOtp,
        extra: CallLogsOtpRouteArgs(
          mfaToken: challenge.mfaToken,
          apiPhoneNumber: challenge.apiPhoneNumber,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      AppToast.show(message: error.toString(), type: ToastType.error);
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  void _openCallLogs() {
    if (!mounted) return;
    context.pushReplacement('${AppRoutes.callLogs}?tab=call_logs');
  }

  @override
  Widget build(BuildContext context) {
    return const StripedScaffold(
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}
