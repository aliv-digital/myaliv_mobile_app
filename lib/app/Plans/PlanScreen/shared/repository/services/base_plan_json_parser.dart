import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Top-level functions for background JSON parsing
/// (Required for use with compute() isolate)

/// Parse JSON array in background isolate
List<Map<String, dynamic>> parseListJsonInBackground(String rawJson) {
  final dynamic decoded = jsonDecode(rawJson);

  if (decoded is! List) {
    throw const FormatException('Expected JSON array for plans response');
  }

  return decoded
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

/// Parse JSON object in background isolate
Map<String, dynamic> parseMapJsonInBackground(String rawJson) {
  final dynamic decoded = jsonDecode(rawJson);

  if (decoded is! Map) {
    throw const FormatException('Expected JSON object for response');
  }

  return decoded.map(
    (dynamic key, dynamic value) =>
        MapEntry<String, dynamic>(key.toString(), value),
  );
}

/// Base JSON parser for all plan services.
///
/// Performs parsing in background isolate using compute() to avoid UI jank
/// on large JSON responses.
///
/// Benefits:
/// - Consistent JSON parsing across all plan services
/// - Automatic background processing for better performance
/// - Better error handling and debugging
/// - Reduced code duplication
///
/// Usage:
/// ```dart
/// class MyJsonParser extends BasePlanJsonParser {
///   MyJsonParser() : super(debugName: 'my-service');
/// }
/// ```
class BasePlanJsonParser {
  const BasePlanJsonParser({this.debugName});

  /// Optional name for debug logging (e.g., 'prepaid', 'postpaid')
  final String? debugName;

  /// Parse raw JSON string into normalized list
  ///
  /// Uses background isolate for better performance on large responses.
  /// Throws FormatException if JSON is not an array.
  Future<List<Map<String, dynamic>>> parseList(String rawJson) async {
    try {
      return await compute(parseListJsonInBackground, rawJson);
    } catch (e) {
      if (kDebugMode) {
        final prefix = debugName != null ? '$debugName: ' : '';
        debugPrint('${prefix}BasePlanJsonParser: Failed to parse list - $e');
      }
      rethrow;
    }
  }

  /// Parse raw JSON string into normalized map
  ///
  /// Uses background isolate for better performance on large responses.
  /// Throws FormatException if JSON is not an object.
  Future<Map<String, dynamic>> parseMap(String rawJson) async {
    try {
      return await compute(parseMapJsonInBackground, rawJson);
    } catch (e) {
      if (kDebugMode) {
        final prefix = debugName != null ? '$debugName: ' : '';
        debugPrint('${prefix}BasePlanJsonParser: Failed to parse map - $e');
      }
      rethrow;
    }
  }
}
