import 'dart:convert';

import 'package:flutter/foundation.dart';

List<Map<String, dynamic>> parseHomePlansPostPaidJsonInBackground(
  String rawJson,
) {
  final dynamic decoded = jsonDecode(rawJson);

  if (decoded is! List) {
    throw const FormatException('Expected JSON array for plans response');
  }

  return decoded
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

class HomePlansPostPaidJsonParser {
  Future<List<Map<String, dynamic>>> parse(String rawJson) async {
    try {
      return await compute(parseHomePlansPostPaidJsonInBackground, rawJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HomePlansPostPaidJsonParser: Failed to parse - $e');
      }
      rethrow;
    }
  }
}
