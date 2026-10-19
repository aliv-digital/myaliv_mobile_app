import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/constants.dart';
import 'token_session.dart';
import 'token_store.dart';

/// Owns the JWT session: in-memory cache + secure persistence + refresh.
///
/// Single-flight refresh guarantees that N concurrent expired requests
/// coalesce into exactly ONE `/Auth/refresh` network call.
class AuthManager {
  AuthManager({TokenStore? store, Dio? authDio})
      : _store = store ?? TokenStore(),
        _authDio = authDio ?? Dio(BaseOptions(baseUrl: baseUrl));

  final TokenStore _store;

  /// Bare Dio with baseUrl only — no interceptors, no cookies. Used ONLY
  /// for the refresh call so it can't recursively trip the auth interceptor.
  final Dio _authDio;

  TokenSession? _session;
  Future<TokenSession?>? _refreshInFlight;

  TokenSession? get currentSession => _session;

  /// Load persisted session into memory. Call once during app boot,
  /// BEFORE NetworkService is used.
  Future<TokenSession?> loadSession() async {
    _session = await _store.load();
    if (kDebugMode) {
      debugPrint(_session == null
          ? 'AuthManager: no persisted session'
          : 'AuthManager: session loaded (access exp: ${_session!.accessExpiresAt})');
    }
    return _session;
  }

  /// Persist and cache a new session (called after login, OTP verify, or
  /// refresh). Both tokens are replaced on rotation.
  Future<void> saveSession(TokenSession session) async {
    _session = session;
    await _store.save(session);
  }

  /// Wipe everything. Called by the hard-logout path.
  Future<void> clearSession() async {
    _session = null;
    await _store.clear();
  }

  /// Refresh the access token. Single-flight: concurrent callers share
  /// one in-flight refresh future.
  ///
  /// Returns:
  ///  - the new [TokenSession] on success
  ///  - null on hard failure (4xx from the refresh endpoint, malformed
  ///    body, or missing/expired local session) — caller should
  ///    hard-logout
  ///  - the existing (stale) session on transient failure (network down,
  ///    5xx, timeout) — caller should surface a network error to the
  ///    user but MUST NOT hard-logout; the refresh token is still valid
  ///    and the next request will retry
  Future<TokenSession?> refreshIfNeeded() {
    return _refreshInFlight ??=
        _doRefresh().whenComplete(() => _refreshInFlight = null);
  }

  Future<TokenSession?> _doRefresh() async {
    final current = _session;
    if (current == null || current.refreshExpired) return null;
    try {
      final res = await _authDio.post<dynamic>(
        '/v1/MyAliv/Auth/refresh',
        data: {'refresh_token': current.refreshToken},
      );
      final data = res.data;
      if (kDebugMode) {
        // First-run debug aid: exact refresh body so the parser can be
        // confirmed against the real backend without another rebuild.
        // Kansys docs contradict themselves on the success shape.
        debugPrint('REFRESH RAW BODY: $data');
      }
      if (data is! Map<String, dynamic>) {
        if (kDebugMode) {
          debugPrint('AuthManager: refresh returned non-JSON body');
        }
        return null;
      }
      final next = TokenSession.fromLoginJson(data);
      await saveSession(next);
      return next;
    } on FormatException catch (e) {
      // Malformed response body — treat as auth failure.
      if (kDebugMode) debugPrint('AuthManager: refresh parse failed - $e');
      return null;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Transient: network/timeout/5xx → keep the current session so
      // the next attempt can try again. Callers see a network error,
      // NOT session expiry.
      final isTransient = status == null || status >= 500;
      if (kDebugMode) {
        debugPrint(
            'AuthManager: refresh dio error status=$status transient=$isTransient');
      }
      return isTransient ? current : null;
    } catch (e) {
      if (kDebugMode) debugPrint('AuthManager: refresh unexpected error - $e');
      return null;
    }
  }
}
