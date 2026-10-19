import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class RewardsApiClient {
  RewardsApiClient({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  Future<String> fetchRewards(int deviceId) async {
    if (kDebugMode) {
      debugPrint(
        'RewardsApiClient: Fetching available SUGs for device $deviceId',
      );
    }

    try {
      final response = await _networkService.request<String>(
        Api.availableSugs(deviceId),
        method: HttpMethod.get,
      );

      if (kDebugMode) {
        debugPrint('RewardsApiClient: Response status=${response.statusCode}');
      }

      if (response.data is String) {
        return response.data!;
      } else {
        return jsonEncode(response.data);
      }
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch available SUGs: $e');
    }
  }
}
