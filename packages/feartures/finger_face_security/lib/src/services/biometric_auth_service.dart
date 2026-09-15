import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricSetupKey = 'biometric_setup_completed';

  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> isBiometricSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricSetupKey) ?? false;
  }

  Future<void> setBiometricSetupCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricSetupKey, completed);
  }

  Future<BiometricAuthResult> authenticateWithBiometrics({
    String localizedReason = 'Please authenticate to access the app',
    bool biometricOnly = false,
  }) async {
    try {
      debugPrint('BiometricAuth: Starting authentication...');

      final deviceSupported = await isDeviceSupported();
      if (!deviceSupported) return BiometricAuthResult.deviceNotSupported;

      final canCheck = await canCheckBiometrics();
      if (!canCheck) return BiometricAuthResult.biometricsNotAvailable;

      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty)
        return BiometricAuthResult.biometricsNotEnrolled;

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: biometricOnly,
        sensitiveTransaction: false,
        persistAcrossBackgrounding: true,
      );

      debugPrint('BiometricAuth: Result: $isAuthenticated');
      return isAuthenticated
          ? BiometricAuthResult.success
          : BiometricAuthResult.failed;
    } on LocalAuthException catch (e) {
      debugPrint('BiometricAuth: LocalAuthException: ${e.code}');
      return switch (e.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.userRequestedFallback =>
          BiometricAuthResult.failed,
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.noCredentialsSet =>
          BiometricAuthResult.biometricsNotEnrolled,
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
          BiometricAuthResult.biometricsNotAvailable,
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout => BiometricAuthResult.error,
        _ => BiometricAuthResult.error,
      };
    } catch (e) {
      debugPrint('BiometricAuth: Error: $e');
      return BiometricAuthResult.error;
    }
  }

  Future<bool> shouldShowBiometricAuth() async {
    if (!await isBiometricEnabled()) return false;
    if (!await isDeviceSupported() || !await canCheckBiometrics()) return false;
    final available = await getAvailableBiometrics();
    return available.isNotEmpty;
  }

  Future<String> getBiometricTypeDescription() async {
    final available = await getAvailableBiometrics();
    if (available.isEmpty) return 'No biometric authentication available';
    if (available.contains(BiometricType.fingerprint)) return 'Fingerprint';
    if (available.contains(BiometricType.face)) return 'Face ID';
    if (available.contains(BiometricType.iris)) return 'Iris';
    return 'Biometric authentication';
  }

  Future<BiometricSetupResult> setupBiometricAuth() async {
    try {
      debugPrint('BiometricSetup: Starting...');

      if (!await isDeviceSupported())
        return BiometricSetupResult.deviceNotSupported;
      if (!await canCheckBiometrics())
        return BiometricSetupResult.biometricsNotAvailable;

      final available = await getAvailableBiometrics();
      if (available.isEmpty) return BiometricSetupResult.biometricsNotEnrolled;

      final authResult = await authenticateWithBiometrics(
        localizedReason: 'Verify your identity to enable biometric lock',
      );

      if (authResult == BiometricAuthResult.success) {
        await setBiometricEnabled(true);
        await setBiometricSetupCompleted(true);
        return BiometricSetupResult.success;
      }

      return switch (authResult) {
        BiometricAuthResult.biometricsNotEnrolled =>
          BiometricSetupResult.biometricsNotEnrolled,
        BiometricAuthResult.biometricsNotAvailable ||
        BiometricAuthResult.deviceNotSupported =>
          BiometricSetupResult.biometricsNotAvailable,
        _ => BiometricSetupResult.authenticationFailed,
      };
    } catch (e) {
      debugPrint('BiometricSetup: Error: $e');
      return BiometricSetupResult.error;
    }
  }

  Future<void> disableBiometricAuth() async {
    await setBiometricEnabled(false);
    await setBiometricSetupCompleted(false);
  }
}

enum BiometricAuthResult {
  success,
  failed,
  deviceNotSupported,
  biometricsNotAvailable,
  biometricsNotEnrolled,
  error,
}

enum BiometricSetupResult {
  success,
  deviceNotSupported,
  biometricsNotAvailable,
  biometricsNotEnrolled,
  authenticationFailed,
  error,
}
