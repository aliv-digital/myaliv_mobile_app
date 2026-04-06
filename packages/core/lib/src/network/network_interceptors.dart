/// Network interceptors for request/response handling
///
/// This file contains interceptor classes and handlers.
/// Responsible for: Request/response interception, logging, and error handling.
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'network_config.dart';
import 'network_exceptions.dart';

/// Handles authentication, session, and error interception
class NetworkInterceptorHandlers {
  NetworkInterceptorHandlers();

  /// Handle outgoing requests - inject auth token
  Future<void> handleRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    return handler.next(options);
  }

  /// Handle incoming responses - check for session expiration
  Future<void> handleResponse(
    Response response,
    ResponseInterceptorHandler handler,
    Future<void> Function() onSessionExpired,
  ) async {
    // Check for session expiration in 200 responses (e.g., Odoo JSON-RPC)
    if (response.statusCode == 200 && response.data is Map) {
      final data = response.data as Map;

      // Check JSON-RPC error format
      if (data['jsonrpc'] != null && data['error'] != null) {
        final errorData = data['error'];
        if (errorData is Map && errorData['message'] != null) {
          final message = errorData['message'].toString().toLowerCase();
          if (message.contains('session expired') ||
              message.contains('odoo session expired')) {
            debugPrint('🔄 Session expired detected in 200 response');
            await onSessionExpired();
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: SessionExpiredException(),
              ),
            );
          }
        }
      }
    }

    return handler.next(response);
  }

  /// Handle errors - check for 401 and session expiration
  Future<void> handleError(
    DioException error,
    ErrorInterceptorHandler handler,
    Future<void> Function() onSessionExpired,
  ) async {
    // Handle 401 unauthorized
    if (error.response?.statusCode == 401) {
      debugPrint('❌ 401 Unauthorized - Session expired');
      await onSessionExpired();
      return handler.next(error);
    }

    // Handle session expiration in error response
    if (isSessionExpired(error)) {
      debugPrint('🔄 Session expired detected in error');
      await onSessionExpired();
    }

    return handler.next(error);
  }

  /// Check if error indicates session expiration
  bool isSessionExpired(DioException error) {
    // Default implementation
    final errorData = error.response?.data;

    if (errorData is String) {
      return errorData.toLowerCase().contains('session expired') ||
          errorData.toLowerCase().contains('odoo session expired');
    }

    if (errorData is Map) {
      final message = errorData['message']?.toString() ?? '';
      final errorMsg = errorData['error']?.toString() ?? '';
      return message.toLowerCase().contains('session expired') ||
          message.toLowerCase().contains('odoo session expired') ||
          errorMsg.toLowerCase().contains('session expired') ||
          errorMsg.toLowerCase().contains('odoo session expired');
    }

    return false;
  }
}

/// Logging interceptor for debugging
class NetworkLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('\n🚀 REQUEST [${options.method}] ${options.uri}');
    debugPrint('📦 Headers: ${_formatJson(options.headers)}');

    if (options.data is FormData) {
      final formData = options.data as FormData;
      debugPrint('📤 FormData Fields: ${formData.fields}');
      if (formData.files.isNotEmpty) {
        debugPrint(
          '📎 Files: ${formData.files.map((f) => '${f.key} (${f.value.filename ?? "unknown"})').toList()}',
        );
      }
    } else if (options.data != null) {
      // Skip logging binary request data
      if (_isBinaryData(options.data)) {
        debugPrint(
            '📤 Data: [Binary data - ${_getDataSize(options.data)} bytes]');
      } else {
        debugPrint('📤 Data: ${_formatJson(options.data)}');
      }
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '✅ RESPONSE [${response.statusCode}] ${response.requestOptions.uri}',
    );

    // Skip logging binary data (images, files, etc.)
    if (_isBinaryData(response.data)) {
      debugPrint(
          '📥 Data: [Binary data - ${_getDataSize(response.data)} bytes]');
    } else {
      debugPrint('📥 Data: ${_formatJson(response.data)}');
    }

    return handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    debugPrint(
      '❌ ERROR [${error.response?.statusCode}] ${error.requestOptions.uri}',
    );
    debugPrint('🧨 Message: ${error.message}');
    if (error.response?.data != null) {
      // Skip logging binary error data
      if (_isBinaryData(error.response?.data)) {
        debugPrint(
            '📛 Data: [Binary data - ${_getDataSize(error.response?.data)} bytes]');
      } else {
        debugPrint('📛 Data: ${_formatJson(error.response?.data)}');
      }
    }
    return handler.next(error);
  }

  /// Format JSON for logging
  String _formatJson(dynamic data) {
    try {
      // If data is a String, try to parse it as JSON first
      if (data is String) {
        try {
          final parsed = jsonDecode(data);
          return const JsonEncoder.withIndent('  ').convert(parsed);
        } catch (_) {
          // Not valid JSON, return as-is (truncate if too long)
          if (data.length > 1000) {
            return '${data.substring(0, 1000)}... [truncated, length: ${data.length}]';
          }
          return data;
        }
      }

      // For non-string data, format directly
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  /// Check if data is binary (byte array, image, file, etc.)
  bool _isBinaryData(dynamic data) {
    if (data is List<int>) return true; // Byte array
    if (data is Stream) return true; // Stream data

    // Check if it's a list containing mostly integers (byte data)
    if (data is List && data.isNotEmpty && data.length > 100) {
      // Sample first 10 items - if all are ints, likely binary data
      final sample = data.take(10);
      if (sample.every((item) => item is int)) {
        return true;
      }
    }

    return false;
  }

  /// Get data size for logging
  String _getDataSize(dynamic data) {
    if (data is List) {
      return '${data.length}';
    }
    if (data is String) {
      return '${data.length}';
    }
    return 'unknown';
  }
}
