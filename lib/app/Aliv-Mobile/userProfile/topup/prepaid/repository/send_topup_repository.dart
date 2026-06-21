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
