import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Handles API calls used by the Usage screen.
///
/// Widgets should not build URLs or know about HTTP methods directly. Keeping
/// that detail here makes the UI easier to read and easier to test later.
class UsageRepository {
  UsageRepository({NetworkService? networkService})
      : _networkService = networkService;

  final NetworkService? _networkService;

  /// Starts the user's queued future plan immediately.
  ///
  /// [deviceAccountId] scopes the request to the active device account.
  /// Returns true when the backend accepts the request with a 2xx response.
  /// Throws [UsageRepositoryException] with a user-facing message on failure.
  Future<bool> jumpStartFuturePlan({required int deviceAccountId}) async {
    if (deviceAccountId <= 0) {
      throw const UsageRepositoryException('Account information not available');
    }

    try {
      final networkService = _networkService ?? instance<NetworkService>();
      final response = await networkService.request<dynamic>(
        '${Api.startFuturePlan}/$deviceAccountId/jump-start-future-plan',
        method: HttpMethod.put,
      );

      final statusCode = response.statusCode ?? 0;
      return statusCode >= 200 && statusCode < 300;
    } on NetworkException catch (error) {
      throw UsageRepositoryException(_friendlyNetworkMessage(error));
    } catch (_) {
      throw const UsageRepositoryException(
        'Failed to start future plan. Please try again.',
      );
    }
  }

  String _friendlyNetworkMessage(NetworkException error) {
    final message = error.message.trim();

    if (error is NoInternetException) {
      return 'No internet connection. Please check and try again.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    if (error is SessionExpiredException || error.statusCode == 401) {
      return 'Session expired. Please login again.';
    }

    if (message.isNotEmpty && message != 'An error occurred') {
      return message;
    }

    return 'Failed to start future plan. Please try again.';
  }
}

class UsageRepositoryException implements Exception {
  const UsageRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
