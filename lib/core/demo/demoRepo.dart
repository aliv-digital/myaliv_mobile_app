// lib/app/demo/repository/demo_api_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../model/apiResponseModel.dart';
import '../networkService/app_http_client.dart';
  // your ApiResponseModel

/// Demo repository that shows how to use every method in ApiService.
/// - Readable method names
/// - English comments
/// - Returns ApiResponseModel or typed data where appropriate
class DemoApiRepository {
  final ApiService _api;
  final String _baseUrl;

  DemoApiRepository({
    required ApiService apiService,
    required String baseUrl})  : _api = apiService, _baseUrl = baseUrl;

  // ---------------------------------------------------------------------------
  // 1) POST JSON: Login
  // ---------------------------------------------------------------------------
  /// Example: POST /auth/login
  /// Sends JSON body { "phone": "...", "password": "..." }
  /// Returns ApiResponseModel (status + raw body string).
  Future<ApiResponseModel> login({
    required String phone,
    required String password,
  }) async {
    final String url = '$_baseUrl/auth/login';
    return _api.postJson(
      url,
      body: {
        'phone': phone,
        'password': password,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 2) GET: Fetch current user's profile
  // ---------------------------------------------------------------------------
  /// Example: GET /users/me
  /// Optional: you could parse JSON to a typed model after receiving response.
  Future<ApiResponseModel> getMyProfile() async {
    final String url = '$_baseUrl/users/me';
    return _api.get(url);
  }

  // ---------------------------------------------------------------------------
  // 3) PUT JSON: Replace/update full profile
  // ---------------------------------------------------------------------------
  /// Example: PUT /users/profile
  /// Sends full profile object as JSON. Server replaces/upserts the resource.
  Future<ApiResponseModel> updateProfile({
    required String name,
    required String email,
  }) async {
    final String url = '$_baseUrl/users/profile';
    return _api.putJson(
      url,
      body: {
        'name': name,
        'email': email,
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 4) PATCH JSON: Partial update of settings
  // ---------------------------------------------------------------------------
  /// Example: PATCH /users/settings
  /// Sends only fields that changed.
  Future<ApiResponseModel> patchUserSettings({
    bool? emailNotifications,
    String? theme,
  }) async {
    final String url = '$_baseUrl/users/settings';
    final Map<String, dynamic> payload = {};
    if (emailNotifications != null) payload['emailNotifications'] = emailNotifications;
    if (theme != null) payload['theme'] = theme;

    return _api.patchJson(url, body: payload);
  }

  // ---------------------------------------------------------------------------
  // 5) DELETE JSON: Delete account with optional confirmation payload
  // ---------------------------------------------------------------------------
  /// Example: DELETE /users/account
  /// Some APIs accept a JSON body for delete confirmation reasons.
  Future<ApiResponseModel> deleteAccount({String? reason}) async {
    final String url = '$_baseUrl/users/account';
    final Map<String, dynamic>? payload = (reason == null) ? null : {'reason': reason};
    return _api.deleteJson(url, body: payload);
  }

  // ---------------------------------------------------------------------------
  // 6) MULTIPART: Upload avatar (image/file)
  // ---------------------------------------------------------------------------
  /// Example: POST /files/avatar
  /// Supports both path-based and bytes-based upload via UploadFile helper.
  Future<ApiResponseModel> uploadAvatarFromPath({
    required String filePath,
    String fileName = 'avatar.jpg',
  }) async {
    final String url = '$_baseUrl/files/avatar';
    return _api.uploadMultipart(
      url: url,
      files: [
        UploadFile.path(fieldName: 'file', filePath: filePath, fileName: fileName),
      ],
      fields: {
        'folder': 'avatars',
      },
    );
  }

  /// Same endpoint, but uploads raw bytes (e.g. from camera or edited image).
  Future<ApiResponseModel> uploadAvatarFromBytes({
    required List<int> bytes,
    String fileName = 'avatar.jpg',
  }) async {
    final String url = '$_baseUrl/files/avatar';
    return _api.uploadMultipart(
      url: url,
      files: [
        UploadFile.bytes(fieldName: 'file', bytes: bytes, fileName: fileName),
      ],
      fields: {
        'folder': 'avatars',
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 7) DOWNLOAD BYTES: e.g., monthly PDF report
  // ---------------------------------------------------------------------------
  /// Example: GET /reports/monthly?month=2025-07
  /// Returns raw bytes (Uint8List) for saving to device or opening in viewer.
  Future<Uint8List> downloadMonthlyReport({
    required String isoMonth, // e.g., "2025-07"
  }) async {
    final String url = '$_baseUrl/reports/monthly';
    return _api.downloadBytes(
      url,
      queryParameters: {'month': isoMonth},
    );
  }

  // ---------------------------------------------------------------------------
  // (Optional) Helper: Parse JSON safely to Map
  // ---------------------------------------------------------------------------
  /// Safely decode a JSON string to Map< String, dynamic >.
  /// Use this when you want to parse ApiResponseModel.body to a Map.
  Map<String, dynamic> tryDecodeJson(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (e, st) {
      if (kDebugMode) debugPrint('JSON decode error: $e\n$st');
      return <String, dynamic>{};
    }
  }
}
