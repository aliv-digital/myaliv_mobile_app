import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';

/// URL-agnostic plumbing for card-based payment POSTs. Owns the network call,
/// 2xx check, `OrderId` extraction, and `NetworkException` → [ChangeBundleFailure]
/// mapping. Higher-level services (change-bundle, top-up) supply the URL and
/// the outer envelope; this class knows nothing about either.
class CardPaymentService {
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
}
