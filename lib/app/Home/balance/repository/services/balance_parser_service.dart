import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Home/balance/models/balance_model.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/balance_repository_exception.dart';

/// Service for parsing balance JSON responses
///
/// Handles JSON parsing and extraction of wallet and bonus balances.
/// Filters and validates data structure.
class BalanceParserService {
  /// Parse raw JSON response to BalanceModel
  ///
  /// Expected JSON structure:
  /// ```json
  /// [
  ///   {
  ///     "Balance": "69.85",
  ///     "BalanceGroupName": "Wallet",
  ///     "Balances": [...]
  ///   },
  ///   {
  ///     "Balance": "0",
  ///     "BalanceGroupName": "Bonus",
  ///     "Balances": [...]
  ///   }
  /// ]
  /// ```
  ///
  /// Extracts:
  /// - Wallet balance from "Wallet" group
  /// - Bonus balance from "Bonus" group (total)
  /// - Individual bonus details from Bonus.Balances array
  ///
  /// Throws [BalanceParseException] on parsing errors
  BalanceModel parseBalances(String jsonString) {
    if (kDebugMode) {
      debugPrint('');
      debugPrint('🔍 BALANCE PARSER: Starting to parse JSON');
    }

    try {
      // Decode JSON
      final dynamic decoded = jsonDecode(jsonString);

      if (kDebugMode) {
        debugPrint('✓ JSON decoded successfully');
      }

      // Validate root structure (should be array)
      if (decoded is! List) {
        throw const BalanceParseException(
          'Invalid JSON structure: expected array at root',
        );
      }

      final List<dynamic> data = decoded;

      if (kDebugMode) {
        debugPrint('✓ Data array found with ${data.length} items');
      }

      double walletBalance = 0.0;
      double bonusBalance = 0.0;
      List<BonusDetail> bonusDetails = [];

      // Parse each balance group
      for (int i = 0; i < data.length; i++) {
        final item = data[i];

        if (item is! Map<String, dynamic>) {
          if (kDebugMode) {
            debugPrint('⚠️ Skipping item $i - not a valid object');
          }
          continue;
        }

        final groupName = item['BalanceGroupName'] as String?;
        final balanceValue = item['Balance'] as String?;

        if (kDebugMode) {
          debugPrint('  Processing group: $groupName, balance: $balanceValue');
        }

        // Extract Wallet balance
        if (groupName == 'Wallet') {
          walletBalance = double.tryParse(balanceValue ?? '0') ?? 0.0;
          if (kDebugMode) {
            debugPrint('  ✓ Wallet balance: \$${walletBalance.toStringAsFixed(2)}');
          }
        }

        // Extract Bonus balance and details
        if (groupName == 'Bonus') {
          bonusBalance = double.tryParse(balanceValue ?? '0') ?? 0.0;
          if (kDebugMode) {
            debugPrint(
              '  ✓ Bonus balance (total): \$${bonusBalance.toStringAsFixed(2)}',
            );
          }

          // Parse individual bonus items
          final balances = item['Balances'] as List?;
          if (balances != null) {
            for (final bonusItem in balances) {
              if (bonusItem is Map<String, dynamic>) {
                try {
                  final detail = BonusDetail.fromJson(bonusItem);

                  // Only include active bonuses
                  if (detail.isActive) {
                    bonusDetails.add(detail);
                    if (kDebugMode) {
                      debugPrint(
                        '    ✓ Bonus: ${detail.displayName} = \$${detail.balanceAmount}',
                      );
                    }
                  }
                } catch (e) {
                  if (kDebugMode) {
                    debugPrint('    ⚠️ Failed to parse bonus item: $e');
                  }
                  continue;
                }
              }
            }
          }
        }
      }

      if (kDebugMode) {
        debugPrint('');
        debugPrint('📊 PARSER RESULT:');
        debugPrint('   Wallet Balance: \$${walletBalance.toStringAsFixed(2)}');
        debugPrint('   Bonus Balance: \$${bonusBalance.toStringAsFixed(2)}');
        debugPrint('   Active Bonus Items: ${bonusDetails.length}');
        debugPrint('');
      }

      return BalanceModel(
        walletBalance: walletBalance,
        bonusBalance: bonusBalance,
        bonusDetails: bonusDetails,
        fetchedAt: DateTime.now(),
      );
    } on BalanceParseException {
      rethrow;
    } catch (e) {
      throw BalanceParseException(
        'Failed to parse balances: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
