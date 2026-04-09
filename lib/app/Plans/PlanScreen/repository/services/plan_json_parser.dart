import 'package:myaliv_mobile_app/app/Plans/shared/repository/services/base_plan_json_parser.dart';

/// Prepaid plans JSON parser.
///
/// Extends BasePlanJsonParser to inherit background parsing capabilities.
/// Provides backwards-compatible method names for existing code.
class PlanJsonParser extends BasePlanJsonParser {
  PlanJsonParser() : super(debugName: 'prepaid');

  /// Parse raw JSON string into normalized plan list
  ///
  /// Alias for parseList() - for backwards compatibility.
  Future<List<Map<String, dynamic>>> parse(String rawJson) => parseList(rawJson);

  /// Parse raw bundles JSON string into normalized root map
  ///
  /// Alias for parseMap() - for backwards compatibility.
  Future<Map<String, dynamic>> parseBundles(String rawJson) => parseMap(rawJson);
}
