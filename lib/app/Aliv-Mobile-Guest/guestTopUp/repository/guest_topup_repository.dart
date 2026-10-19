// lib/features/guest_top_up/guest_top_up/repository/guest_top_up_repository.dart
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class GuestTopUpVerifyResult {
  final String? accountStatus;
  final String? paymentOption;
  const GuestTopUpVerifyResult({this.accountStatus, this.paymentOption});
}

class GuestTopUpRepository {
  const GuestTopUpRepository();

  /// NO API: stub method (same idea as your LoginRepository)
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Calls Guest/balance and returns both AccountStatus and PaymentOption.
  Future<GuestTopUpVerifyResult> verifyNumber(String phoneNumber) async {
    final rawPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final networkService = instance<NetworkService>();
    final response = await networkService.request<dynamic>(
      Api.guestBalanceUrl,
      method: HttpMethod.post,
      data: <String, dynamic>{
        'ChannelType': 'SelfCare',
        'PhoneNumber': rawPhone,
      },
      options: Options(extra: {'skipAuth': true}),
    );
    final data = response.data;
    if (data is! Map) return const GuestTopUpVerifyResult();
    final statusRaw = data['AccountStatus'] ?? data['accountStatus'];
    final paymentRaw = data['PaymentOption'] ?? data['paymentOption'];
    return GuestTopUpVerifyResult(
      accountStatus: statusRaw is String ? statusRaw.trim() : null,
      paymentOption: paymentRaw is String ? paymentRaw.trim() : null,
    );
  }
}
