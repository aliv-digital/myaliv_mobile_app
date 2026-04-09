import 'package:myaliv_mobile_app/app/Plans/shared/repository/services/base_plan_json_parser.dart';

/// Postpaid plans JSON parser.
///
/// Extends BasePlanJsonParser to inherit background parsing capabilities.
/// Provides backwards-compatible method names for existing code.
class HomePlansPostPaidJsonParser extends BasePlanJsonParser {
  HomePlansPostPaidJsonParser() : super(debugName: 'postpaid');

  /// Parse raw JSON string into normalized plan list
  ///
  /// Alias for parseList() - for backwards compatibility.
  Future<List<Map<String, dynamic>>> parse(String rawJson) => parseList(rawJson);
}
