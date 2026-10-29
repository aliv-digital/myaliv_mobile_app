import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:finger_face_security/src/services/biometric_auth_service.dart';
import 'package:finger_face_security/src/services/biometric_type_hint.dart';

/// Dart wrapper for the Android-only `new.app.myaliv/biometric` MethodChannel
/// that invokes `BiometricPrompt` with a specific authenticator class
/// (`BIOMETRIC_WEAK` for face, `BIOMETRIC_STRONG` for fingerprint).
///
/// Callers must only invoke this on Android with [BiometricTypeHint.face] or
/// [BiometricTypeHint.fingerprint]; see [BiometricAuthService] for routing.
class AndroidBiometricChannel {
  AndroidBiometricChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('new.app.myaliv/biometric');

  final MethodChannel _channel;

  Future<BiometricAuthResult> authenticate({
    required BiometricTypeHint type,
    required String localizedReason,
    String title = 'Sign in to MyAliv',
    String negativeButton = 'Cancel',
  }) async {
    assert(
      type == BiometricTypeHint.face || type == BiometricTypeHint.fingerprint,
      'AndroidBiometricChannel requires an explicit face/fingerprint hint',
    );
    try {
      final response = await _channel.invokeMethod<Map<Object?, Object?>>(
        'authenticate',
        <String, Object?>{
          'type': type == BiometricTypeHint.face ? 'face' : 'fingerprint',
          'title': title,
          'subtitle': localizedReason,
          'negativeButton': negativeButton,
        },
      );
      final result = response?['result'] as String?;
      return _mapResult(result);
    } on PlatformException catch (e) {
      debugPrint('AndroidBiometricChannel: PlatformException ${e.code}');
      return BiometricAuthResult.error;
    } catch (e) {
      debugPrint('AndroidBiometricChannel: Error $e');
      return BiometricAuthResult.error;
    }
  }

  BiometricAuthResult _mapResult(String? result) => switch (result) {
    'success' => BiometricAuthResult.success,
    'failed' => BiometricAuthResult.failed,
    'cancelled' => BiometricAuthResult.cancelled,
    'lockedOut' => BiometricAuthResult.lockedOut,
    'notEnrolled' => BiometricAuthResult.biometricsNotEnrolled,
    'notAvailable' => BiometricAuthResult.biometricsNotAvailable,
    'notSupported' => BiometricAuthResult.deviceNotSupported,
    _ => BiometricAuthResult.error,
  };
}
