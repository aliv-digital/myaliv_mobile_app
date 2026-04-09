import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Plans/shared/repository/services/base_plan_api_client.dart';
import '../../../../../../core/networkService/api_paths.dart';

/// Handles API calls for postpaid roaming plan data.
///
/// Extends BasePlanApiClient to inherit:
/// - Authentication handling
/// - Error mapping
/// - Debug logging
class HomePlansPostPaidApiClient extends BasePlanApiClient {
  HomePlansPostPaidApiClient({super.networkService, super.authManager})
    : super(debugName: 'postpaid');

  /// Fetch raw plans JSON from API
  ///
  /// Returns the raw response body as a string.
  /// Throws [BasePlanRepositoryException] on errors.
  Future<String> fetchRawPlansJson() async {
    final auth = requireAuth(); // Throws if not authenticated

    debugLog('Fetching plans for device=${auth.deviceAccountID}');

    final response = await networkService.request<String>(
      '${Api.getAllPlans}/${auth.deviceAccountID}/available-plans',
      method: HttpMethod.get,
    );

    debugLog('Response status=${response.statusCode}');

    validateResponse(
      statusCode: response.statusCode,
      responseBody: response.data,
    );

    return response.data ?? '';
  }
}
