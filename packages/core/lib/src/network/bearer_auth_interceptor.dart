import 'package:dio/dio.dart';

import '../auth/auth_manager.dart';

/// Injects `Authorization: Bearer` on every request through the shared Dio,
/// proactively refreshes expiring access tokens, and reactively recovers
/// from 401s with a single-flight refresh + one retry.
///
/// [QueuedInterceptor] serializes onRequest handling, so during a refresh
/// all other queued requests wait and then read the NEW token — no
/// thundering herd.
///
/// Bypass rules:
///   - `options.extra['skipAuth'] == true` — auth endpoints set this
///   - `options.uri.host == 'myalivappuat-api.bealiv.com'` — public host
class BearerAuthInterceptor extends QueuedInterceptor {
  BearerAuthInterceptor({
    required this.authManager,
    required this.onHardLogout,
    required this.retryDio,
  });

  final AuthManager authManager;
  final Future<void> Function() onHardLogout;

  /// Bare Dio (no interceptors) used ONLY to retry the original request
  /// after a successful reactive refresh. Must NOT be the intercepted
  /// instance or the retry would recurse into this interceptor.
  final Dio retryDio;

  static const _skipAuthKey = 'skipAuth';
  static const _retriedKey = 'authRetried';
  static const _publicHost = 'myalivappuat-api.bealiv.com';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[_skipAuthKey] == true ||
        options.uri.host == _publicHost) {
      return handler.next(options);
    }

    var session = authManager.currentSession;
    if (session == null) {
      return handler.reject(_sessionExpired(options), true);
    }

    if (session.refreshExpired) {
      await onHardLogout();
      return handler.reject(_sessionExpired(options), true);
    }

    if (session.accessExpired) {
      session = await authManager.refreshIfNeeded();
      if (session == null) {
        await onHardLogout();
        return handler.reject(_sessionExpired(options), true);
      }
    }

    options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthCall = err.requestOptions.extra[_skipAuthKey] == true;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    if (err.response?.statusCode == 401 && !isAuthCall && !alreadyRetried) {
      final session = await authManager.refreshIfNeeded();
      if (session != null) {
        final opts = err.requestOptions;
        opts.extra[_retriedKey] = true;
        opts.headers['Authorization'] = 'Bearer ${session.accessToken}';
        try {
          final response = await retryDio.fetch<dynamic>(opts);
          return handler.resolve(response);
        } catch (_) {
          // fall through to normal error flow
        }
      } else {
        await onHardLogout();
      }
    }
    return handler.next(err);
  }

  DioException _sessionExpired(RequestOptions options) => DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 401,
        ),
      );
}
