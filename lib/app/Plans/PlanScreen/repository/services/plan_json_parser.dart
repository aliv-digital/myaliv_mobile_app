import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Top-level function for background JSON parsing
///
/// Required for use with compute() isolate.
List<Map<String, dynamic>> parsePlansJsonInBackground(String rawJson) {
  final dynamic decoded = jsonDecode(rawJson);

  if (decoded is! List) {
    throw const FormatException('Expected JSON array for plans response');
  }

  return decoded
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic> parseBundlesJsonInBackground(String rawJson) {
  final dynamic decoded = jsonDecode(rawJson);

  if (decoded is! Map) {
    throw const FormatException('Expected JSON object for bundles response');
  }

  return decoded.map(
    (dynamic key, dynamic value) =>
        MapEntry<String, dynamic>(key.toString(), value),
  );
}

/// Parses plan JSON data
///
/// Uses background isolate for large JSON to avoid UI jank.
class PlanJsonParser {
  /// Parse raw JSON string into normalized plan list
  ///
  /// Performs parsing in background isolate using compute().
  Future<List<Map<String, dynamic>>> parse(String rawJson) async {
    try {
      return await compute(parsePlansJsonInBackground, rawJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PlanJsonParser: Failed to parse - $e');
      }
      rethrow;
    }
  }

  /// Parse raw bundles JSON string into normalized root map.
  Future<Map<String, dynamic>> parseBundles(String rawJson) async {
    try {
      return await compute(parseBundlesJsonInBackground, rawJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PlanJsonParser: Failed to parse bundles - $e');
      }
      rethrow;
    }
  }
}
