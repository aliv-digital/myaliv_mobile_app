import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/model/reward_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/repository/services/rewards_api_client.dart';
import 'package:myaliv_mobile_app/core/appConfig/active_device.dart';

class RewardPrepaidRepository {
  RewardPrepaidRepository({RewardsApiClient? apiClient})
    : _apiClient = apiClient ?? RewardsApiClient();

  final RewardsApiClient _apiClient;

  Future<List<RewardModel>> fetchRewards() async {
    final deviceId = ActiveDevice.id() ?? 0;

    if (kDebugMode) {
      debugPrint('RewardPrepaidRepository: Fetching SUGs for device $deviceId');
    }

    final rawJson = await _apiClient.fetchRewards(deviceId);
    final rewards = _parseRewards(rawJson);

    if (kDebugMode) {
      debugPrint('RewardPrepaidRepository: Parsed ${rewards.length} SUGs');
    }

    return rewards;
  }

  List<RewardModel> _parseRewards(String rawJson) {
    final decoded = jsonDecode(rawJson);

    if (decoded is List) {
      return decoded
          .map((item) => RewardModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
