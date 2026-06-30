import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_request_factory.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/change_bundle_result.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/plan_bundle.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// One-stop payment service for the `POST /Order/change-bundle` endpoint.
/// Any screen can call any method here without coupling to the home-plans
/// feature module. Returns a [ChangeBundleResult] so callers can pattern-match
/// instead of catching exceptions.
class ChangeBundleService {
  ChangeBundleService({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  Future<ChangeBundleResult> payFromWallet({
    required double amount,
    required PlanBundle bundle,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) {
    return _send(
      cardPayment: ChangeBundleRequestFactory.walletCardPayment(amount: amount),
      bundle: bundle,
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
      logTag: 'wallet',
    );
  }

  Future<ChangeBundleResult> payWithSavedCard({
    required double amount,
    required String cardToken,
    required PlanBundle bundle,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) {
    return _send(
      cardPayment: ChangeBundleRequestFactory.tokenCardPayment(
        amount: amount,
        cardToken: cardToken,
      ),
      bundle: bundle,
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
      logTag: 'saved-card',
    );
  }

  Future<ChangeBundleResult> payWithNewCard({
    required double amount,
    required NewCardDetails details,
    required PlanBundle bundle,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) {
    return _send(
      cardPayment: ChangeBundleRequestFactory.newCardPayment(
        amount: amount,
        details: details,
      ),
      bundle: bundle,
      forceNow: forceNow,
      selectedBeginDate: selectedBeginDate,
      logTag: 'new-card',
    );
  }

  Future<ChangeBundleResult> _send({
    required Map<String, dynamic> cardPayment,
    required PlanBundle bundle,
    required bool forceNow,
    DateTime? selectedBeginDate,
    required String logTag,
  }) async {
    final Map<String, dynamic> body;
    try {
      body = ChangeBundleRequestFactory.body(
        cardPayment: cardPayment,
        bundle: bundle,
        forceNow: forceNow,
        selectedBeginDate: selectedBeginDate,
      );
    } catch (e) {
      return ChangeBundleFailure(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }

    if (kDebugMode) {
      debugPrint('change-bundle [$logTag] request: $body');
    }

    try {
      final response = await _networkService.request<dynamic>(
        Api.payFromWalletUrl,
        method: HttpMethod.post,
        data: body,
      );

      if (kDebugMode) {
        debugPrint(
          'change-bundle [$logTag] status: ${response.statusCode} '
          'body: ${response.data}',
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
