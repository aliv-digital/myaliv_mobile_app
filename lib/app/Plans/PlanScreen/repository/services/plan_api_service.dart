import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/shared/repository/services/base_plan_api_client.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Service for fetching plan data from API
///
/// Extends BasePlanApiClient to inherit:
/// - Authentication handling
/// - Error mapping
/// - Debug logging
class PlanApiService extends BasePlanApiClient {
  PlanApiService({
    super.networkService,
    super.authManager,
  }) : super(debugName: 'plan-api-service');

  /// Fetch raw plans JSON from API
  Future<String> fetchRawPlansJson() async {
    final auth = requireAuth(); // Throws if not authenticated

    debugLog('Fetching plans for device=${auth.deviceAccountID}');

    final response = await networkService.request<String>(
      "${Api.getAllPlans}/${auth.deviceAccountID}/available-plans",
      method: HttpMethod.get,
    );

    debugLog('Response status=${response.statusCode}');

    validateResponse(
      statusCode: response.statusCode,
      responseBody: response.data,
    );

    return response.data ?? '';
  }

  /// Fetch raw bundles JSON from API
  Future<String> fetchRawBundlesJson() async {
    final auth = requireAuth(); // Throws if not authenticated

    debugLog('Fetching bundles for device=${auth.deviceAccountID}');

    final response = await networkService.request<String>(
      "${Api.getBundles}/${auth.deviceAccountID}/bundles",
      method: HttpMethod.get,
    );

    debugLog('Bundles response status=${response.statusCode}');

    validateResponse(
      statusCode: response.statusCode,
      responseBody: response.data,
    );

    return response.data ?? '';
  }

  /// Check if API is reachable
  Future<bool> checkConnectivity() async {
    try {
      // Try to get auth first
      final auth = authManager.getCurrentAuth();
      if (auth == null || !auth.isAuthenticated) {
        return false;
      }

      // Simple GET request to check connectivity
      final response = await networkService.request<String>(
        "${Api.getAllPlans}/${auth.deviceAccountID}/available-plans",
        method: HttpMethod.get,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
