import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:myaliv_mobile_app/core/auth/hard_logout.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class LogoutRepository {
  LogoutRepository({
    NetworkService? networkService,
    AuthManager? authManager,
    Future<void> Function()? performLocalLogout,
  }) : _network = networkService ?? instance<NetworkService>(),
       _authManager = authManager ?? instance<AuthManager>(),
       _performLocalLogout = performLocalLogout ?? performHardLogout;

  final NetworkService _network;
  final AuthManager _authManager;
  final Future<void> Function() _performLocalLogout;

  /// Calls the selected logout API, then always clears the local session.
  /// Server errors are ignored so the user can still leave the app safely.
  Future<bool> logout({bool logoutAllDevices = false}) async {
    final session = _authManager.currentSession;

    if (session != null) {
      try {
        if (logoutAllDevices) {
          await _logoutAllDevices();
        } else {
          await _logoutCurrentDevice(session.accessToken);
        }
      } catch (e) {
        // Server-side revocation is best-effort — local logout must
        // proceed even if the network call fails so users don't get
        // stuck with a dead session they can't clear.
        if (kDebugMode) {
          debugPrint('Logout API call failed (ignoring): $e');
        }
      }
    }

    await _performLocalLogout();
    return true;
  }

  Future<void> _logoutAllDevices() async {
    // This is a normal authenticated request. The bearer interceptor adds
    // the Authorization header and, after a 401, refreshes the token and
    // retries this request once.
    await _network.request<dynamic>(
      Api.logoutAllDevicesUrl,
      method: HttpMethod.post,
    );
  }

  Future<void> _logoutCurrentDevice(String accessToken) async {
    // The existing single-device endpoint receives its token in the body.
    // skipAuth preserves its current behavior and avoids bearer refresh.
    await _network.request<dynamic>(
      Api.logOutUrl,
      method: HttpMethod.post,
      data: {'access_token': accessToken},
      options: Options(extra: {'skipAuth': true}),
    );
  }
}
