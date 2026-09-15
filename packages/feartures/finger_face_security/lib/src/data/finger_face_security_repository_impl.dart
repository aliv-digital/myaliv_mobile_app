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
    final available = await _service.getAvailableBiometrics();
    final isEnabled = await _service.isBiometricEnabled();
    final typeDescription = await _service.getBiometricTypeDescription();

    return FingerFaceSecurityModel(
      isBiometricEnabled: isEnabled,
      isFingerprintAvailable: available.contains(BiometricType.fingerprint) ||
          available.contains(BiometricType.strong),
      isFaceIdAvailable: available.contains(BiometricType.face),
      biometricTypeDescription: typeDescription,
    );
  }

  @override
  Future<BiometricAuthResult> authenticate({String? reason}) {
    return _service.authenticateWithBiometrics(
      localizedReason: reason ?? 'Authenticate to access MyAliv',
    );
  }

  @override
  Future<BiometricSetupResult> setupBiometric() => _service.setupBiometricAuth();

  @override
  Future<void> disableBiometric() => _service.disableBiometricAuth();
}
