import 'package:flutter/foundation.dart';
import '../../loginOtp/model/account_info_model.dart';
import '../../loginOtp/repository/services/otp_json_parser.dart';
import 'base_account_info_repository.dart';
import 'services/account_info_api_client.dart';

/// Account information repository - using service composition.
///
/// This repository orchestrates:
/// - AccountInfoApiClient: Handles API calls with auth from NetworkService
/// - OtpJsonParser: Parses JSON responses (reused from loginOtp)
///
/// Note: Authentication is handled automatically by NetworkService using
/// GlobalState (managed by AuthManager). No credential passing needed.
class AccountInfoRepository implements BaseAccountInfoRepository {
  AccountInfoRepository({
    AccountInfoApiClient? apiClient,
    OtpJsonParser? jsonParser,
  }) : _apiClient = apiClient ?? AccountInfoApiClient(),
       _jsonParser = jsonParser ?? OtpJsonParser();

  final AccountInfoApiClient _apiClient;
  final OtpJsonParser _jsonParser;

  @override
  Future<AccountInfoModel> fetchAccountInfo() async {
    debugPrint('AccountInfoRepository: Fetching account info');

    // 1. Make API call (auth headers added automatically by NetworkService)
    final rawJson = await _apiClient.fetchAccountInfo();

    // 2. Parse response
    final accountInfo = _jsonParser.parseAccountInfo(rawJson);

    debugPrint('AccountInfoRepository: Account info parsed successfully');

    return accountInfo;
  }
}
