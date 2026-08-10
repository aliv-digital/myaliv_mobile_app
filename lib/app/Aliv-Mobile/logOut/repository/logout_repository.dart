import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:myaliv_mobile_app/core/auth/hard_logout.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class LogoutRepository {
  LogoutRepository({NetworkService? networkService})
      : _network = networkService ?? instance<NetworkService>();

  final NetworkService _network;

  /// Ends the session:
  ///   1. POST /Auth/logout { access_token }  (best-effort; ignore failures)
  ///   2. Run the shared hard-logout sequence (clears secure storage,
  ///      cubits, cookies; navigates to welcome).
  ///
  /// Marks the request `skipAuth` so the bearer interceptor doesn't try
  /// to inject/refresh a token that's about to be discarded anyway.
  Future<bool> logout() async {
    final session = instance<AuthManager>().currentSession;

    if (session != null) {
      try {
        await _network.request<dynamic>(
          Api.logOutUrl,
          method: HttpMethod.post,
          data: {'access_token': session.accessToken},
          options: Options(extra: {'skipAuth': true}),
        );
      } catch (e) {
        // Server-side revocation is best-effort — local logout must
        // proceed even if the network call fails so users don't get
        // stuck with a dead session they can't clear.
        if (kDebugMode) debugPrint('Logout API call failed (ignoring): $e');
      }
    }

    await performHardLogout();
    return true;
  }
}
