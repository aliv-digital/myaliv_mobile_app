import 'package:shared_preferences/shared_preferences.dart';

/// Tracks when the user was last active in the app and decides whether
/// enough time has passed to force them back to the Welcome screen.
///
/// Persisted via SharedPreferences so cold starts can read the same
/// timestamp that was set during the previous session.
class SessionTimeoutService {
  static const Duration sessionTimeout = Duration(minutes: 20);
  static const String _lastActiveKey = 'session_last_active_ms';

  /// Save the current timestamp. Call on login success and on
  /// AppLifecycleState.paused.
  Future<void> markActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastActiveKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Returns true if the user has been away for >= [sessionTimeout].
  /// Returns true when no timestamp exists (never logged in or cleared).
  Future<bool> hasTimedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveMs = prefs.getInt(_lastActiveKey);
    if (lastActiveMs == null) return true;
    final lastActive = DateTime.fromMillisecondsSinceEpoch(lastActiveMs);
    return DateTime.now().difference(lastActive) >= sessionTimeout;
  }
}
