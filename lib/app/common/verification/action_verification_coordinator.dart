import 'dart:async';

import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_session_completion_service.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

import 'action_otp_route_args.dart';
import 'action_verified_result.dart';

typedef OpenActionOtp<T extends Object> =
    Future<ActionVerifiedResult<T>?> Function(ActionOtpRouteArgs<T> args);

/// Form/page-scoped verification only. Never performs a payment mutation.
class ActionVerificationCoordinator<T extends Object> {
  ActionVerificationCoordinator({
    CallLogsVerificationRepository? challengeRepository,
    AuthManager? authManager,
    Object? Function()? accountContext,
  }) : _repository =
           challengeRepository ?? instance<CallLogsVerificationRepository>(),
       _auth = authManager ?? instance<AuthManager>(),
       _accountContext = accountContext ?? _currentAccountContext;

  final CallLogsVerificationRepository _repository;
  final AuthManager _auth;
  final Object? Function() _accountContext;
  _AuthorizationAttempt<T>? _pending;

  Future<ActionVerifiedResult<T>?> verifyAction({
    required T purpose,
    required OpenActionOtp<T> openOtp,
    required bool Function() isOwnerActive,
    Object? attemptId,
  }) => verify(
    paymentMethod: purpose,
    openOtp: openOtp,
    isOwnerActive: isOwnerActive,
    attemptId: attemptId,
  );

  static Object? _currentAccountContext() {
    final account = instance<AccountInfoCubit>().state.accountInfo;
    final device = instance<DeviceLimitsCubit>().state.deviceLimits;
    return account == null ? null : (account.idAcc, device?.deviceId);
  }

  Future<ActionVerifiedResult<T>?> verify({
    required T paymentMethod,
    required OpenActionOtp<T> openOtp,
    required bool Function() isOwnerActive,
    Object? attemptId,
  }) async {
    if (_pending != null) {
      return null;
    }
    final context = _accountContext();
    if (context == null || _auth.currentSession == null) {
      throw const CallLogsVerificationException(
        'Your session is unavailable. Please sign in again.',
      );
    }
    final attempt = _AuthorizationAttempt<T>(
      attemptId: attemptId ?? Object(),
      paymentMethod: paymentMethod,
      repository: _repository,
      auth: _auth,
      isContextCurrent: () => isOwnerActive() && _accountContext() == context,
    );
    _pending = attempt;
    try {
      final challenge = await Future.any<CallLogsChallenge?>([
        attempt.resendChallenge(),
        attempt.cancelled.future.then((_) => null),
      ]);
      if (challenge == null || !attempt.isActive) {
        return null;
      }
      final result = await Future.any([
        openOtp(ActionOtpRouteArgs<T>(challenge: challenge, attempt: attempt)),
        attempt.cancelled.future.then<ActionVerifiedResult<T>?>((_) => null),
      ]);
      if (result == null ||
          !attempt.isActive ||
          !identical(result, attempt.verifiedResult)) {
        return null;
      }
      return result;
    } finally {
      attempt.cancel();
      if (identical(_pending, attempt)) {
        _pending = null;
      }
    }
  }

  void cancel() => _pending?.cancel();
}

class _AuthorizationAttempt<T extends Object>
    implements ActionVerificationAttempt<T> {
  _AuthorizationAttempt({
    required this.attemptId,
    required this.paymentMethod,
    required CallLogsVerificationRepository repository,
    required AuthManager auth,
    required bool Function() isContextCurrent,
  }) : challengeRepository = repository,
       _auth = auth,
       _isContextCurrent = isContextCurrent;

  final Object attemptId;
  @override
  final T paymentMethod;
  @override
  final CallLogsVerificationRepository challengeRepository;
  final AuthManager _auth;
  final bool Function() _isContextCurrent;
  final Completer<void> cancelled = Completer<void>();
  Future<CallLogsChallenge>? _challengeInFlight;
  TokenSession? _challengeSession;
  TokenSession? _savedSession;
  ActionVerifiedResult<T>? _result;
  bool _saving = false;

  @override
  bool get isActive =>
      !cancelled.isCompleted &&
      _isContextCurrent() &&
      _auth.currentSession != null;

  @override
  Future<CallLogsChallenge> resendChallenge() {
    if (!isActive || _savedSession != null || _saving) {
      throw const CallLogsVerificationException('Verification was cancelled.');
    }
    return _challengeInFlight ??= _requestChallenge();
  }

  Future<CallLogsChallenge> _requestChallenge() async {
    try {
      final challenge = await challengeRepository.requestChallenge();
      if (!isActive) {
        throw const CallLogsVerificationException(
          'Verification was cancelled.',
        );
      }
      _challengeSession = _auth.currentSession;
      return challenge;
    } finally {
      _challengeInFlight = null;
    }
  }

  @override
  Future<void> completeSession(
    TokenSession session,
    AppUiConfigCubit config,
  ) async {
    if (!isActive ||
        _saving ||
        _savedSession != null ||
        _challengeInFlight != null ||
        !identical(_auth.currentSession, _challengeSession)) {
      throw const CallLogsVerificationException('Verification was cancelled.');
    }
    _saving = true;
    try {
      await CallLogsSessionCompletionService(
        authManager: _auth,
      ).complete(session: session, appUiConfigCubit: config);
      if (!isActive || !identical(_auth.currentSession, session)) {
        throw const CallLogsVerificationException(
          'Verification was cancelled.',
        );
      }
      _savedSession = session;
      _result = ActionVerifiedResult<T>(
        attemptId: attemptId,
        paymentMethod: paymentMethod,
        canConsume: () =>
            _isContextCurrent() &&
            identical(_auth.currentSession, _savedSession),
      );
    } catch (_) {
      // AuthManager may replace its in-memory session before storage fails.
      // No result is issued; a retry must still complete persistence.
      if (isActive) {
        _challengeSession = _auth.currentSession;
      }
      rethrow;
    } finally {
      _saving = false;
    }
  }

  @override
  ActionVerifiedResult<T>? get verifiedResult => isActive ? _result : null;

  @override
  void cancel() {
    if (!cancelled.isCompleted) {
      cancelled.complete();
    }
  }
}
