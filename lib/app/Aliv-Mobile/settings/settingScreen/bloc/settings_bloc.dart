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
      final fingerprint = await _repository.getFingerprintEnabled();
      final faceScan = await _repository.getFaceScanEnabled();

      emit(
        state.copyWith(
          status: SettingsStatus.ready,
          fingerprintEnabled: fingerprint,
          faceScanEnabled: faceScan,
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
    // optimistic UI update
    emit(state.copyWith(fingerprintEnabled: event.enabled));

    try {
      await _repository.setFingerprintEnabled(event.enabled);
    } catch (e) {
      // rollback
      emit(
        state.copyWith(
          fingerprintEnabled: !event.enabled,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onFaceScanToggled(
      FaceScanToggled event,
      Emitter<SettingsState> emit,
      ) async {
    emit(state.copyWith(faceScanEnabled: event.enabled));

    try {
      await _repository.setFaceScanEnabled(event.enabled);
    } catch (e) {
      emit(
        state.copyWith(
          faceScanEnabled: !event.enabled,
          errorMessage: e.toString(),
        ),
      );
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
