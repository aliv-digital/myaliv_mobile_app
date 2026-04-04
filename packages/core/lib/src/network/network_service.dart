/// Enhanced Network Service with better architecture
///
/// This file contains the main NetworkService class.
/// Responsible for: HTTP requests, service orchestration, and lifecycle management.
library;

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'network_config.dart';
import 'network_exceptions.dart';
import 'network_types.dart';
import 'network_interceptors.dart';

/// Main network service for making HTTP requests
///
/// This is a singleton service that handles all network operations including:
/// - HTTP requests (GET, POST, PUT, DELETE, PATCH)
/// - Cookie management (session persistence)
/// - Authentication token injection
/// - Session expiration handling
/// - Request cancellation
/// - Progress tracking
/// - Error handling
class NetworkService {
  /// Clean constructor - init() must be called explicitly after AuthManager loads credentials
  NetworkService();

  late Dio _dio;
  late PersistCookieJar _cookieJar;
  late NetworkConfig _config;
  NetworkCallbacks? _callbacks;
  bool _initialized = false;

  // Interceptor handlers
  late NetworkInterceptorHandlers _interceptorHandlers;

  // Cancel tokens for request cancellation
  final Map<String, CancelToken> _cancelTokens = {};

  /// Initialize the network service
  ///
  /// ⚠️ IMPORTANT: Must be called AFTER AuthManager.loadAuthFromStorage()
  /// This ensures credentials are available in GlobalState before initialization.
  ///
  /// Call order in CoreInjection:
  /// 1. AuthManager.loadAuthFromStorage() → loads auth to GlobalState
  /// 2. NetworkService.init() → reads auth from GlobalState
  ///
  /// Example:
  /// ```dart
  /// final authManager = AuthManager();
  /// await authManager.loadAuthFromStorage(...);
  /// final networkService = NetworkService();
  /// await networkService.init();
  /// ```
  Future<void> init() async {
    if (_initialized) {
      debugPrint('⚠️ NetworkService already initialized');
      return;
    }

    // ========== 1. Initialize Cookie Jar (FIX: Was missing!) ==========
    final appDocDir = await getApplicationDocumentsDirectory();
    final cookiePath = '${appDocDir.path}/.cookies/';
    _cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(cookiePath),
    );

    // ========== 2. Build Config with Auth from GlobalState ==========
    final authToken = globalState.basicAuthToken;

    _config = NetworkConfig(
      baseUrl: baseUrl,
      headers: authToken != null
          ? {'Authorization': 'Basic $authToken'}
          : {}, // No auth for guest/unauthenticated users
    );

    if (kDebugMode) {
      debugPrint('NetworkService: Auth headers ${authToken != null ? "SET ✅" : "NOT SET ⚠️"}');
      debugPrint('NetworkService: Config - baseUrl=${_config.baseUrl}, enableLogging=${_config.enableLogging}');
    }

    _interceptorHandlers = NetworkInterceptorHandlers();

    // ========== 3. Configure Dio ==========
    _dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl,
        connectTimeout: _config.connectTimeout,
        receiveTimeout: _config.receiveTimeout,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
          ..._config.headers ?? {},
        },
      ),
    );

    // ========== 4. Add Interceptors ==========
    _setupInterceptors();

    _initialized = true;
    debugPrint('✅ NetworkService initialized');
  }

  /// Update auth headers after login (without full re-init)
  ///
  /// Call this after AuthManager.saveAuth() to update NetworkService
  /// with new credentials without reinitializing the entire service.
  void updateAuthHeaders() {
    if (!_initialized) {
      debugPrint('⚠️ NetworkService not initialized, cannot update headers');
      return;
    }

    final authToken = globalState.basicAuthToken;

    if (authToken != null) {
      _dio.options.headers['Authorization'] = 'Basic $authToken';
      if (kDebugMode) {
        debugPrint('✅ NetworkService: Auth headers updated');
      }
    } else {
      _dio.options.headers.remove('Authorization');
      if (kDebugMode) {
        debugPrint('⚠️ NetworkService: Auth headers removed (no auth in GlobalState)');
      }
    }
  }

  /// Clear auth headers (logout)
  ///
  /// Call this during logout to remove authentication from NetworkService.
  void clearAuthHeaders() {
    if (!_initialized) return;

    _dio.options.headers.remove('Authorization');
    if (kDebugMode) {
      debugPrint('🗑️ NetworkService: Auth headers cleared');
    }
  }

  /// Setup all interceptors
  void _setupInterceptors() {
    // Cookie manager
    _dio.interceptors.add(CookieManager(_cookieJar));

    // Auth and session interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _interceptorHandlers.handleRequest,
        onResponse: (response, handler) => _interceptorHandlers.handleResponse(
          response,
          handler,
          _handleSessionExpired,
        ),
        onError: (error, handler) => _interceptorHandlers.handleError(
          error,
          handler,
          _handleSessionExpired,
        ),
      ),
    );

    // Logging interceptor (debug mode only)
    if (_config.enableLogging && kDebugMode) {
      _dio.interceptors.add(NetworkLoggingInterceptor());
      debugPrint('✅ NetworkService: Logging interceptor added');
    } else {
      debugPrint('⚠️ NetworkService: Logging DISABLED (enableLogging=${_config.enableLogging}, debugMode=$kDebugMode)');
    }
  }

  /// Handle session expiration
  Future<void> _handleSessionExpired() async {
    debugPrint('🔄 Clearing session data');

    // Clear cookies
    await clearCookies();

    // Trigger app-specific logout callback
    if (_callbacks?.onSessionExpired != null) {
      await _callbacks!.onSessionExpired!();
    }

    debugPrint('✅ Session cleared');
  }

  /// Make HTTP request with automatic error handling
  ///
  /// Example:
  /// ```dart
  /// final response = await service.request(
  ///   '/users',
  ///   method: HttpMethod.get,
  /// );
  /// ```
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

    // Create or use existing cancel token
    final token =
        cancelToken ?? (requestId != null ? _getCancelToken(requestId) : null);

    try {
      Response<T> response;

      switch (method) {
        case HttpMethod.get:
          response = await _dio.get<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: token,
            onReceiveProgress: onReceiveProgress,
          );
          break;

        case HttpMethod.post:
          response = await _dio.post<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: token,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          break;

        case HttpMethod.put:
          response = await _dio.put<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: token,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          break;

        case HttpMethod.delete:
          response = await _dio.delete<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: token,
          );
          break;

        case HttpMethod.patch:
          response = await _dio.patch<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: token,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          break;
      }

      // Clean up cancel token if using requestId
      if (requestId != null) {
        _cancelTokens.remove(requestId);
      }

      return response;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }

  /// Upload file with multipart/form-data
  ///
  /// Example:
  /// ```dart
  /// await service.upload(
  ///   '/files',
  ///   data: {'title': 'My File'},
  ///   files: [MapEntry('file', multipartFile)],
  ///   onProgress: (sent, total) => print('$sent/$total'),
  /// );
  /// ```
  Future<Response> upload(
    String path, {
    required Map<String, dynamic> data,
    List<MapEntry<String, MultipartFile>>? files,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
    String? requestId,
  }) async {
    final formData = FormData();

    // Add fields
    data.forEach((key, value) {
      formData.fields.add(MapEntry(key, value.toString()));
    });

    // Add files
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
  ///
  /// Example:
  /// ```dart
  /// await service.download(
  ///   '/files/123',
  ///   '/path/to/save/file.pdf',
  ///   onProgress: (received, total) => print('$received/$total'),
  /// );
  /// ```
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

  /// Get or create cancel token for request
  CancelToken _getCancelToken(String requestId) {
    return _cancelTokens.putIfAbsent(requestId, () => CancelToken());
  }

  /// Cancel request by ID
  ///
  /// Example:
  /// ```dart
  /// service.cancelRequest('upload-123');
  /// ```
  void cancelRequest(String requestId, [String? reason]) {
    final token = _cancelTokens[requestId];
    if (token != null && !token.isCancelled) {
      token.cancel(reason ?? 'Request cancelled');
      _cancelTokens.remove(requestId);
      debugPrint('🚫 Request cancelled: $requestId');
    }
  }

  /// Cancel all pending requests
  ///
  /// Example:
  /// ```dart
  /// service.cancelAllRequests('User logged out');
  /// ```
  void cancelAllRequests([String? reason]) {
    for (final entry in _cancelTokens.entries) {
      if (!entry.value.isCancelled) {
        entry.value.cancel(reason ?? 'All requests cancelled');
      }
    }
    _cancelTokens.clear();
    debugPrint('🚫 All requests cancelled');
  }

  /// Handle Dio exceptions and convert to NetworkException
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
          return SessionExpiredException();
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException(message, statusCode: statusCode);
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

  /// Extract error message from response data
  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'An error occurred';

    if (data is String) return data;

    if (data is Map) {
      // Try common error message keys
      final message = data['message'] ??
          data['error'] ??
          data['msg'] ??
          data['detail'] ??
          'An error occurred';
      return message.toString();
    }

    return 'An error occurred';
  }

  /// Check if there's a valid session
  ///
  /// Example:
  /// ```dart
  /// final hasSession = await service.hasValidSession('https://api.example.com/auth/check');
  /// ```
  Future<bool> hasValidSession(String checkUrl) async {
    if (!_initialized) {
      debugPrint('⚠️ NetworkService not initialized - cannot check session');
      return false;
    }

    final uri = Uri.parse(checkUrl);
    final cookies = await _cookieJar.loadForRequest(uri);
    final sessionCookie = cookies.firstWhere(
      (cookie) => cookie.name == 'session_id',
      orElse: () => Cookie('session_id', ''),
    );

    if (sessionCookie.value.isNotEmpty &&
        sessionCookie.expires != null &&
        !sessionCookie.expires!.isBefore(DateTime.now())) {
      // Notify app of session cookie if callback provided
      if (_callbacks?.onSessionCookie != null) {
        await _callbacks!.onSessionCookie!(sessionCookie.value);
      }

      debugPrint('✅ Valid session found: ${sessionCookie.value}');
      return true;
    }

    debugPrint('⚠️ No valid session found');
    return false;
  }

  /// Clear all cookies
  ///
  /// Example:
  /// ```dart
  /// await service.clearCookies();
  /// ```
  Future<void> clearCookies() async {
    if (!_initialized) {
      debugPrint('⚠️ NetworkService not initialized - cannot clear cookies');
      return;
    }
    await _cookieJar.deleteAll();
    debugPrint('🍪 All cookies cleared');
  }

  /// Get Dio instance (for advanced usage)
  ///
  /// Use this only when you need direct access to Dio for custom operations.
  Dio get dio {
    if (!_initialized) {
      throw NetworkException(
          'NetworkService not initialized. Call init() first.');
    }
    return _dio;
  }

  /// Get cookie jar (for advanced usage)
  ///
  /// Use this only when you need direct access to cookies for custom operations.
  PersistCookieJar get cookieJar {
    if (!_initialized) {
      throw NetworkException(
          'NetworkService not initialized. Call init() first.');
    }
    return _cookieJar;
  }

  /// Check if service is initialized
  bool get isInitialized => _initialized;
}
