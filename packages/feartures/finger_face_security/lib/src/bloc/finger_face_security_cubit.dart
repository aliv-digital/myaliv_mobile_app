import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finger_face_security/src/bloc/finger_face_security_state.dart';
import 'package:finger_face_security/src/repository/finger_face_security_repository.dart';
import 'package:finger_face_security/src/services/biometric_auth_service.dart';

class FingerFaceSecurityCubit extends Cubit<FingerFaceSecurityState> {
  final FingerFaceSecurityRepository _repository;

  FingerFaceSecurityCubit(this._repository) : super(const FingerFaceSecurityState());

  Future<void> loadBiometricStatus() async {
    emit(state.copyWith(status: FingerFaceSecurityStatus.loading));
    try {
      final data = await _repository.getBiometricStatus();
      emit(state.copyWith(status: FingerFaceSecurityStatus.ready, data: data));
    } catch (e) {
      emit(state.copyWith(
        status: FingerFaceSecurityStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> authenticate({String? reason}) async {
    emit(state.copyWith(status: FingerFaceSecurityStatus.authenticating));
    try {
      final result = await _repository.authenticate(reason: reason);
      if (result == BiometricAuthResult.success) {
        emit(state.copyWith(
          status: FingerFaceSecurityStatus.authenticated,
          lastAuthResult: result,
        ));
      } else {
        emit(state.copyWith(
          status: FingerFaceSecurityStatus.failure,
          lastAuthResult: result,
          errorMessage: _authResultMessage(result),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FingerFaceSecurityStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> enableBiometric() async {
    emit(state.copyWith(status: FingerFaceSecurityStatus.loading));
    try {
      final result = await _repository.setupBiometric();
      if (result == BiometricSetupResult.success) {
        final updated = state.data?.copyWith(isBiometricEnabled: true);
        emit(state.copyWith(
          status: FingerFaceSecurityStatus.setupSuccess,
          data: updated,
        ));
      } else {
        emit(state.copyWith(
          status: FingerFaceSecurityStatus.failure,
          errorMessage: _setupResultMessage(result),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FingerFaceSecurityStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> disableBiometric() async {
    emit(state.copyWith(status: FingerFaceSecurityStatus.loading));
    try {
      await _repository.disableBiometric();
      final updated = state.data?.copyWith(isBiometricEnabled: false);
      emit(state.copyWith(status: FingerFaceSecurityStatus.ready, data: updated));
    } catch (e) {
      emit(state.copyWith(
        status: FingerFaceSecurityStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  String _authResultMessage(BiometricAuthResult result) => switch (result) {
        BiometricAuthResult.failed => 'Authentication failed. Please try again.',
        BiometricAuthResult.biometricsNotEnrolled =>
          'No biometric data found. Please set up biometrics in device settings.',
        BiometricAuthResult.biometricsNotAvailable =>
          'Biometric authentication not available on this device.',
        BiometricAuthResult.deviceNotSupported =>
          'This device does not support biometric authentication.',
        _ => 'An authentication error occurred. Please try again.',
      };

  void markSessionAuthenticated() {
    emit(state.copyWith(isSessionAuthenticated: true));
  }

  String _setupResultMessage(BiometricSetupResult result) => switch (result) {
        BiometricSetupResult.biometricsNotEnrolled =>
          'No biometrics enrolled. Please set up in device settings.',
        BiometricSetupResult.biometricsNotAvailable ||
        BiometricSetupResult.deviceNotSupported =>
          'Biometric authentication is not available on this device.',
        BiometricSetupResult.authenticationFailed =>
          'Authentication failed. Please try again.',
        _ => 'Could not enable biometric security. Please try again.',
      };
}
