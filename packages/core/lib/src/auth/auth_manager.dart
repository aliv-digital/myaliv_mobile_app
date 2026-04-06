import 'package:flutter/foundation.dart';
import '../app/global_state.dart';
import 'auth_context.dart';

/// Manages authentication state across persistence and memory layers
///
/// This service acts as the bridge between:
/// - SharedPreferences (disk storage) via LocalStorage
/// - GlobalState (in-memory cache)
///
/// It ensures both layers stay in sync during login/logout operations.
class AuthManager {
  final GlobalState _globalState;

  AuthManager({
    GlobalState? globalState,
  }) : _globalState = globalState ?? GlobalState.instance;

  // ========== Load Auth (App Startup) ==========

  /// Load credentials from SharedPreferences into GlobalState
  ///
  /// This method should be called during app initialization (before NetworkService.init()).
  /// It reads stored credentials from disk and populates the in-memory GlobalState.
  ///
  /// Returns:
  /// - AuthContext if valid credentials exist
  /// - null if no credentials or invalid data
  ///
  /// Note: This method requires LocalStorage which is in the main app package,
  /// so it must be provided via dependency injection or called from the main app.
  Future<AuthContext?> loadAuthFromStorage({
    required Future<String?> Function() getTicket,
    required Future<Map<String, dynamic>> Function() getAccountInfoMap,
    required String username,
    required dynamic Function(Map<String, dynamic>) parseAccountInfo,
  }) async {
    try {
      // Read from SharedPreferences
      final ticket = await getTicket();
      final accountMap = await getAccountInfoMap();
      final accountInfo = parseAccountInfo(accountMap);

      // Validate data
      if (ticket == null || ticket.trim().isEmpty) {
        if (kDebugMode) debugPrint('⚠️ AuthManager: No ticket found');
        return null;
      }

      // Extract account ID (handle different model types)
      int? accountId;
      if (accountInfo is Map) {
        accountId = accountInfo['idAcc'] as int?;
      } else {
        // Assuming it has an idAcc property
        try {
          accountId = (accountInfo as dynamic).idAcc as int?;
        } catch (e) {
          if (kDebugMode)
            debugPrint('⚠️ AuthManager: Could not extract idAcc: $e');
        }
      }

      if (accountId == null || accountId <= 0) {
        if (kDebugMode) debugPrint('⚠️ AuthManager: Invalid account ID');
        return null;
      }

      // Build auth context
      final authContext = AuthContext.fromStorage(
        username: username,
        ticket: ticket,
        accountId: accountId,
      );

      // Store in GlobalState (in-memory cache)
      _globalState.setAuthContext(authContext);

      if (kDebugMode) {
        debugPrint(
            '✅ AuthManager: Loaded auth for device: ${authContext.deviceAccountID}');
      }

      return authContext;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthManager: Failed to load auth - $e');
      }
      return null;
    }
  }

  // ========== Save Auth (After Login) ==========

  /// Save credentials to both SharedPreferences and GlobalState
  ///
  /// This method should be called after successful login.
  /// It persists credentials to disk and updates the in-memory cache.
  ///
  /// The actual SharedPreferences write operations are delegated to the caller
  /// via the provided functions to avoid coupling with the main app package.
  Future<void> saveAuth({
    required String username,
    required String ticket,
    required String deviceAccountID,
    required Future<void> Function(String ticket) storeTicket,
    required Future<void> Function(String accountID) storeAccountID,
    required Future<void> Function(Map<String, dynamic> accountInfo)?
        storeAccountInfoMap,
    Map<String, dynamic>? accountInfoMap,
  }) async {
    try {
      // 1. Save to SharedPreferences (persistence)
      await storeTicket(ticket);
      await storeAccountID(deviceAccountID);
      if (storeAccountInfoMap != null && accountInfoMap != null) {
        await storeAccountInfoMap(accountInfoMap);
      }

      // 2. Build auth context
      final authContext = AuthContext.fromCredentials(
        username: username,
        password: ticket,
        deviceAccountID: deviceAccountID,
      );

      // 3. Store in GlobalState (in-memory)
      _globalState.setAuthContext(authContext);

      if (kDebugMode) {
        debugPrint('✅ AuthManager: Saved auth for device: $deviceAccountID');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthManager: Failed to save auth - $e');
      }
      rethrow;
    }
  }

  // ========== Clear Auth (Logout) ==========

  /// Clear credentials from both SharedPreferences and GlobalState
  ///
  /// This method should be called during logout.
  /// It removes all stored credentials from disk and clears the in-memory cache.
  Future<void> clearAuth({
    required Future<void> Function() clearAllPreferences,
  }) async {
    try {
      // 1. Clear SharedPreferences
      await clearAllPreferences();

      // 2. Clear GlobalState
      _globalState.clearAuthContext();

      if (kDebugMode) {
        debugPrint('✅ AuthManager: Auth cleared (logout)');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ AuthManager: Failed to clear auth - $e');
      }
      rethrow;
    }
  }

  // ========== Utility Methods ==========

  /// Check if valid auth exists in memory
  bool hasValidAuth() {
    final auth = _globalState.authContext;
    return auth != null && auth.isAuthenticated && !auth.isExpired;
  }

  /// Get current auth context (may be null)
  AuthContext? getCurrentAuth() => _globalState.authContext;

  /// Require valid auth or throw
  AuthContext requireAuth({String? operation}) {
    final auth = getCurrentAuth();
    if (auth == null || !auth.isAuthenticated) {
      throw StateError(
        operation != null
            ? 'Authentication required for: $operation'
            : 'User not authenticated',
      );
    }
    if (auth.isExpired) {
      throw StateError('Authentication expired. Please login again.');
    }
    return auth;
  }
}
