import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../../../../core/localStorage/localStorage.dart';
import '../../loginOtp/model/account_info_model.dart';
import '../../loginOtp/repository/services/otp_json_parser.dart';
import 'account_info_exception.dart';
import 'base_account_info_repository.dart';
import 'services/account_info_api_client.dart';

/// Account information repository - using service composition.
///
/// This repository orchestrates:
/// - AuthManager: Provides credentials from storage
/// - AccountInfoApiClient: Handles API calls
/// - OtpJsonParser: Parses JSON responses (reused from loginOtp)
class AccountInfoRepository implements BaseAccountInfoRepository {
  AccountInfoRepository({
    required AuthManager authManager,
    AccountInfoApiClient? apiClient,
    OtpJsonParser? jsonParser,
  }) : _authManager = authManager,
       _apiClient = apiClient ?? AccountInfoApiClient(),
       _jsonParser = jsonParser ?? OtpJsonParser();

  final AuthManager _authManager;
  final AccountInfoApiClient _apiClient;
  final OtpJsonParser _jsonParser;

  @override
  Future<AccountInfoModel> fetchAccountInfo() async {
    if (kDebugMode) {
      debugPrint('AccountInfoRepository: Fetching account info');
    }

    // Note: NetworkService automatically uses credentials from GlobalState
    // (managed by AuthManager), so no need to fetch or pass them here.

    // Make API call - auth headers added automatically by NetworkService
    final rawJson = await _apiClient.fetchAccountInfo();

    // Parse response
    final accountInfo = _jsonParser.parseAccountInfo(rawJson);

    if (kDebugMode) {
      debugPrint('AccountInfoRepository: Account info parsed successfully');
    }

    return accountInfo;
  }
}
