import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';

/// URL-agnostic plumbing for card-based payment POSTs. Owns the network call,
/// 2xx check, `OrderId` extraction, and `NetworkException` → [ChangeBundleFailure]
/// mapping. Higher-level services (change-bundle, top-up) supply the URL and
/// the outer envelope; this class knows nothing about either.
class CardPaymentService {
  static const pendingOrdersMessage =
      'You have pending or failed orders. '
      'Please wait for the open orders to complete '
      'before sending another request.';

  CardPaymentService({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  Future<ChangeBundleResult> send({
    required String url,
    required Map<String, dynamic> body,
    String logTag = 'card-payment',
  }) async {
    if (kDebugMode) {
      debugPrint('$logTag POST $url body: $body');
    }

    try {
      final response = await _networkService.request<dynamic>(
        url,
        method: HttpMethod.post,
        data: body,
      );

      if (kDebugMode) {
        debugPrint(
          '$logTag status: ${response.statusCode} body: ${response.data}',
        );
      }

      final code = response.statusCode ?? 0;
      if (code >= 200 && code < 300) {
        return ChangeBundleSuccess(orderId: _extractOrderId(response.data));
      }
      return const ChangeBundleFailure('Payment failed. Try again.');
    } on NetworkException catch (error) {
      return ChangeBundleFailure(_errorMessage(error));
    } catch (error) {
      return ChangeBundleFailure('Payment failed: $error');
    }
  }

  int? _extractOrderId(dynamic data) {
    if (data is Map && data['OrderId'] is int) return data['OrderId'] as int;
    if (data is Map && data['OrderId'] is String) {
      return int.tryParse(data['OrderId'] as String);
    }
    return null;
  }

  String _errorMessage(NetworkException error) {
    // Server-declared error codes take precedence — they're authoritative
    // regardless of transport wrapper. Example: `ToManyOrders` shipped inside
    // a 4xx body is a business signal, not a network problem.
    final custom = _customMessageFor(_errorCodeName(error.data));
    if (custom != null) return custom;

    if (error is NoInternetException || error is HostUnreachableException) {
      return error.message;
    }
    if (error is TimeoutException) {
      return 'Request timeout. Please try again.';
    }
    if (error is SessionExpiredException || error.statusCode == 401) {
      return 'Session expired. Please log in again.';
    }
    final message = error.message.trim();
    if (message.isNotEmpty && message != 'An error occurred') {
      return message;
    }
    return 'Payment failed. Try again.';
  }

  /// Map the server's `ErrorCodeName` onto a user-facing message. Returns
  /// null when no override exists — caller falls back to transport handling.
  String? _customMessageFor(String? codeName) {
    switch (codeName?.trim().toLowerCase()) {
      // The API currently returns the misspelled "ToManyOrders". Accept the
      // correctly spelled variant as well so the UI copy remains stable if
      // the backend fixes its enum name.
      case 'tomanyorders':
      case 'toomanyorders':
        return pendingOrdersMessage;
    }
    return null;
  }

  /// Dio may deliver the error body as a decoded `Map` or as a raw JSON
  /// `String` depending on `ResponseType`. Handle both.
  String? _errorCodeName(dynamic data) {
    if (data is Map) {
      final name = data['ErrorCodeName'] ?? data['errorCodeName'];
      return name is String ? name : name?.toString();
    }
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        return _errorCodeName(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
