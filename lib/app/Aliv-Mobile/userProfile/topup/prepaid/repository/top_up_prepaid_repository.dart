import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

import 'can_submit_order_result.dart';
import 'top_up_limit_left_model.dart';

class TopUpPrepaidRepository {
  TopUpPrepaidRepository({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// ✅ Later: call API here
  Future<double> fetchCurrentBalance() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return 129.00; // mock from screenshot
  }

  /// ✅ Later: submit topup API here
  Future<void> topUp({required double amount}) async {
    await Future.delayed(const Duration(milliseconds: 400));
  }

  /// GET /Account/top-up-limit-left → 24h rolling remaining + reset time (UTC).
  Future<TopUpLimitLeft> fetchTopUpLimitLeft() async {
    final response = await _networkService.request<dynamic>(
      Api.topUpLimitLeft,
      method: HttpMethod.get,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return TopUpLimitLeft.fromJson(data);
    }
    return const TopUpLimitLeft(limitLeft: 0.0);
  }

  /// GET /Account/can-submit-order?amount={amount} — concurrent-order gate.
  /// Always returns HTTP 200; distinguish by the `Info` field. Callers should
  /// treat a thrown [CanSubmitOrderException] as Case D (fail-closed).
  Future<CanSubmitOrderResult> canSubmitOrder({required double amount}) async {
    try {
      final response = await _networkService.request<dynamic>(
        Api.canSubmitOrder(amount: amount),
        method: HttpMethod.get,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return CanSubmitOrderResult.fromJson(data);
      }
      throw const CanSubmitOrderException();
    } catch (_) {
      throw const CanSubmitOrderException();
    }
  }
}

class CanSubmitOrderException implements Exception {
  const CanSubmitOrderException();
}
