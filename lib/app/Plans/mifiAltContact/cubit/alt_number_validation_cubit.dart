import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/alt_number_validation_repository.dart';
import 'alt_number_validation_state.dart';

class AltNumberValidationCubit extends Cubit<AltNumberValidationState> {
  AltNumberValidationCubit({required AltNumberValidationRepository repository})
      : _repository = repository,
        super(const AltNumberValidationState());

  final AltNumberValidationRepository _repository;

  Future<void> validate(String altNumber) async {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: AltNumberValidationStatus.loading,
        errorMessage: '',
        signalId: state.signalId + 1,
      ),
    );

    try {
      final isValid = await _repository.validate(altNumber);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: isValid
              ? AltNumberValidationStatus.valid
              : AltNumberValidationStatus.invalid,
          errorMessage: isValid ? '' : 'this mobile number is not valid.',
          signalId: state.signalId + 1,
        ),
      );
    } on AltNumberValidationException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AltNumberValidationStatus.failure,
          errorMessage: e.message,
          signalId: state.signalId + 1,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AltNumberValidationCubit: unexpected error $e');
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AltNumberValidationStatus.failure,
          errorMessage: 'could not verify the mobile number. please try again.',
          signalId: state.signalId + 1,
        ),
      );
    }
  }

  void reset() {
    emit(const AltNumberValidationState());
  }
}
