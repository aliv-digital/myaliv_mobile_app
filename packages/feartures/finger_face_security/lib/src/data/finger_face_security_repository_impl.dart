import 'package:local_auth/local_auth.dart';
import 'package:finger_face_security/src/model/finger_face_security_model.dart';
import 'package:finger_face_security/src/repository/finger_face_security_repository.dart';
import 'package:finger_face_security/src/services/biometric_auth_service.dart';

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

    return FingerFaceSecurityModel(
      isBiometricEnabled: isEnabled,
      isFingerprintAvailable:
          available.contains(BiometricType.fingerprint) ||
          available.contains(BiometricType.strong),
      isFaceIdAvailable: available.contains(BiometricType.face),
      biometricTypeDescription: typeDescription,
      fingerprintEnabled: fingerprintEnabled,
      faceIdEnabled: faceIdEnabled,
    );
  }

  @override
  Future<BiometricAuthResult> authenticate({String? reason}) {
    return _service.authenticateWithBiometrics(
      localizedReason: reason ?? 'Authenticate to access MyAliv',
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
