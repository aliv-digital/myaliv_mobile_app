import 'dart:convert';

import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

import '../models/refer_friend_prepaid_models.dart';

class ReferFriendPrepaidRepository {
  ReferFriendPrepaidRepository({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  Future<void> shareReferral({
    required String friendPhone,
    required String friendEmail,
  }) async {
    // TODO: API integration later
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> redeemReferral({required String code}) async {
    // TODO: API integration later
    await Future.delayed(const Duration(milliseconds: 600));

    // demo validation
    if (code.trim().length < 5) {
      throw Exception('invalid');
    }
  }

  Future<String> postReferAFriend({
    required String deviceAccountID,
    required String userPhone,
    required String email,
  }) async {
    final parsedDeviceAccountId = int.tryParse(deviceAccountID.trim());
    final requestBody = <String, dynamic>{
      'ReferringDeviceAccountId': parsedDeviceAccountId ?? deviceAccountID.trim(),
      'ReferredEmail': email.trim(),
      'ReferredTN': userPhone.trim(),
    };

    final response = await _networkService.request<dynamic>(
      Api.referAFriend,
      method: HttpMethod.post,
      data: requestBody,
    );

    final responseMap = _decodeResponseMap(response.data);
    final referralCode = _readStringValue(responseMap, 'ReferralCode');

    if (referralCode.isEmpty) {
      throw Exception('Referral code missing in response.');
    }

    return referralCode;
  }

  Future<bool> isValidReferral({required String userPhoneNumber}) async {
    final encodedPhoneNumber = Uri.encodeComponent(userPhoneNumber.trim());
    final api = '${Api.isReferralValid}/$encodedPhoneNumber/valid';

    final response = await _networkService.request<dynamic>(
      api,
      method: HttpMethod.get,
    );

    final responseMap = _decodeResponseMap(response.data);
    final validValue = responseMap['IsValid'] ?? responseMap['isValid'];

    if (validValue is bool) {
      return validValue;
    }

    if (validValue is String) {
      return validValue.toLowerCase() == 'true';
    }

    throw Exception('Referral validity missing in response.');
  }

  Future<List<ReferralHistoryItem>> fetchHistory() async {
    // TODO: API integration later
    await Future.delayed(const Duration(milliseconds: 350));

    return const [
      ReferralHistoryItem(
        code: '0002391',
        email: 'Jade123@hotmail.com',
        sentDate: '12/02/2024',
        acceptedDate: 'Pending',
        expiryLabel: 'Exp: 12/02/2024',
      ),
      ReferralHistoryItem(
        code: '0002391',
        email: 'Jade123@hotmail.com',
        sentDate: '12/02/2024',
        acceptedDate: '12/02/2024',
      ),
      ReferralHistoryItem(
        code: '0002391',
        email: 'Jade123@hotmail.com',
        sentDate: '12/02/2024',
        acceptedDate: '12/02/2024',
      ),
    ];
  }

  Map<String, dynamic> _decodeResponseMap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    if (responseData is Map) {
      return responseData.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      final decoded = jsonDecode(responseData);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    }

    return <String, dynamic>{};
  }

  String _readStringValue(Map<String, dynamic> source, String key) {
    final value = source[key] ?? source[_lowerFirst(key)];
    return value?.toString().trim() ?? '';
  }

  String _lowerFirst(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toLowerCase() + value.substring(1);
  }
}
