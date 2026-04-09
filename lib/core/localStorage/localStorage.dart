import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _accountInfoKey = 'account_info_json';

  // Store an integer value
  static Future<void> storeIntValue({
    required String key,
    required int value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  // ticket works as password
  static Future<void> storeTicket({required String ticket}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ticket', ticket);
  }

  static Future<String?> getTicket() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('ticket');
  }

  static Future<void> storeAccountID({required String accountID}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accountID', accountID);
  }

  static Future<String?> getAccountID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accountID');
  }

  /// Stores the complete account response map as JSON.
  static Future<void> storeAccountInfoMap({
    required Map<String, dynamic> accountInfo,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountInfoKey, jsonEncode(accountInfo));
  }

  /// Returns the raw JSON string if account info was cached.
  static Future<String?> getAccountInfoJson() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accountInfoKey);
  }

  /// Returns decoded account map. Always safe: returns empty map on bad/missing data.
  static Future<Map<String, dynamic>> getAccountInfoMap() async {
    final raw = await getAccountInfoJson();
    return _decodeJsonMap(raw);
  }

  /// Reads a single value from cached account info.
  ///
  /// Supports dotted paths for nested objects, e.g.:
  /// - PhoneNumber
  /// - IdentificationInfo.NINumber
  static Future<dynamic> getAccountInfoValue({required String path}) async {
    final data = await getAccountInfoMap();
    return _readValueByPath(data, path);
  }

  // Get an integer value
  static Future<int?> getSelectedActiveEventId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('activeEventID');
  }

  // Get an integer value
  static Future<int?> getIntValue({required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  // Store a String value
  static Future<void> storeStringValue({
    required String key,
    required String value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<void> storePassword({required String password}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password);
  }

  static Future<String?> getPassword() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('password');
  }

  static Future<void> storeAccessToken({required String accessToken}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
  }

  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // Remove a specific key-value pair
  static Future<void> deleteAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }

  // Get a String value
  static Future<String?> getStringValue({required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Store a boolean value
  static Future<void> storeBoolValue({
    required String key,
    required bool value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Get a boolean value
  static Future<bool?> getBoolValue({required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  // Store a double value
  static Future<void> storeDoubleValue({
    required String key,
    required double value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  // Get a double value
  static Future<double?> getDoubleValue({required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  // Store a list of strings
  static Future<void> storeStringListValue({
    required String key,
    required List<String> value,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  // Get a list of strings
  static Future<List<String>?> getStringListValue({required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  // Remove a specific key-value pair
  static Future<void> removeValue({required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Map<String, dynamic> _decodeJsonMap(String? raw) {
    if (raw == null || raw.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        final mapped = <String, dynamic>{};
        for (final entry in decoded.entries) {
          mapped[entry.key.toString()] = entry.value;
        }
        return mapped;
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static dynamic _readValueByPath(Map<String, dynamic> source, String path) {
    if (path.trim().isEmpty) return null;
    dynamic current = source;

    for (final segment in path.split('.')) {
      if (current is Map<String, dynamic>) {
        if (current.containsKey(segment)) {
          current = current[segment];
          continue;
        }

        // Fallback: allow case-insensitive key lookup.
        final lowerSegment = segment.toLowerCase();
        String? matchedKey;
        for (final key in current.keys) {
          if (key.toLowerCase() == lowerSegment) {
            matchedKey = key;
            break;
          }
        }
        if (matchedKey == null) return null;
        current = current[matchedKey];
        continue;
      }

      return null;
    }

    return current;
  }
}
