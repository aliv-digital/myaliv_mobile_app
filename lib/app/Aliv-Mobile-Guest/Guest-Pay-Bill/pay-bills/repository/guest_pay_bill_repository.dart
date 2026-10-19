import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

import '../model/guest_pay_bill_models.dart';

class GuestPayBillRepository {
  Future<List<BillService>> fetchServices() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const [
      BillService(code: 'ALIV_POSTPAID', label: 'ALIV Postpaid'),
      BillService(code: 'ALIV_FIBR', label: 'ALIVFibr'),
      BillService(code: 'REV', label: 'REV'),
    ];
  }

  Future<PayBillAccountInfo> verifyAlivPostpaid({
    required String mobileNumber,
    required String confirmMobileNumber,
  }) async {
    final rawPhone = mobileNumber.replaceAll(RegExp(r'\D'), '');

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
    final balance = (data is Map ? (data['Balance'] ?? data['balance']) : null);
    final statusRaw = data is Map
        ? (data['AccountStatus'] ?? data['accountStatus'])
        : null;
    final status = (statusRaw is String && statusRaw.trim().isNotEmpty)
        ? statusRaw.trim()
        : 'unidentified';
    final paymentOptionRaw = data is Map
        ? (data['PaymentOption'] ?? data['paymentOption'])
        : null;

    return PayBillAccountInfo(
      status: status,
      balance: balance is num ? balance.toDouble() : null,
      paymentOption: paymentOptionRaw is String
          ? paymentOptionRaw.trim()
          : null,
    );
  }

  Future<PayBillAccountInfo> verifyRev({
    required String accountNumber,
    required String enteredName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (accountNumber.trim().length >= 8) {
      return const PayBillAccountInfo(
        status: 'Active',
        name: 'James Bain',
        balance: 200.00,
      );
    }

    throw Exception('Account not found');
  }

  Future<PayBillAccountInfo> verifyAlivFibr({
    required String accountNumberOrUsername,
    required String enteredName,
  }) async {
    final networkService = instance<NetworkService>();
    final response = await networkService.request<dynamic>(
      Api.guestFibrBalanceUrl,
      method: HttpMethod.post,
      data: <String, dynamic>{
        'ChannelType': 'SelfCare',
        'FibrName': enteredName.trim().toUpperCase(),
        'FibrAccountID': accountNumberOrUsername.trim(),
      },
      options: Options(extra: {'skipAuth': true}),
    );

    final data = response.data;
    final idAcc = data is Map ? (data['id_acc'] ?? data['Id_acc']) : null;
    final balance = data is Map ? (data['Balance'] ?? data['balance']) : null;
    final statusRaw = data is Map
        ? (data['AccountStatus'] ?? data['accountStatus'])
        : null;

    return PayBillAccountInfo(
      status: (statusRaw is String && statusRaw.trim().isNotEmpty)
          ? statusRaw.trim()
          : 'unidentified',
      balance: balance is num ? balance.toDouble() : null,
      fibrAccountId: idAcc is num ? idAcc.toInt() : null,
    );
  }

  Future<void> submitBillPayment({
    required String serviceCode,
    required String identifier, // phone or account number
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return;
  }
}
