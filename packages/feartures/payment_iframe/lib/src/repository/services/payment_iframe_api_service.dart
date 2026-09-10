import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../models/order_status_model.dart';
import '../../models/payment_request.dart';
import '../payment_iframe_exception.dart';

/// Makes the initial POST request that kicks off the iframe payment flow.
///
/// The API returns a JSON object with an `"html"` field containing a complete
/// HTML document. That document contains a fingerprinting iframe that auto-
/// submits to PowerTranz and eventually redirects back to the app via the
/// custom URI scheme.
class PaymentIFrameApiService {
  PaymentIFrameApiService({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// POST [request.body] to [request.endpoint] and return the HTML string
  /// from the response's `"html"` field.
  ///
  /// Throws [PaymentIFrameException] on any error.
  Future<String> fetchHtml(PaymentRequest request) async {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 💳 PAYMENT IFRAME — initiate');
      debugPrint('│ POST ${request.endpoint}');
      debugPrint('│ body: ${request.body}');
      debugPrint('└─────────────────────────────────────────');
    }

    try {
      final response = await _networkService.request<dynamic>(
        request.endpoint,
        method: HttpMethod.post,
        data: request.body,
        // Guest endpoints reject Bearer tokens — skip auth header unless the
        // caller explicitly marks the request as authenticated.
        options: request.requiresAuth ? null : Options(extra: {'skipAuth': true}),
      );

      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ✅ PAYMENT IFRAME — response ${response.statusCode}');
        debugPrint('└─────────────────────────────────────────');
        debugPrint('');
      }

      return _extractHtml(response.data);
    } on NetworkException catch (e) {
      if (kDebugMode) {
        debugPrint('│ ❌ PAYMENT IFRAME — NetworkException: $e');
      }
      throw _mapNetworkException(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('│ ❌ PAYMENT IFRAME — unexpected error: $e');
      }
      throw PaymentIFrameException(
        'Failed to initiate payment: $e',
        type: PaymentIFrameErrorType.unknown,
        originalError: e,
      );
    }
  }

  /// GET [orderVerificationUrl]?orderId=[orderId] and return an [OrderStatusModel].
  ///
  /// Throws [PaymentIFrameException] on any error.
  Future<OrderStatusModel> fetchOrderStatus({
    required String orderVerificationUrl,
    required String orderId,
    required bool requiresAuth,
  }) async {
    final url = '$orderVerificationUrl?orderId=$orderId';

    if (kDebugMode) {
      debugPrint('');
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 💳 PAYMENT IFRAME — verify order');
      debugPrint('│ GET $url');
      debugPrint('└─────────────────────────────────────────');
    }

    try {
      final response = await _networkService.request<dynamic>(
        url,
        method: HttpMethod.get,
        options: requiresAuth ? null : Options(extra: {'skipAuth': true}),
      );

      if (kDebugMode) {
        debugPrint('┌─────────────────────────────────────────');
        debugPrint('│ ✅ PAYMENT IFRAME — order status ${response.statusCode}');
        debugPrint('│ data: ${response.data}');
        debugPrint('└─────────────────────────────────────────');
        debugPrint('');
      }

      return OrderStatusModel.parse(response.data);
    } on NetworkException catch (e) {
      if (kDebugMode) debugPrint('│ ❌ PAYMENT IFRAME — order verify NetworkException: $e');
      throw _mapNetworkException(e);
    } catch (e) {
      if (kDebugMode) debugPrint('│ ❌ PAYMENT IFRAME — order verify unexpected: $e');
      throw PaymentIFrameException(
        'Failed to verify order status: $e',
        type: PaymentIFrameErrorType.unknown,
        originalError: e,
      );
    }
  }

  String _extractHtml(dynamic data) {
    Map<String, dynamic>? map;

    if (data is Map<String, dynamic>) {
      map = data;
    } else if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) map = decoded;
      } catch (_) {}
    }

    final html = map?['html'];
    if (html is String && html.isNotEmpty) return html;

    throw const PaymentIFrameException(
      'API response did not contain an "html" field.',
      type: PaymentIFrameErrorType.invalidResponse,
    );
  }

  PaymentIFrameException _mapNetworkException(NetworkException e) {
    if (e is NoInternetException || e is HostUnreachableException) {
      return PaymentIFrameException(
        e.message,
        type: PaymentIFrameErrorType.noInternet,
        originalError: e,
      );
    }
    if (e is TimeoutException) {
      return PaymentIFrameException(
        'Request timed out. Please try again.',
        type: PaymentIFrameErrorType.timeout,
        originalError: e,
      );
    }
    final code = e.statusCode ?? 0;
    if (code >= 500) {
      return PaymentIFrameException(
        'Server error. Please try again later.',
        type: PaymentIFrameErrorType.server,
        originalError: e,
      );
    }
    return PaymentIFrameException(
      e.message.isNotEmpty ? e.message : 'Payment request failed.',
      type: PaymentIFrameErrorType.network,
      originalError: e,
    );
  }
}
