// lib/core/network/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/apiResponseModel.dart';

/// A small, readable HTTP client wrapper for typical app needs.
/// - Auto-injects Authorization token if `tokenProvider` is supplied
/// - JSON requests (auto-encodes Map/List bodies when Content-Type is JSON)
/// - Clear timeouts and offline error messages
/// - Simple multipart upload for files/images
/// - Separate methods for each HTTP verb for readability
class ApiService {
  /// Underlying HTTP client. Reusing a single client improves performance and testability.
  final http.Client _client;

  /// Default timeout for all requests.
  final Duration requestTimeout;

  /// Optional token provider, e.g., read from FlutterSecureStorage.
  /// If present and returns a non-empty token, it will be added as:
  ///   Authorization: Bearer < token >
  final Future<String?> Function()? tokenProvider;

  ApiService({
    http.Client? client,
    this.requestTimeout = const Duration(seconds: 20),
    this.tokenProvider,
  }) : _client = client ?? http.Client();

  // ---------------------------------------------------------------------------
  // Public, human-friendly methods
  // ---------------------------------------------------------------------------

  /// HTTP GET with optional query string and extra headers.
  Future<ApiResponseModel>get(String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  })async {
    final Uri uri = _buildUri(url, queryParameters);
    final Map<String, String> resolvedHeaders = await _buildJsonHeaders(headers);

    try {
      final http.Response response = await _client.get(uri, headers: resolvedHeaders).timeout(requestTimeout);
      return _toApiResponse(response);
    } on TimeoutException {
      return ApiResponseModel(408, 'Request timeout');
    } on SocketException {
      return ApiResponseModel(0, 'No internet connection');
    } on http.ClientException catch (e) {
      return ApiResponseModel(0, 'Network error: ${e.message}');
    } catch (e, st) {
      if (kDebugMode) debugPrint('GET unexpected error: $e\n$st');
      return ApiResponseModel(500, 'Unexpected error');
    }
  }

  /// HTTP POST with JSON body. If `body` is Map/List, it will be JSON-encoded.
  Future<ApiResponseModel> postJson(String url, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }){
    return _sendJsonWithBody(
      method: 'POST',
      url: url,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  /// HTTP PUT with JSON body.
  Future<ApiResponseModel> putJson(
      String url, {
        Object? body,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
      }) {
    return _sendJsonWithBody(
      method: 'PUT',
      url: url,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  /// HTTP PATCH with JSON body.
  Future<ApiResponseModel> patchJson(
      String url, {
        Object? body,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
      }) {
    return _sendJsonWithBody(
      method: 'PATCH',
      url: url,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  /// HTTP DELETE. Some APIs accept a JSON body in DELETE; supported here.
  Future<ApiResponseModel> deleteJson(
      String url, {
        Object? body,
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
      }) {
    return _sendJsonWithBody(
      method: 'DELETE',
      url: url,
      body: body,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  /// Multipart upload for one or more files/images with optional extra fields.
  /// NOTE: Do not set Content-Type manually; `http` will set multipart boundary automatically.
  Future<ApiResponseModel> uploadMultipart({
    required String url,
    required List<UploadFile> files,
    Map<String, String>? fields,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(url, queryParameters);
    final http.MultipartRequest request = http.MultipartRequest('POST', uri);

    // Add token & Accept header. DO NOT set Content-Type for multipart.
    final Map<String, String> resolvedHeaders = await _buildMultipartHeaders(headers);
    request.headers.addAll(resolvedHeaders);

    if (fields != null && fields.isNotEmpty) {
      request.fields.addAll(fields);
    }

    // Support path-based and bytes-based attachments
    for (final UploadFile file in files) {
      if (file.filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            file.fieldName,
            file.filePath!,
            filename: file.fileName,
          ),
        );
      } else if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            file.fieldName,
            file.bytes!,
            filename: file.fileName ?? 'upload.bin',
          ),
        );
      }
    }

    try {
      final http.StreamedResponse streamedResponse =
      await request.send().timeout(requestTimeout);
      final http.Response response = await http.Response.fromStream(streamedResponse);
      return _toApiResponse(response);
    } on TimeoutException {
      return ApiResponseModel(408, 'Upload timeout');
    } on SocketException {
      return ApiResponseModel(0, 'No internet connection');
    } catch (e, st) {
      if (kDebugMode) debugPrint('UPLOAD unexpected error: $e\n$st');
      return ApiResponseModel(500, 'Unexpected error');
    }
  }

  /// Download any resource as raw bytes (e.g., PDF/image).
  Future<Uint8List> downloadBytes(
      String url, {
        Map<String, dynamic>? queryParameters,
        Map<String, String>? headers,
      }) async {
    final Uri uri = _buildUri(url, queryParameters);
    final Map<String, String> resolvedHeaders = await _buildJsonHeaders(headers);

    try {
      final http.Response response =
      await _client.get(uri, headers: resolvedHeaders).timeout(requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
      // Convert non-2xx responses to readable errors
      throw HttpException('HTTP ${response.statusCode} while downloading bytes');
    } on TimeoutException {
      throw HttpException('Request timeout while downloading bytes');
    } on SocketException {
      throw HttpException('No internet connection while downloading bytes');
    }
  }

  /// Close the underlying HTTP client when you are done with it.
  void dispose() => _client.close();

  // ---------------------------------------------------------------------------
  // Internal helpers (kept small and explicit)
  // ---------------------------------------------------------------------------

  /// Shared JSON sender used by post/put/patch/delete for readability.
  Future<ApiResponseModel> _sendJsonWithBody({
    required String method,
    required String url,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(url, queryParameters);
    final Map<String, String> resolvedHeaders = await _buildJsonHeaders(headers);
    final Object? encodedBody = _encodeBodyIfJson(body, resolvedHeaders);

    try {
      final http.Request request = http.Request(method, uri)
        ..headers.addAll(resolvedHeaders);

      if (encodedBody != null) {
        // For JSON, encodedBody is a String. For forms, it could be Map<String, String>.
        if (encodedBody is String) {
          request.body = encodedBody;
        } else {
          // Fallback: http.Request only accepts String. Convert if needed.
          request.body = encodedBody.toString();
        }
      }

      final http.StreamedResponse streamed = await _client.send(request).timeout(requestTimeout);
      final http.Response response = await http.Response.fromStream(streamed);
      return _toApiResponse(response);
    } on TimeoutException {
      return ApiResponseModel(408, 'Request timeout');
    } on SocketException {
      return ApiResponseModel(0, 'No internet connection');
    } on http.ClientException catch (e) {
      return ApiResponseModel(0, 'Network error: ${e.message}');
    } catch (e, st) {
      if (kDebugMode) debugPrint('$method unexpected error: $e\n$st');
      return ApiResponseModel(500, 'Unexpected error');
    }
  }

  /// Build a Uri with optional query parameters.
  /// If `queryParameters` is null/empty, the original URL is used.
  /// NOTE: If a value is Iterable, the last value wins (simple approach).
  Uri _buildUri(String url, Map<String, dynamic>? queryParameters) {
    final Uri base = Uri.parse(url);
    if (queryParameters == null || queryParameters.isEmpty) return base;

    final Map<String, String> asString = <String, String>{};
    queryParameters.forEach((String key, dynamic value) {
      if (value == null) return;
      if (value is Iterable) {
        for (final dynamic item in value) {
          asString[key] = item.toString();
        }
      } else {
        asString[key] = value.toString();
      }
    });

    return base.replace(queryParameters: <String, String>{
      ...base.queryParameters,
      ...asString,
    });
  }

  /// Build headers for JSON requests:
  /// - Accept: application/json
  /// - Content-Type: application/json; charset=utf-8
  /// - Authorization: Bearer < token >  (if provided)
  Future<Map<String, String>> _buildJsonHeaders(Map<String, String>? extra) async {
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      ...?extra,
    };

    final String? token = await tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Build headers for multipart requests (no Content-Type here).
  Future<Map<String, String>> _buildMultipartHeaders(Map<String, String>? extra) async {
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      ...?extra,
    };

    final String? token = await tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// JSON auto-encode helper. If Content-Type indicates JSON and body is not a String,
  /// Maps/Lists will be encoded to a JSON string.
  Object? _encodeBodyIfJson(Object? body, Map<String, String> headers) {
    if (body == null) return null;

    final String contentType = headers['Content-Type'] ?? headers['content-type'] ?? '';
    final bool isJson = contentType.contains('application/json');

    if (isJson && body is! String) {
      return jsonEncode(body);
    }
    return body; // For String bodies or form-urlencoded bodies
  }

  /// Convert http.Response to your ApiResponseModel (status + raw body string).
  ApiResponseModel _toApiResponse(http.Response response) {
    return ApiResponseModel(response.statusCode, response.body);
  }
}

/// Helper model for multipart uploads.
/// You can create with a file path or directly with bytes.
class UploadFile {
  /// The form field name used by the server, e.g., "file" or "avatar".
  final String fieldName;

  /// Provide either a local file path or raw bytes.
  final String? filePath;
  final List<int>? bytes;

  /// Optional filename to present to the server (e.g., "photo.jpg").
  final String? fileName;

  UploadFile.path({
    required this.fieldName,
    required this.filePath,
    this.fileName,
  }) : bytes = null;

  UploadFile.bytes({
    required this.fieldName,
    required this.bytes,
    this.fileName,
  }) : filePath = null;
}
