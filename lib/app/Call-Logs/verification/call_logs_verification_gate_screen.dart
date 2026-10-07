import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import 'call_logs_otp_route_args.dart';
import 'call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';
import 'history_route_observer.dart';

class CallLogsVerificationGateScreen extends StatefulWidget {
  const CallLogsVerificationGateScreen({
    super.key,
    this.repository,
    this.verificationSession,
    this.destination = HistoryDestination.callLogs,
  });

  final CallLogsVerificationRepository? repository;
  final ProtectedAccountAccessVerificationSession? verificationSession;
  final HistoryDestination destination;

  @override
  State<CallLogsVerificationGateScreen> createState() =>
      _CallLogsVerificationGateScreenState();
}

class _CallLogsVerificationGateScreenState
    extends State<CallLogsVerificationGateScreen>
    with RouteAware {
  bool _started = false;
  PageRoute<dynamic>? _route;

  CallLogsVerificationRepository get _repository =>
      widget.repository ?? instance<CallLogsVerificationRepository>();

  ProtectedAccountAccessVerificationSession get _verificationSession =>
      widget.verificationSession ??
      instance<ProtectedAccountAccessVerificationSession>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && !identical(route, _route)) {
      historyRouteObserver.unsubscribe(this);
      _route = route;
      historyRouteObserver.subscribe(this, route);
    }
    _scheduleBegin();
  }

  @override
  void didPopNext() => _scheduleBegin();

  void _scheduleBegin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _started || _route?.isCurrent == false) {
        return;
      }
      _started = true;
      _begin();
    });
  }

  @override
  void dispose() {
    historyRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _begin() async {
    if (_verificationSession.isVerified) {
      _openCallLogs();
      return;
    }

    final generation = _verificationSession.generation;
    try {
      final challenge = await _repository.requestChallenge();
      if (!mounted) return;
      if (_verificationSession.generation != generation) {
        return;
      }
      if (_route?.isCurrent == false) {
        _started = false;
        return;
      }
      context.pushReplacement(
        AppRoutes.callLogsOtp,
        extra: CallLogsOtpRouteArgs(
          mfaToken: challenge.mfaToken,
          apiPhoneNumber: challenge.apiPhoneNumber,
          destination: widget.destination,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      if (_route?.isCurrent == false) {
        _started = false;
        return;
      }
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
    context.pushReplacement(widget.destination.location);
  }

  @override
  Widget build(BuildContext context) {
    return const StripedScaffold(
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}
