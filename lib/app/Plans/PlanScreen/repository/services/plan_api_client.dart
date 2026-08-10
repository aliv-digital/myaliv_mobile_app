import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/shared/repository/services/base_plan_api_client.dart';
import '../../../../../../core/networkService/api_paths.dart';

/// Handles API calls for prepaid plan data.
class PlanApiClient extends BasePlanApiClient {
  PlanApiClient({super.networkService, super.authManager})
      : super(debugName: 'prepaid');

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
}
