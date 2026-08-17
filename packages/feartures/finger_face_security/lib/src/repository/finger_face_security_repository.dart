import 'package:finger_face_security/src/model/finger_face_security_model.dart';
import 'package:finger_face_security/src/services/biometric_auth_service.dart';

abstract class FingerFaceSecurityRepository {
  Future<FingerFaceSecurityModel> getBiometricStatus();
  Future<BiometricAuthResult> authenticate({String? reason});
  Future<BiometricSetupResult> setupBiometric();
  Future<void> disableBiometric();
}
