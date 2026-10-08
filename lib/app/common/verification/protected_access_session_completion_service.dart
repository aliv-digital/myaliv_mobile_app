import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/services/auth_completion_service.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

import 'protected_account_access_verification_session.dart';

/// Policy A only. Policy B continues using its one-use action completion.
class ProtectedAccessSessionCompletionService extends AuthCompletionService {
  ProtectedAccessSessionCompletionService({
    AuthManager? authManager,
    ProtectedAccountAccessVerificationSession? accessSession,
  }) : _auth = authManager ?? instance<AuthManager>(),
       _access =
           accessSession ??
           instance<ProtectedAccountAccessVerificationSession>() {
    _generation = _access.generation;
  }

  final AuthManager _auth;
  final ProtectedAccountAccessVerificationSession _access;
  late final int _generation;

  @override
  Future<void> complete({
    required TokenSession session,
    required AppUiConfigCubit appUiConfigCubit,
  }) async {
    if (_access.generation != _generation) {
      throw StateError('Verification was cancelled.');
    }
    await _auth.saveSession(session);
    if (!_access.markVerified(expectedGeneration: _generation)) {
      throw StateError('Verification was cancelled.');
    }
  }
}
