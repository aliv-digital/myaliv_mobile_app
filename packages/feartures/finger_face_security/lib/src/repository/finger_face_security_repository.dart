import 'package:finger_face_security/src/model/finger_face_security_model.dart';
import 'package:finger_face_security/src/services/biometric_auth_service.dart';
import 'package:finger_face_security/src/services/biometric_type_hint.dart';

abstract class FingerFaceSecurityRepository {
  Future<FingerFaceSecurityModel> getBiometricStatus();
  Future<BiometricAuthResult> authenticate({
    String? reason,
    BiometricTypeHint type = BiometricTypeHint.any,
  });
  Future<BiometricSetupResult> setupBiometric();
  Future<void> disableBiometric();

  // Per-type setup / disable
  Future<BiometricSetupResult> setupFingerprintBiometric();
  Future<BiometricSetupResult> setupFaceIdBiometric();
  Future<void> disableFingerprintBiometric();
  Future<void> disableFaceIdBiometric();
}
