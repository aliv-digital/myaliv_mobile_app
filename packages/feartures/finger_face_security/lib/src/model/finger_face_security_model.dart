import 'package:equatable/equatable.dart';

class FingerFaceSecurityModel extends Equatable {
  final bool isBiometricEnabled;
  final bool isFingerprintAvailable;
  final bool isFaceIdAvailable;
  final String biometricTypeDescription;
  final bool fingerprintEnabled;
  final bool faceIdEnabled;

  const FingerFaceSecurityModel({
    this.isBiometricEnabled = false,
    this.isFingerprintAvailable = false,
    this.isFaceIdAvailable = false,
    this.biometricTypeDescription = 'Biometric authentication',
    this.fingerprintEnabled = false,
    this.faceIdEnabled = false,
  });

  bool get isAnyBiometricAvailable =>
      isFingerprintAvailable || isFaceIdAvailable;

  bool get isAnyEnabled => fingerprintEnabled || faceIdEnabled;

  FingerFaceSecurityModel copyWith({
    bool? isBiometricEnabled,
    bool? isFingerprintAvailable,
    bool? isFaceIdAvailable,
    String? biometricTypeDescription,
    bool? fingerprintEnabled,
    bool? faceIdEnabled,
  }) {
    return FingerFaceSecurityModel(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isFingerprintAvailable:
          isFingerprintAvailable ?? this.isFingerprintAvailable,
      isFaceIdAvailable: isFaceIdAvailable ?? this.isFaceIdAvailable,
      biometricTypeDescription:
          biometricTypeDescription ?? this.biometricTypeDescription,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
      faceIdEnabled: faceIdEnabled ?? this.faceIdEnabled,
    );
  }

  @override
  List<Object?> get props => [
    isBiometricEnabled,
    isFingerprintAvailable,
    isFaceIdAvailable,
    biometricTypeDescription,
    fingerprintEnabled,
    faceIdEnabled,
  ];
}
