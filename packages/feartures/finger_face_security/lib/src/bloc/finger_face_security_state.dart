import 'package:equatable/equatable.dart';
import 'package:finger_face_security/src/model/finger_face_security_model.dart';
import 'package:finger_face_security/src/services/biometric_auth_service.dart';

enum FingerFaceSecurityStatus {
  initial,
  loading,
  ready,
  authenticating,
  authenticated,
  setupSuccess,
  failure,
}

class FingerFaceSecurityState extends Equatable {
  final FingerFaceSecurityStatus status;
  final FingerFaceSecurityModel? data;
  final String? errorMessage;
  final BiometricAuthResult? lastAuthResult;
  final bool isSessionAuthenticated;

  const FingerFaceSecurityState({
    this.status = FingerFaceSecurityStatus.initial,
    this.data,
    this.errorMessage,
    this.lastAuthResult,
    this.isSessionAuthenticated = false,
  });

  bool get isLoading => status == FingerFaceSecurityStatus.loading;
  bool get isAuthenticating => status == FingerFaceSecurityStatus.authenticating;
  bool get isAuthenticated => status == FingerFaceSecurityStatus.authenticated;
  bool get isFailure => status == FingerFaceSecurityStatus.failure;
  bool get isBiometricEnabled => data?.isBiometricEnabled ?? false;

  FingerFaceSecurityState copyWith({
    FingerFaceSecurityStatus? status,
    FingerFaceSecurityModel? data,
    String? errorMessage,
    BiometricAuthResult? lastAuthResult,
    bool? isSessionAuthenticated,
  }) {
    return FingerFaceSecurityState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
      lastAuthResult: lastAuthResult ?? this.lastAuthResult,
      isSessionAuthenticated: isSessionAuthenticated ?? this.isSessionAuthenticated,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage, lastAuthResult, isSessionAuthenticated];
}
