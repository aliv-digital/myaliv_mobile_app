import 'package:core/core.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../repository/settings_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required SettingsRepository repository})
    : _repository = repository,
      super(SettingsState.initial()) {
    on<SettingsStarted>(_onStarted);
    on<FingerprintToggled>(_onFingerprintToggled);
    on<FaceScanToggled>(_onFaceScanToggled);

    on<SecurityPressed>(_onSecurityPressed);
    on<PrivacyPressed>(_onPrivacyPressed);
    on<HelpPressed>(_onHelpPressed);

    on<SettingsNavConsumed>(_onNavConsumed);
  }

  final SettingsRepository _repository;

  Future<void> _onStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: null));

    try {
      final biometricCubit = instance<FingerFaceSecurityCubit>();
      // Only hit SharedPreferences/device APIs if cubit doesn't already have fresh data.
      if (biometricCubit.state.status != FingerFaceSecurityStatus.ready) {
        await biometricCubit.loadBiometricStatus();
      }
      final data = biometricCubit.state.data;

      emit(
        state.copyWith(
          status: SettingsStatus.ready,
          isFingerprintAvailable: data?.isFingerprintAvailable ?? false,
          isFaceIdAvailable: data?.isFaceIdAvailable ?? false,
          fingerprintEnabled: data?.fingerprintEnabled ?? false,
          faceScanEnabled: data?.faceIdEnabled ?? false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFingerprintToggled(
    FingerprintToggled event,
    Emitter<SettingsState> emit,
  ) async {
    // Only the disable path fires here; the enable path reloads via SettingsStarted
    // after the user agrees on the security screen.
    if (!event.enabled) {
      emit(state.copyWith(fingerprintEnabled: false));
      try {
        await instance<FingerFaceSecurityCubit>().disableFingerprintBiometric();
        // If face is also off, no biometric type remains — wipe cached creds.
        if (!state.faceScanEnabled) await CredentialStore().clear();
      } catch (e) {
        emit(
          state.copyWith(fingerprintEnabled: true, errorMessage: e.toString()),
        );
      }
    }
  }

  Future<void> _onFaceScanToggled(
    FaceScanToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (!event.enabled) {
      emit(state.copyWith(faceScanEnabled: false));
      try {
        await instance<FingerFaceSecurityCubit>().disableFaceIdBiometric();
        // If fingerprint is also off, no biometric type remains — wipe cached creds.
        if (!state.fingerprintEnabled) await CredentialStore().clear();
      } catch (e) {
        emit(state.copyWith(faceScanEnabled: true, errorMessage: e.toString()));
      }
    }
  }

  void _onSecurityPressed(SecurityPressed event, Emitter<SettingsState> emit) {
    emit(state.copyWith(navTarget: SettingsNavTarget.security));
  }

  void _onPrivacyPressed(PrivacyPressed event, Emitter<SettingsState> emit) {
    emit(state.copyWith(navTarget: SettingsNavTarget.privacy));
  }

  void _onHelpPressed(HelpPressed event, Emitter<SettingsState> emit) {
    emit(state.copyWith(navTarget: SettingsNavTarget.help));
  }

  void _onNavConsumed(SettingsNavConsumed event, Emitter<SettingsState> emit) {
    emit(state.copyWith(navTarget: SettingsNavTarget.none));
  }
}
