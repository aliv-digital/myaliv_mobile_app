import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finger_face_security/src/services/android_biometric_channel.dart';
import 'package:finger_face_security/src/services/biometric_type_hint.dart';

class BiometricAuthService {
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricSetupKey = 'biometric_setup_completed';
  static const String _fingerprintEnabledKey = 'biometric_fingerprint_enabled';
  static const String _faceIdEnabledKey = 'biometric_face_enabled';

  /// SharedPreferences keys that must survive logout (device-level preferences).
  static const Set<String> devicePreferenceKeys = {
    _biometricEnabledKey,
    _fingerprintEnabledKey,
    _faceIdEnabledKey,
  };

  BiometricAuthService({
    LocalAuthentication? localAuth,
    AndroidBiometricChannel? androidChannel,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _androidChannel = androidChannel ?? AndroidBiometricChannel();

  final LocalAuthentication _localAuth;
  final AndroidBiometricChannel _androidChannel;

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

  Future<bool> isFingerprintEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_fingerprintEnabledKey) ?? false;
  }

  Future<void> setFingerprintEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fingerprintEnabledKey, enabled);
    if (enabled) await prefs.setBool(_biometricEnabledKey, true);
  }

  Future<bool> isFaceIdEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_faceIdEnabledKey) ?? false;
  }

  Future<void> setFaceIdEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_faceIdEnabledKey, enabled);
    if (enabled) await prefs.setBool(_biometricEnabledKey, true);
  }

  Future<BiometricAuthResult> authenticateWithBiometrics({
    String localizedReason = 'Please authenticate to access the app',
    bool biometricOnly = false,
    BiometricTypeHint type = BiometricTypeHint.any,
  }) async {
    try {
      debugPrint('BiometricAuth: Starting authentication (type=$type)...');

      final deviceSupported = await isDeviceSupported();
      if (!deviceSupported) return BiometricAuthResult.deviceNotSupported;

      // Android + explicit type hint: skip the local_auth preflight entirely.
      // local_auth's getAvailableBiometrics() misreports empty on devices where
      // only a BIOMETRIC_WEAK (face) authenticator is enrolled. The native
      // handler does its own authoritative BiometricManager.canAuthenticate()
      // check, so defer to it.
      if (Platform.isAndroid && type != BiometricTypeHint.any) {
        return await _androidChannel.authenticate(
          type: type,
          localizedReason: localizedReason,
        );
      }

      final canCheck = await canCheckBiometrics();
      if (!canCheck) return BiometricAuthResult.biometricsNotAvailable;

      final availableBiometrics = await getAvailableBiometrics();
      debugPrint('BiometricAuth: availableBiometrics=$availableBiometrics');
      if (availableBiometrics.isEmpty) {
        return BiometricAuthResult.biometricsNotEnrolled;
      }

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
        // Explicit dismissal is informational; failed attempts stay separate.
        LocalAuthExceptionCode.userCanceled => BiometricAuthResult.cancelled,
        LocalAuthExceptionCode.userRequestedFallback =>
          BiometricAuthResult.userRequestedFallback,
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.noCredentialsSet =>
          BiometricAuthResult.biometricsNotEnrolled,
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
          BiometricAuthResult.biometricsNotAvailable,
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout =>
          BiometricAuthResult.lockedOut,
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
    final isAndroid = Platform.isAndroid;
    final parts = <String>[];
    if (available.contains(BiometricType.fingerprint) ||
        (isAndroid && available.contains(BiometricType.strong))) {
      parts.add('Fingerprint');
    }
    if (available.contains(BiometricType.face) ||
        (isAndroid && available.contains(BiometricType.weak))) {
      parts.add('Face ID');
    }
    if (available.contains(BiometricType.iris)) parts.add('Iris');
    return parts.isEmpty ? 'Biometric authentication' : parts.join(' & ');
  }

  Future<BiometricSetupResult> _setupBiometricType({
    required String reason,
    required Future<void> Function(SharedPreferences) onSuccess,
  }) async {
    try {
      if (!await isDeviceSupported()) {
        return BiometricSetupResult.deviceNotSupported;
      }
      if (!await canCheckBiometrics()) {
        return BiometricSetupResult.biometricsNotAvailable;
      }
      final available = await getAvailableBiometrics();
      if (available.isEmpty) return BiometricSetupResult.biometricsNotEnrolled;

      final authResult = await authenticateWithBiometrics(
        localizedReason: reason,
      );

      if (authResult == BiometricAuthResult.success) {
        final prefs = await SharedPreferences.getInstance();
        await onSuccess(prefs);
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

  Future<BiometricSetupResult> setupFingerprintAuth() => _setupBiometricType(
    reason: 'Verify your fingerprint to enable fingerprint lock',
    onSuccess: (prefs) async {
      await prefs.setBool(_fingerprintEnabledKey, true);
      await prefs.setBool(_biometricEnabledKey, true);
      await prefs.setBool(_biometricSetupKey, true);
    },
  );

  Future<BiometricSetupResult> setupFaceIdAuth() => _setupBiometricType(
    reason: 'Verify your face to enable face lock',
    onSuccess: (prefs) async {
      await prefs.setBool(_faceIdEnabledKey, true);
      await prefs.setBool(_biometricEnabledKey, true);
      await prefs.setBool(_biometricSetupKey, true);
    },
  );

  Future<void> disableFingerprintAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fingerprintEnabledKey, false);
    // Sync legacy flag without extra reads — only face state matters now.
    final faceEnabled = prefs.getBool(_faceIdEnabledKey) ?? false;
    await prefs.setBool(_biometricEnabledKey, faceEnabled);
  }

  Future<void> disableFaceIdAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_faceIdEnabledKey, false);
    final fpEnabled = prefs.getBool(_fingerprintEnabledKey) ?? false;
    await prefs.setBool(_biometricEnabledKey, fpEnabled);
  }

  Future<BiometricSetupResult> setupBiometricAuth() async {
    try {
      debugPrint('BiometricSetup: Starting...');

      if (!await isDeviceSupported()) {
        return BiometricSetupResult.deviceNotSupported;
      }
      if (!await canCheckBiometrics()) {
        return BiometricSetupResult.biometricsNotAvailable;
      }

      final available = await getAvailableBiometrics();
      if (available.isEmpty) return BiometricSetupResult.biometricsNotEnrolled;

      final authResult = await authenticateWithBiometrics(
        localizedReason: 'Verify your identity to enable biometric lock',
      );

      if (authResult == BiometricAuthResult.success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_biometricEnabledKey, true);
        await prefs.setBool(_biometricSetupKey, true);
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
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_biometricEnabledKey, false),
      prefs.setBool(_biometricSetupKey, false),
      prefs.setBool(_fingerprintEnabledKey, false),
      prefs.setBool(_faceIdEnabledKey, false),
    ]);
  }
}

enum BiometricAuthResult {
  success,
  failed,
  deviceNotSupported,
  biometricsNotAvailable,
  biometricsNotEnrolled,
  error,
  cancelled,
  userRequestedFallback,
  lockedOut,
}

enum BiometricSetupResult {
  success,
  deviceNotSupported,
  biometricsNotAvailable,
  biometricsNotEnrolled,
  authenticationFailed,
  error,
}
