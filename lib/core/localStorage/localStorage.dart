import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  // Store an integer value
  static Future<void> storeIntValue({required String key, required int value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }




  static Future<void> storeSelectedActiveEventID({required int eventID}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('activeEventID', eventID);
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
  static Future<void> storeStringValue({required String key, required String value}) async {
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
  static Future<void> storeBoolValue({required String key, required bool value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Get a boolean value
  static Future<bool?> getBoolValue({required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  // Store a double value
  static Future<void> storeDoubleValue({required String key, required double value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  // Get a double value
  static Future<double?> getDoubleValue({required String key}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  // Store a list of strings
  static Future<void> storeStringListValue({required String key, required List<String> value}) async {
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
}
