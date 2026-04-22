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

  Future<void> redeemReferral({
    required String code,
    required String referredNumber,
  }) async {
    final trimmedCode = code.trim();
    final trimmedReferredNumber = referredNumber.trim();

    if (trimmedCode.isEmpty || trimmedReferredNumber.isEmpty) {
      throw const ReferFriendPrepaidException(
        'Referral code or phone number is missing.',
      );
    }

    final requestBody = <String, dynamic>{
      'ReferralCode': trimmedCode,
      'ReferredTN': trimmedReferredNumber,
    };

    try {
      await _networkService.request<dynamic>(
        Api.redeemReferral,
        method: HttpMethod.post,
        data: requestBody,
      );
    } on NetworkException catch (error) {
      throw ReferFriendPrepaidException(_redeemReferralErrorMessage(error));
    } on ReferFriendPrepaidException {
      rethrow;
    } catch (_) {
      throw const ReferFriendPrepaidException(
        'Could not redeem referral. Try again.',
      );
    }
  }

  Future<String> postReferAFriend({
    required String deviceAccountID,
    required String referredNumber,
    required String email,
  }) async {
    final parsedDeviceAccountId = int.tryParse(deviceAccountID.trim());
    final requestBody = <String, dynamic>{
      'ReferringDeviceAccountId':
          parsedDeviceAccountId ?? deviceAccountID.trim(),
      'ReferredEmail': email.trim(),
      'ReferredTN': referredNumber.trim(),
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
      return responseData.map((key, value) => MapEntry(key.toString(), value));
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      final decoded = jsonDecode(responseData);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
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

  String _redeemReferralErrorMessage(NetworkException error) {
    final statusCode = error.statusCode;

    if (statusCode == 400 || statusCode == 404) {
      return 'Invalid referral code.';
    }

    if (statusCode == 401) {
      return 'Session expired. Please log in again.';
    }

    if (statusCode != null && statusCode >= 500) {
      return 'Could not redeem referral. Try again.';
    }

    final message = error.message.trim();
    if (message.isNotEmpty && message != 'An error occurred') {
      return message;
    }

    return 'Could not redeem referral. Try again.';
  }
}

class ReferFriendPrepaidException implements Exception {
  final String message;

  const ReferFriendPrepaidException(this.message);

  @override
  String toString() => message;
}
