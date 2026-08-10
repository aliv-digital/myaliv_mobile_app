/// Network interceptors for logging.
///
/// Auth/session interception was moved to [BearerAuthInterceptor] during
/// the JWT migration. This file now only contains the logging interceptor.
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'network_config.dart';

/// Logging interceptor for debugging.
///
/// Behavior is controlled by [NetworkLogConfig]. Defaults emit compact
/// (single-line) bodies, truncate at 20000 chars, and collapse arrays
/// longer than 50 items. Long bodies are chunked across multiple
/// `debugPrint` calls so Android logcat (which truncates lines around
/// ~4 KB) still surfaces the full payload.
class NetworkLoggingInterceptor extends Interceptor {
  NetworkLoggingInterceptor({NetworkLogConfig? config})
      : _config = config ?? const NetworkLogConfig();

  final NetworkLogConfig _config;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('\n🚀 REQUEST [${options.method}] ${options.uri}');

    if (_config.logRequestHeaders) {
      _printChunked('📦 Headers', _formatBody(options.headers));
    }

    if (_config.logRequestBody) {
      _logRequestBody(options.data);
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '✅ RESPONSE [${response.statusCode}] ${response.requestOptions.uri}',
    );

    if (_config.logResponseHeaders) {
      _printChunked('📋 Headers', _formatBody(response.headers.map));
    }

    if (_config.logResponseBody) {
      _logResponseBody(response.data);
    }

    return handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    final status = error.response?.statusCode;
    final tag = status?.toString() ?? error.type.name;
    final method = error.requestOptions.method;
    final uri = error.requestOptions.uri;

    debugPrint('\n❌ ERROR [$tag] $method $uri');
    debugPrint('🔻 Type: ${error.type.name}');
    debugPrint('🧨 Message: ${error.message ?? "(none)"}');

    if (error.error != null) {
      debugPrint('🪤 Cause: ${error.error}');
    }

    final response = error.response;
    if (response != null) {
      if (_config.logResponseHeaders) {
        _printChunked(
            '📋 Response Headers', _formatBody(response.headers.map));
      }
      if (response.data != null) {
        debugPrint('📛 Extracted: ${_extractErrorMessage(response.data)}');
        if (_config.logResponseBody) {
          if (_isBinaryData(response.data)) {
            debugPrint(
                '📥 Response Body: [Binary data - ${_getDataSize(response.data)} bytes]');
          } else {
            _printChunked('📥 Response Body', _formatBody(response.data));
          }
        }
      }
    }

    if (_config.logErrorRequestBody) {
      final reqData = error.requestOptions.data;
      if (reqData != null) {
        if (reqData is FormData) {
          debugPrint('📤 Request FormData Fields: ${reqData.fields}');
        } else if (_isBinaryData(reqData)) {
          debugPrint(
              '📤 Request Body: [Binary data - ${_getDataSize(reqData)} bytes]');
        } else {
          _printChunked('📤 Request Body', _formatBody(reqData));
        }
      }
    }

    if (_config.logErrorStack && error.stackTrace.toString().isNotEmpty) {
      debugPrint('🧵 Stack:\n${error.stackTrace}');
    }

    return handler.next(error);
  }

  // ---------------- helpers ----------------

  void _logRequestBody(dynamic data) {
    if (data == null) return;

    if (data is FormData) {
      debugPrint('📤 FormData Fields: ${data.fields}');
      if (data.files.isNotEmpty) {
        debugPrint(
          '📎 Files: ${data.files.map((f) => '${f.key} (${f.value.filename ?? "unknown"})').toList()}',
        );
      }
      return;
    }

    if (_isBinaryData(data)) {
      debugPrint('📤 Data: [Binary data - ${_getDataSize(data)} bytes]');
      return;
    }

    _printChunked('📤 Data', _formatBody(data));
  }

  void _logResponseBody(dynamic data) {
    if (_isBinaryData(data)) {
      debugPrint('📥 Data: [Binary data - ${_getDataSize(data)} bytes]');
      return;
    }
    _printChunked('📥 Data', _formatBody(data));
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'An error occurred';

    if (data is String) {
      try {
        final parsed = jsonDecode(data);
        if (parsed is Map) return _extractMessageFromMap(parsed);
        return data;
      } catch (_) {
        return data;
      }
    }

    if (data is Map) return _extractMessageFromMap(data);

    return 'An error occurred';
  }

  String _extractMessageFromMap(Map data) {
    final message = data['Message'] ??
        data['message'] ??
        data['Error'] ??
        data['error'] ??
        data['msg'] ??
        data['Detail'] ??
        data['detail'];
    return message?.toString() ?? 'An error occurred';
  }

  String _formatBody(dynamic data) {
    if (_config.bodyMode == NetworkLogBodyMode.off) return '<hidden>';

    dynamic decoded = data;
    if (data is String) {
      try {
        decoded = jsonDecode(data);
      } catch (_) {
        return _truncate(data);
      }
    }

    try {
      if (_config.bodyMode == NetworkLogBodyMode.summary) {
        return _truncate(jsonEncode(_summarize(decoded)));
      }

      final trimmed = _trimArrays(decoded, _config.maxArrayItems);
      final encoded = _config.bodyMode == NetworkLogBodyMode.pretty
          ? const JsonEncoder.withIndent('  ').convert(trimmed)
          : jsonEncode(trimmed);
      return _truncate(encoded);
    } catch (_) {
      return _truncate(data.toString());
    }
  }

  dynamic _trimArrays(dynamic node, int max) {
    if (node is List) {
      final trimmed = node.length > max
          ? [
              ...node.take(max).map((e) => _trimArrays(e, max)),
              '... +${node.length - max} more',
            ]
          : node.map((e) => _trimArrays(e, max)).toList();
      return trimmed;
    }
    if (node is Map) {
      return node.map((k, v) => MapEntry(k, _trimArrays(v, max)));
    }
    return node;
  }

  dynamic _summarize(dynamic node) {
    if (node is List) {
      if (node.isEmpty) return '<List length=0>';
      return '<List length=${node.length}, sample=${jsonEncode(_summarize(node.first))}>';
    }
    if (node is Map) {
      return node.map((k, v) => MapEntry(k.toString(), _summarize(v)));
    }
    return node;
  }

  String _truncate(String s) {
    final max = _config.maxBodyChars;
    if (max <= 0 || s.length <= max) return s;
    return '${s.substring(0, max)}... [truncated, total=${s.length}]';
  }

  void _printChunked(String label, String body) {
    const chunk = 800;
    if (body.length <= chunk) {
      debugPrint('$label: $body');
      return;
    }
    debugPrint('$label: ${body.substring(0, chunk)}');
    var i = chunk;
    while (i < body.length) {
      final end = (i + chunk < body.length) ? i + chunk : body.length;
      debugPrint('  …${body.substring(i, end)}');
      i = end;
    }
  }

  bool _isBinaryData(dynamic data) {
    if (data is List<int>) return true;
    if (data is Stream) return true;

    if (data is List && data.isNotEmpty && data.length > 100) {
      final sample = data.take(10);
      if (sample.every((item) => item is int)) return true;
    }

    return false;
  }

  String _getDataSize(dynamic data) {
    if (data is List) return '${data.length}';
    if (data is String) return '${data.length}';
    return 'unknown';
  }
}
