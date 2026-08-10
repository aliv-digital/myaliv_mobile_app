import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/shared/repository/services/base_plan_api_client.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Service for fetching plan data from API
class PlanApiService extends BasePlanApiClient {
  PlanApiService({
    super.networkService,
    super.authManager,
  }) : super(debugName: 'plan-api-service');

  Future<String> fetchRawPlansJson() async {
    final deviceId = requireDeviceAccountId();

    debugLog('Fetching plans for device=$deviceId');

    final response = await networkService.request<String>(
      "${Api.getAllPlans}/$deviceId/available-plans",
      method: HttpMethod.get,
    );

    debugLog('Response status=${response.statusCode}');

    validateResponse(
      statusCode: response.statusCode,
      responseBody: response.data,
    );

    return response.data ?? '';
  }

  Future<String> fetchRawBundlesJson() async {
    final deviceId = requireDeviceAccountId();

    debugLog('Fetching bundles for device=$deviceId');

    final response = await networkService.request<String>(
      "${Api.getBundles}/$deviceId/bundles",
      method: HttpMethod.get,
    );

    debugLog('Bundles response status=${response.statusCode}');

    validateResponse(
      statusCode: response.statusCode,
      responseBody: response.data,
    );

    return response.data ?? '';
  }

  Future<bool> checkConnectivity() async {
    try {
      if (authManager.currentSession == null) return false;
      final deviceId = requireDeviceAccountId();

      final response = await networkService.request<String>(
        "${Api.getAllPlans}/$deviceId/available-plans",
        method: HttpMethod.get,
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
