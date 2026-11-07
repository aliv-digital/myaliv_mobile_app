/// Enhanced Network Service with better architecture
///
/// This file contains the main NetworkService class.
/// Responsible for: HTTP requests, service orchestration, and lifecycle management.
library;

import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'bearer_auth_interceptor.dart';
import 'network_interceptors.dart';

/// Main network service for making HTTP requests
///
/// This is a singleton service that handles all network operations including:
/// - HTTP requests (GET, POST, PUT, DELETE, PATCH)
/// - Cookie management (session persistence)
/// - JWT Bearer token injection + refresh via [BearerAuthInterceptor]
/// - Request cancellation
/// - Progress tracking
/// - Error handling
class NetworkService {
  NetworkService({
    required this.authManager,
    required this.onHardLogout,
  });

  final AuthManager authManager;
  final Future<void> Function() onHardLogout;

  late Dio _dio;
  late PersistCookieJar _cookieJar;
  late NetworkConfig _config;
  bool _initialized = false;

  final Map<String, CancelToken> _cancelTokens = {};

  /// Initialize the network service.
  ///
  /// Call order in CoreInjection:
  /// 1. AuthManager.loadSession() — loads persisted tokens
  /// 2. NetworkService.init() — reads session lazily via the interceptor
  Future<void> init() async {
    if (_initialized) {
      debugPrint('⚠️ NetworkService already initialized');
      return;
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final cookiePath = '${appDocDir.path}/.cookies/';
    _cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(cookiePath),
    );

    _config = const NetworkConfig(baseUrl: baseUrl);

    final baseOptions = BaseOptions(
      baseUrl: _config.baseUrl,
      connectTimeout: _config.connectTimeout,
      receiveTimeout: _config.receiveTimeout,
      contentType: 'application/json',
      headers: {
        'Accept': 'application/json',
        'Cache-Control': 'no-cache',
      },
    );

    _dio = Dio(baseOptions);

    // Retry Dio used ONLY by BearerAuthInterceptor to replay an original
    // request after a reactive refresh. Must NOT share interceptors.
    final retryDio = Dio(baseOptions);

    _setupInterceptors(retryDio);

    _initialized = true;
    debugPrint('✅ NetworkService initialized');
  }

  /// Setup all interceptors. Order matters:
  ///   CookieManager → BearerAuthInterceptor → Logging
  void _setupInterceptors(Dio retryDio) {
    _dio.interceptors.add(CookieManager(_cookieJar));

    _dio.interceptors.add(
      BearerAuthInterceptor(
        authManager: authManager,
        onHardLogout: onHardLogout,
        retryDio: retryDio,
      ),
    );

    if (_config.enableLogging && kDebugMode) {
      _dio.interceptors
          .add(NetworkLoggingInterceptor(config: _config.logConfig));
    }
  }

  static const int _maxRetryAttempts = 3;

  /// Make HTTP request with automatic error handling.
  ///
  /// Automatically retries up to [_maxRetryAttempts] times on timeout with
  /// exponential backoff (1 s, 2 s). All other errors are thrown immediately.
  Future<Response<T>> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    String? requestId,
  }) async {
    if (!_initialized) {
      throw NetworkException('NetworkService not initialized');
    }

    if (kDebugMode) {
      debugPrint('🔵 NetworkService.request() called: [$method] $path');
    }

    final token =
        cancelToken ?? (requestId != null ? _getCancelToken(requestId) : null);

    // Only retry idempotent methods — POST/PUT/PATCH may mutate server state
    // before the timeout fires, so retrying them risks double-submission.
    final canRetry = method == HttpMethod.get;
    final maxAttempts = canRetry ? _maxRetryAttempts : 1;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _dispatchRequest<T>(
          path,
          method: method,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: token,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );

        if (requestId != null) _cancelTokens.remove(requestId);
        return response;
      } on DioException catch (e) {
        final isTimeout = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout;

        if (isTimeout && attempt < maxAttempts) {
          final delay = Duration(seconds: 1 << (attempt - 1));
          if (kDebugMode) {
            debugPrint(
              '⏳ NetworkService: Timeout on attempt $attempt/$maxAttempts'
              ' [$method] $path — retrying in ${delay.inSeconds}s…',
            );
          }
          await Future.delayed(delay);
          continue;
        }

        if (requestId != null) _cancelTokens.remove(requestId);
        throw _handleDioException(e);
      } catch (e) {
        if (requestId != null) _cancelTokens.remove(requestId);
        throw NetworkException('Unexpected error: $e');
      }
    }

    throw StateError('unreachable');
  }

  Future<Response<T>> _dispatchRequest<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    switch (method) {
      case HttpMethod.get:
        return _dio.get<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        );

      case HttpMethod.post:
        return _dio.post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );

      case HttpMethod.put:
        return _dio.put<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );

      case HttpMethod.delete:
        return _dio.delete<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        );

      case HttpMethod.patch:
        return _dio.patch<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
    }
  }

  /// Upload file with multipart/form-data
  Future<Response> upload(
    String path, {
    required Map<String, dynamic> data,
    List<MapEntry<String, MultipartFile>>? files,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
    String? requestId,
  }) async {
    final formData = FormData();

    data.forEach((key, value) {
      formData.fields.add(MapEntry(key, value.toString()));
    });

    if (files != null) {
      formData.files.addAll(files);
    }

    return request(
      path,
      method: HttpMethod.post,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onProgress,
      cancelToken: cancelToken,
      requestId: requestId,
    );
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
    String? requestId,
  }) async {
    final token =
        cancelToken ?? (requestId != null ? _getCancelToken(requestId) : null);

    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onProgress,
        cancelToken: token,
      );

      if (requestId != null) {
        _cancelTokens.remove(requestId);
      }

      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  CancelToken _getCancelToken(String requestId) {
    return _cancelTokens.putIfAbsent(requestId, () => CancelToken());
  }

  void cancelRequest(String requestId, [String? reason]) {
    final token = _cancelTokens[requestId];
    if (token != null && !token.isCancelled) {
      token.cancel(reason ?? 'Request cancelled');
      _cancelTokens.remove(requestId);
      debugPrint('🚫 Request cancelled: $requestId');
    }
  }

  void cancelAllRequests([String? reason]) {
    for (final entry in _cancelTokens.entries) {
      if (!entry.value.isCancelled) {
        entry.value.cancel(reason ?? 'All requests cancelled');
      }
    }
    _cancelTokens.clear();
    debugPrint('🚫 All requests cancelled');
  }

  NetworkException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);

        if (statusCode == 401) {
          // Auth endpoints (login, refresh) set skipAuth: true. A 401 there
          // is bad credentials, not session expiry — preserve the body so
          // the caller can surface the real backend error code.
          final skipAuth = error.requestOptions.extra['skipAuth'] == true;
          if (skipAuth) {
            return NetworkException(
              message,
              statusCode: statusCode,
              data: error.response?.data,
            );
          }
          return SessionExpiredException();
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(
            message,
            statusCode: statusCode,
            data: error.response?.data,
          );
        } else {
          return NetworkException(
            message,
            statusCode: statusCode,
            data: error.response?.data,
          );
        }

      case DioExceptionType.cancel:
        return NetworkException('Request cancelled');

      case DioExceptionType.connectionError:
        final cause = error.error;
        if (cause is SocketException &&
            cause.message.contains('Failed host lookup')) {
          return HostUnreachableException();
        }
        return NoInternetException();

      case DioExceptionType.badCertificate:
        return NetworkException('SSL certificate error');

      case DioExceptionType.unknown:
        return NetworkException(
          error.message ?? 'Unknown error occurred',
          statusCode: error.response?.statusCode,
        );
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'An error occurred';

    if (data is String) {
      try {
        final parsed = jsonDecode(data);
        if (parsed is Map) {
          return _extractMessageFromMap(parsed);
        }
        return data;
      } catch (_) {
        return data;
      }
    }

    if (data is Map) {
      return _extractMessageFromMap(data);
    }

    return 'An error occurred';
  }

  String _extractMessageFromMap(Map<dynamic, dynamic> data) {
    final message = data['Message'] ??
        data['message'] ??
        data['Error'] ??
        data['error'] ??
        data['msg'] ??
        data['Detail'] ??
        data['detail'];
    return message?.toString() ?? 'An error occurred';
  }

  /// Clear all cookies
  Future<void> clearCookies() async {
    if (!_initialized) return;
    await _cookieJar.deleteAll();
    debugPrint('🍪 All cookies cleared');
  }

  Dio get dio {
    if (!_initialized) {
      throw NetworkException(
          'NetworkService not initialized. Call init() first.');
    }
    return _dio;
  }

  PersistCookieJar get cookieJar {
    if (!_initialized) {
      throw NetworkException(
          'NetworkService not initialized. Call init() first.');
    }
    return _cookieJar;
  }

  bool get isInitialized => _initialized;
}
