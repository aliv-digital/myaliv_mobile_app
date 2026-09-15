import 'package:equatable/equatable.dart';

class FingerFaceSecurityModel extends Equatable {
  final bool isBiometricEnabled;
  final bool isFingerprintAvailable;
  final bool isFaceIdAvailable;
  final String biometricTypeDescription;

  const FingerFaceSecurityModel({
    this.isBiometricEnabled = false,
    this.isFingerprintAvailable = false,
    this.isFaceIdAvailable = false,
    this.biometricTypeDescription = 'Biometric authentication',
  });

  bool get isAnyBiometricAvailable => isFingerprintAvailable || isFaceIdAvailable;

  FingerFaceSecurityModel copyWith({
    bool? isBiometricEnabled,
    bool? isFingerprintAvailable,
    bool? isFaceIdAvailable,
    String? biometricTypeDescription,
  }) {
    return FingerFaceSecurityModel(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isFingerprintAvailable: isFingerprintAvailable ?? this.isFingerprintAvailable,
      isFaceIdAvailable: isFaceIdAvailable ?? this.isFaceIdAvailable,
      biometricTypeDescription: biometricTypeDescription ?? this.biometricTypeDescription,
    );
  }

  @override
  List<Object?> get props => [
        isBiometricEnabled,
        isFingerprintAvailable,
        isFaceIdAvailable,
        biometricTypeDescription,
      ];
}
