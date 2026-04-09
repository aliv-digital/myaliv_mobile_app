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
  /// Note: Account info is managed by AccountInfoCubit (HydratedBloc).
  /// This method only loads authentication credentials (ticket and accountID).
  Future<AuthContext?> loadAuthFromStorage({
    required Future<String?> Function() getTicket,
    required Future<String?> Function() getAccountID,
    required String username,
  }) async {
    try {
      // Read from SharedPreferences
      final ticket = await getTicket();
      final accountIdStr = await getAccountID();

      // Validate data
      if (ticket == null || ticket.trim().isEmpty) {
        if (kDebugMode) debugPrint('⚠️ AuthManager: No ticket found');
        return null;
      }

      if (accountIdStr == null || accountIdStr.trim().isEmpty) {
        if (kDebugMode) debugPrint('⚠️ AuthManager: No account ID found');
        return null;
      }

      // Parse account ID
      int? accountId;
      try {
        accountId = int.parse(accountIdStr);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ AuthManager: Could not parse account ID: $e');
        }
        return null;
      }

      if (accountId <= 0) {
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
  /// Note: Account info is managed by AccountInfoCubit (HydratedBloc).
  /// This method only saves authentication credentials (ticket and accountID).
  ///
  /// The actual SharedPreferences write operations are delegated to the caller
  /// via the provided functions to avoid coupling with the main app package.
  Future<void> saveAuth({
    required String username,
    required String ticket,
    required String deviceAccountID,
    required Future<void> Function(String ticket) storeTicket,
    required Future<void> Function(String accountID) storeAccountID,
  }) async {
    try {
      // 1. Save to SharedPreferences (persistence)
      await storeTicket(ticket);
      await storeAccountID(deviceAccountID);

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

  // ========== Get Stored Credentials ==========

  /// Get stored credentials (username and ticket) from storage
  ///
  /// Returns null if:
  /// - No auth exists in memory
  /// - User is not authenticated
  /// - Ticket is not found in storage
  ///
  /// This method is useful for API calls that require Basic Auth.
  Future<AuthCredentials?> getStoredCredentials({
    required Future<String?> Function() getTicket,
  }) async {
    final auth = getCurrentAuth();
    if (auth == null || !auth.isAuthenticated) {
      if (kDebugMode) {
        debugPrint('⚠️ AuthManager: No valid auth context');
      }
      return null;
    }

    final ticket = await getTicket();
    if (ticket == null || ticket.trim().isEmpty) {
      if (kDebugMode) {
        debugPrint('⚠️ AuthManager: No ticket found in storage');
      }
      return null;
    }

    return AuthCredentials(
      username: auth.username,
      ticket: ticket,
    );
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

/// Credentials holder for Basic Auth
///
/// Contains username and ticket (password) for API authentication.
class AuthCredentials {
  final String username;
  final String ticket;

  const AuthCredentials({
    required this.username,
    required this.ticket,
  });
}
