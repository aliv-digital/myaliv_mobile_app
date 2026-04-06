import 'package:core/core.dart';
import 'package:core/src/app/di.dart';
import 'package:flutter/foundation.dart';

/// Core package dependency injection
///
/// Initializes core services like NetworkService and AuthManager.
/// This should be called by the main app's injection initialization.
class CoreInjection {
  /// Initialize core dependencies with optional auth loading
  ///
  /// If auth loading functions are provided, this will:
  /// 1. Create and register AuthManager
  /// 2. Load stored credentials into GlobalState
  /// 3. Create and register NetworkService
  /// 4. Initialize NetworkService with auth (if available)
  ///
  /// If auth functions are not provided:
  /// - NetworkService will be initialized without auth headers
  /// - Auth can be set up later via AuthManager.saveAuth()
  ///
  /// Parameters:
  /// - [getTicket]: Function to retrieve stored ticket from SharedPreferences
  /// - [getAccountInfoMap]: Function to retrieve stored account info
  /// - [parseAccountInfo]: Function to parse account info map to model
  /// - [username]: Username constant (from core/constants)
  Future<void> initInjection({
    Future<String?> Function()? getTicket,
    Future<Map<String, dynamic>> Function()? getAccountInfoMap,
    dynamic Function(Map<String, dynamic>)? parseAccountInfo,
    String? username,
  }) async {
    if (kDebugMode) {
      debugPrint('========== CoreInjection START ==========');
    }

    // ========== 1. Register AuthManager ==========
    final authManager = AuthManager();
    instance.registerSingleton<AuthManager>(authManager);

    // ========== 2. Load Auth from Storage (if functions provided) ==========
    if (getTicket != null &&
        getAccountInfoMap != null &&
        parseAccountInfo != null &&
        username != null) {
      try {
        await authManager.loadAuthFromStorage(
          getTicket: getTicket,
          getAccountInfoMap: getAccountInfoMap,
          parseAccountInfo: parseAccountInfo,
          username: username,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ CoreInjection: Failed to load auth - $e');
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint('⚠️ CoreInjection: No auth loading functions provided, skipping auth load');
      }
    }

    // ========== 3. Register NetworkService ==========
    final networkService = NetworkService();
    instance.registerSingleton<NetworkService>(networkService);

    // ========== 4. Initialize NetworkService ==========
    await networkService.init();

    if (kDebugMode) {
      final hasAuth = globalState.isAuthenticated;
      debugPrint('✅ CoreInjection COMPLETE (Auth: ${hasAuth ? "YES ✅" : "NO ⚠️"})');
      debugPrint('==========================================');
    }
  }
}
