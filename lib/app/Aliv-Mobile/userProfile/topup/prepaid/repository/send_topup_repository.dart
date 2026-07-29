import 'dart:convert';

import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class SendTopupRepository {
  SendTopupRepository({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  Future<void> transfer({
    required String toNumber,
    required double amount,
  }) async {
    final sanitizedNumber = toNumber.replaceAll(RegExp(r'\D'), '');

    if (sanitizedNumber.isEmpty) {
      throw const SendTopupException('Recipient phone number is missing.');
    }

    if (amount <= 0) {
      throw const SendTopupException('Amount must be greater than zero.');
    }

    try {
      await _networkService.request<dynamic>(
        Api.orderTransferUrl,
        method: HttpMethod.post,
        data: <String, dynamic>{
          'ToNumber': sanitizedNumber,
          'Amount': amount,
        },
      );
    } on NetworkException catch (error) {
      throw SendTopupException(_errorMessage(error));
    } on SendTopupException {
      rethrow;
    } catch (_) {
      throw const SendTopupException(
        'Could not complete the transfer. Please try again.',
      );
    }
  }

  /// GET /device/exists/{phoneNumber} — is this an Aliv number at all?
  ///
  /// - 200 `{ "Success": true }` → [PhoneExistsResult.exists]
  /// - error envelope `{ "ErrorCode": 501, "ErrorCodeName": "InvalidDevice" }`
  ///   → [PhoneExistsResult.invalidDevice] (backend is telling us the number
  ///   is not an Aliv device — user-actionable, distinct from a network
  ///   failure).
  /// - anything else (network error, timeout, 5xx, malformed body)
  ///   → [PhoneExistsResult.unknown] → caller treats as Case D.
  Future<PhoneExistsResult> phoneNumberExists(String phoneNumber) async {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return PhoneExistsResult.unknown;

    try {
      final response = await _networkService.request<dynamic>(
        Api.deviceExists(phoneNumber: digits),
        method: HttpMethod.get,
      );
      final data = response.data;
      if (_isInvalidDeviceBody(data)) return PhoneExistsResult.invalidDevice;
      if (data is Map<String, dynamic> && data['Success'] == true) {
        return PhoneExistsResult.exists;
      }
      return PhoneExistsResult.unknown;
    } on NetworkException catch (error) {
      if (_isInvalidDeviceBody(error.data)) {
        return PhoneExistsResult.invalidDevice;
      }
      return PhoneExistsResult.unknown;
    } catch (_) {
      return PhoneExistsResult.unknown;
    }
  }

  bool _isInvalidDeviceBody(dynamic data) {
    Map? map;
    if (data is Map) {
      map = data;
    } else if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) map = decoded;
      } catch (_) {
        return false;
      }
    }
    if (map == null) return false;
    final code = map['ErrorCode'];
    final name = map['ErrorCodeName']?.toString();
    return code == 501 || name == 'InvalidDevice';
  }

  /// GET /device/transfer-is-valid/{phoneNumber} — recipient eligibility
  /// (Send Top-up Gate 2, called after Gate 0 confirms the number exists).
  ///
  /// Returns `null` when the backend confirms `{ "Success": true }` (proceed).
  /// Returns the server's `Message` string on any non-200 / failure response
  /// so the caller can show it verbatim in a toast.
  Future<String?> transferIsValid(String phoneNumber) async {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return caseDMessage;

    try {
      final response = await _networkService.request<dynamic>(
        Api.transferIsValid(phoneNumber: digits),
        method: HttpMethod.get,
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['Success'] == true) {
        return null;
      }
      return _extractServerMessage(data) ?? caseDMessage;
    } on NetworkException catch (error) {
      return _extractServerMessage(error.data) ?? _errorMessage(error);
    } catch (_) {
      return caseDMessage;
    }
  }

  static const caseDMessage =
      'please try again in a few minutes. if this continues, contact support at 1-242-300-2548';

  String _errorMessage(NetworkException error) {
    if (error is NoInternetException || error is HostUnreachableException) {
      return 'No internet connection. Please check and try again.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    if (error is SessionExpiredException) {
      return 'Session expired. Please log in again.';
    }

    final serverMessage = _extractServerMessage(error.data);
    if (serverMessage != null) {
      return serverMessage;
    }

    final statusCode = error.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return 'Server error. Please try again later.';
    }

    return 'Could not complete the transfer. Please try again.';
  }

  /// Pulls "Message" (preferred) or "Detail" out of the server's error body.
  /// Server shape: `{"ErrorCode":461,"Message":"...","Detail":"..."}`.
  String? _extractServerMessage(dynamic data) {
    Map<String, dynamic>? map;

    if (data is Map<String, dynamic>) {
      map = data;
    } else if (data is Map) {
      map = data.map((k, v) => MapEntry(k.toString(), v));
    } else if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          map = decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {
        return null;
      }
    }

    if (map == null) return null;

    final message = (map['Message'] ?? map['message'])?.toString().trim();
    if (message != null && message.isNotEmpty) return message;

    final detail = (map['Detail'] ?? map['detail'])?.toString().trim();
    if (detail != null && detail.isNotEmpty) return detail;

    return null;
  }
}

class SendTopupException implements Exception {
  final String message;

  const SendTopupException(this.message);

  @override
  String toString() => message;
}

/// Outcome of [SendTopupRepository.phoneNumberExists]. Three-valued because
/// "not an Aliv number" (backend-confirmed) needs different UX than "we
/// couldn't reach the check" (network failure → Case D).
enum PhoneExistsResult { exists, invalidDevice, unknown }
