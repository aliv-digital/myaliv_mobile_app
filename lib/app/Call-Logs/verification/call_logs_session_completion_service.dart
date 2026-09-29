import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/services/auth_completion_service.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

/// Replaces only the JWT pair after Call Logs verification.
///
/// The normal login completion sequence remains owned by the login flow and is
/// deliberately not rerun for this already-authenticated user.
class CallLogsSessionCompletionService extends AuthCompletionService {
  CallLogsSessionCompletionService({AuthManager? authManager})
      : _authManager = authManager ?? instance<AuthManager>();

  final AuthManager _authManager;

  @override
  Future<void> complete({
    required TokenSession session,
    required AppUiConfigCubit appUiConfigCubit,
  }) {
    return _authManager.saveSession(session);
  }
}
