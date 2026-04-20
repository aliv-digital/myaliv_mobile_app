import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Handles API calls for rewards operations.
///
/// Uses NetworkService which automatically handles Basic Auth from GlobalState.
class RewardsApiClient {
  RewardsApiClient({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// Fetches all rewards from the API.
  ///
  /// Returns raw JSON response string on success.
  /// Throws [NetworkException] on errors.
  Future<String> fetchRewards() async {
    if (kDebugMode) {
      debugPrint('RewardsApiClient: Fetching rewards');
    }

    try {
      final response = await _networkService.request<String>(
        Api.rewards,
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
      throw Exception('Failed to fetch rewards: $e');
    }
  }
}
