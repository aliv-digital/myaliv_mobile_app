import 'package:flutter/foundation.dart';

import 'analytics/analytics_service.dart';
import 'app/di.dart';
import 'auth/auth_manager.dart';
import 'network/network_service.dart';
import 'time/timezone_service.dart';

/// Core package dependency injection.
///
/// Registers, in order:
///   1. TimezoneService
///   2. AuthManager (JWT session owner)  →  loadSession() (secure storage)
///   3. NetworkService                    →  init() (interceptor reads session lazily)
///   4. AnalyticsService
///
/// The [onHardLogout] callback is invoked by [BearerAuthInterceptor] when a
/// refresh token is dead or a refresh call fails. The app layer supplies the
/// closure — it must clear cached state and navigate the user back to the
/// login/welcome flow.
class CoreInjection {
  Future<void> initInjection({
    required Future<void> Function() onHardLogout,
  }) async {
    if (kDebugMode) {
      debugPrint('========== CoreInjection START ==========');
    }

    if (!instance.isRegistered<TimezoneService>()) {
      instance
          .registerSingleton<TimezoneService>(const DeviceTimezoneService());
    }

    final authManager = AuthManager();
    instance.registerSingleton<AuthManager>(authManager);

    // Load persisted JWT session BEFORE NetworkService is used, so the
    // first authed request finds a session in memory.
    try {
      await authManager.loadSession();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ CoreInjection: loadSession failed - $e');
      }
    }

    final networkService = NetworkService(
      authManager: authManager,
      onHardLogout: onHardLogout,
    );
    instance.registerSingleton<NetworkService>(networkService);
    await networkService.init();

    final analyticsService = AnalyticsService();
    instance.registerSingleton<AnalyticsService>(analyticsService);
    await analyticsService.init();

    if (kDebugMode) {
      final hasSession = authManager.currentSession != null;
      debugPrint(
          '✅ CoreInjection COMPLETE (session: ${hasSession ? "YES ✅" : "NO ⚠️"})');
      debugPrint('==========================================');
    }
  }
}
