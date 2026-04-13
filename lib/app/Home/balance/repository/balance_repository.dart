import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/balance/models/balance_model.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/balance_repository_exception.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/services/balance_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/services/balance_parser_service.dart';

/// Abstract interface for Balance data operations
abstract class BalanceRepository {
  /// Fetch balances from API
  ///
  /// [deviceAccountId] - The account ID for the device
  /// Returns BalanceModel with wallet and bonus balances
  /// Throws [BalanceRepositoryException] on errors
  Future<BalanceModel> fetchBalances({required int deviceAccountId});
}

/// Implementation of BalanceRepository
///
/// Orchestrates API calls and JSON parsing.
/// Combines wallet and bonus balances into a single model.
class BalanceRepositoryImpl implements BalanceRepository {
  final BalanceApiService _apiService;
  final BalanceParserService _parserService;

  BalanceRepositoryImpl({
    required BalanceApiService apiService,
    required BalanceParserService parserService,
  })  : _apiService = apiService,
        _parserService = parserService;

  @override
  Future<BalanceModel> fetchBalances({required int deviceAccountId}) async {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('🏪 BALANCE REPOSITORY: Fetching balances');
      debugPrint('   Account ID: $deviceAccountId');
    }

    try {
      // Step 1: Fetch raw JSON from API
      final rawJson = await _apiService.fetchBalances(
        deviceAccountId: deviceAccountId,
      );

      if (kDebugMode) {
        debugPrint('✓ API call successful, parsing response...');
      }

      // Step 2: Parse JSON to model
      final balance = _parserService.parseBalances(rawJson);

      if (kDebugMode) {
        debugPrint('✓ Parsing complete');
        debugPrint('   Wallet: \$${balance.walletBalance.toStringAsFixed(2)}');
        debugPrint('   Bonus: \$${balance.bonusBalance.toStringAsFixed(2)}');
        debugPrint('');
      }

      return balance;
    } on BalanceRepositoryException {
      if (kDebugMode) {
        debugPrint('❌ Repository error occurred');
        debugPrint('');
      }
      rethrow;
    } on BalanceParseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Parsing error occurred: $e');
        debugPrint('');
      }

      throw BalanceRepositoryException(
        'Failed to parse balances: ${e.message}',
        type: BalanceErrorType.parsing,
        originalError: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unknown error occurred: $e');
        debugPrint('');
      }

      throw BalanceRepositoryException(
        'Unexpected error: ${e.toString()}',
        type: BalanceErrorType.unknown,
        originalError: e,
      );
    }
  }
}
