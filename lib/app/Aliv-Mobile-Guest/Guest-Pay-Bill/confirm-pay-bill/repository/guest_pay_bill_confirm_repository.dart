import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_request_factory.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class GuestPayBillConfirmRepository {
  Future<double> fetchVat({
    required String serviceName,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return 0.00;
  }

  Future<void> payNow({
    required String serviceName,
    required String identifierValue,
    required double totalAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return;
  }

  Future<int> fibrPay({
    required int fibrAccountId,
    required double amount,
    required NewCardDetails cardDetails,
  }) async {
    final body = ChangeBundleRequestFactory.fibrPayBody(
      fibrAccountId: fibrAccountId,
      amount: amount,
      card: cardDetails,
    );
    final response = await instance<NetworkService>().request<dynamic>(
      Api.guestFibrPayUrl,
      method: HttpMethod.post,
      data: body,
      options: Options(extra: {'skipAuth': true}),
    );
    final data = response.data;
    final orderId = data is Map ? (data['OrderId'] ?? data['orderId']) : null;
    return orderId is num ? orderId.toInt() : 0;
  }
}
