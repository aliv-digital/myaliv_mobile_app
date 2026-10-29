import 'dart:io' show Platform;

import 'package:local_auth/local_auth.dart';
import 'package:finger_face_security/src/model/finger_face_security_model.dart';
import 'package:finger_face_security/src/repository/finger_face_security_repository.dart';
import 'package:finger_face_security/src/services/biometric_auth_service.dart';
import 'package:finger_face_security/src/services/biometric_type_hint.dart';

class FingerFaceSecurityRepositoryImpl implements FingerFaceSecurityRepository {
  final BiometricAuthService _service;

  FingerFaceSecurityRepositoryImpl({BiometricAuthService? service})
    : _service = service ?? BiometricAuthService();

  @override
  Future<FingerFaceSecurityModel> getBiometricStatus() async {
    // Run all independent reads in parallel.
    final results = await Future.wait([
      _service.getAvailableBiometrics(),
      _service.isBiometricEnabled(),
      _service.getBiometricTypeDescription(),
      _service.isFingerprintEnabled(),
      _service.isFaceIdEnabled(),
    ]);

    final available = results[0] as List<BiometricType>;
    final isEnabled = results[1] as bool;
    final typeDescription = results[2] as String;
    final fingerprintEnabled = results[3] as bool;
    final faceIdEnabled = results[4] as bool;

    // local_auth returns BiometricType.fingerprint / .face only on iOS. On
    // Android it returns .strong (Class 3, usually fingerprint) and .weak
    // (Class 2, usually face unlock) with no per-modality disambiguation.
    final isAndroid = Platform.isAndroid;
    return FingerFaceSecurityModel(
      isBiometricEnabled: isEnabled,
      isFingerprintAvailable:
          available.contains(BiometricType.fingerprint) ||
          (isAndroid && available.contains(BiometricType.strong)),
      isFaceIdAvailable:
          available.contains(BiometricType.face) ||
          (isAndroid && available.contains(BiometricType.weak)),
      biometricTypeDescription: typeDescription,
      fingerprintEnabled: fingerprintEnabled,
      faceIdEnabled: faceIdEnabled,
    );
  }

  @override
  Future<BiometricAuthResult> authenticate({
    String? reason,
    BiometricTypeHint type = BiometricTypeHint.any,
  }) {
    return _service.authenticateWithBiometrics(
      localizedReason: reason ?? 'Authenticate to access MyAliv',
      type: type,
    );
  }

  @override
  Future<BiometricSetupResult> setupBiometric() =>
      _service.setupBiometricAuth();

  @override
  Future<void> disableBiometric() => _service.disableBiometricAuth();

  @override
  Future<BiometricSetupResult> setupFingerprintBiometric() =>
      _service.setupFingerprintAuth();

  @override
  Future<BiometricSetupResult> setupFaceIdBiometric() =>
      _service.setupFaceIdAuth();

  @override
  Future<void> disableFingerprintBiometric() =>
      _service.disableFingerprintAuth();

  @override
  Future<void> disableFaceIdBiometric() => _service.disableFaceIdAuth();
}
