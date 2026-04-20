import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/model/reward_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/repository/services/rewards_api_client.dart';

/// Repository for rewards data.
///
/// Handles data fetching and parsing from API.
class RewardPrepaidRepository {
  RewardPrepaidRepository({RewardsApiClient? apiClient})
      : _apiClient = apiClient ?? RewardsApiClient();

  final RewardsApiClient _apiClient;

  /// Fetches all rewards from the API.
  ///
  /// Returns a list of [RewardModel] sorted by sortOrder.
  Future<List<RewardModel>> fetchRewards() async {
    if (kDebugMode) {
      debugPrint('RewardPrepaidRepository: Fetching rewards');
    }

    final rawJson = await _apiClient.fetchRewards();
    final rewards = _parseRewards(rawJson);

    if (kDebugMode) {
      debugPrint('RewardPrepaidRepository: Parsed ${rewards.length} rewards');
    }

    return rewards;
  }

  /// Parses JSON response into list of RewardModel.
  List<RewardModel> _parseRewards(String rawJson) {
    final decoded = jsonDecode(rawJson);

    if (decoded is List) {
      final rewards = decoded
          .map((item) => RewardModel.fromJson(item as Map<String, dynamic>))
          .toList();
      // Sort by sortOrder
      rewards.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return rewards;
    }

    return [];
  }
}
