import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/privacy_repository.dart';
import 'privacy_event.dart';
import 'privacy_state.dart';

class PrivacyBloc extends Bloc<PrivacyEvent, PrivacyState> {
  PrivacyBloc({
    required PrivacyRepository repository,
  })  : _repository = repository,
        super(PrivacyState.initial()) {
    on<PrivacyStarted>(_onStarted);
    on<PrivacyHomePressed>(_onHomePressed);
    on<PrivacyNavConsumed>(_onNavConsumed);
  }

  final PrivacyRepository _repository;

  Future<void> _onStarted(
      PrivacyStarted event,
      Emitter<PrivacyState> emit,
      ) async {
    emit(
      state.copyWith(
        status: PrivacyStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final PrivacyContent content = await _repository.fetchContent();
      emit(
        state.copyWith(
          status: PrivacyStatus.ready,
          content: content,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PrivacyStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onHomePressed(
      PrivacyHomePressed event,
      Emitter<PrivacyState> emit,
      ) {
    emit(state.copyWith(navTarget: PrivacyNavTarget.home));
  }

  void _onNavConsumed(
      PrivacyNavConsumed event,
      Emitter<PrivacyState> emit,
      ) {
    emit(state.copyWith(navTarget: PrivacyNavTarget.none));
  }
}