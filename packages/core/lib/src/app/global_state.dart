import 'package:flutter/foundation.dart';
import '../auth/auth_context.dart';

class GlobalState {
  // Existing generic data storage
  final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};

  // Auth-specific storage
  AuthContext? _authContext;

  // Singleton
  static final GlobalState _instance = GlobalState._internal();
  static GlobalState get instance => _instance;
  GlobalState._internal();

  // ========== Generic Data Access (Existing Functionality) ==========

  /// Store generic key-value data
  dynamic set(dynamic key, dynamic value) => _data[key] = value;

  /// Retrieve generic key-value data
  dynamic get(dynamic key) => _data[key];

  // ========== Auth Context Management ==========

  /// Get current auth context (read-only)
  AuthContext? get authContext => _authContext;

  /// Check if user is authenticated
  bool get isAuthenticated => _authContext?.isAuthenticated ?? false;

  /// Get pre-computed Basic Auth token
  String? get basicAuthToken => _authContext?.basicAuthToken;

  /// Get username
  String? get username => _authContext?.username;

  /// Get device account ID
  String? get deviceAccountID => _authContext?.deviceAccountID;

  /// Set auth context (called by AuthManager only)
  void setAuthContext(AuthContext? context) {
    _authContext = context;
    if (kDebugMode) {
      if (context != null) {
        debugPrint('✅ GlobalState: Auth context set (user: ${context.username})');
      } else {
        debugPrint('⚠️ GlobalState: Auth context cleared');
      }
    }
  }

  /// Clear auth context (logout)
  void clearAuthContext() {
    _authContext = null;
    if (kDebugMode) {
      debugPrint('🗑️ GlobalState: Auth context cleared');
    }
  }

  /// Validate auth and throw if invalid
  void requireAuth({String? operation}) {
    if (!isAuthenticated) {
      final msg = operation != null
          ? 'Authentication required for: $operation'
          : 'Authentication required';
      throw StateError(msg);
    }
  }
}

// Global accessor (for convenience)
final globalState = GlobalState.instance;