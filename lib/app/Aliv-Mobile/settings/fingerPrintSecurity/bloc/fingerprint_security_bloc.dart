import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/fingerprint_security_repository.dart';
import 'fingerprint_security_event.dart';
import 'fingerprint_security_state.dart';

class FingerPrintSecurityBloc
    extends Bloc<FingerPrintSecurityEvent, FingerPrintSecurityState> {
  FingerPrintSecurityBloc({
    required FingerPrintSecurityRepository repository,
  })  : _repository = repository,
        super(FingerPrintSecurityState.initial()) {
    on<FingerPrintSecurityStarted>(_onStarted);
    on<AgreePressed>(_onAgreePressed);
    on<FingerPrintSecurityNavConsumed>(_onNavConsumed);
  }

  final FingerPrintSecurityRepository _repository;

  Future<void> _onStarted(
      FingerPrintSecurityStarted event,
      Emitter<FingerPrintSecurityState> emit,
      ) async {
    emit(state.copyWith(status: FingerPrintSecurityStatus.loading, errorMessage: null));
    try {
      final content = await _repository.fetchContent();
      emit(state.copyWith(status: FingerPrintSecurityStatus.ready, content: content));
    } catch (e) {
      emit(state.copyWith(status: FingerPrintSecurityStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onAgreePressed(AgreePressed event, Emitter<FingerPrintSecurityState> emit) {
    // Navigation hook: after agree, go back (or proceed)
    emit(state.copyWith(navTarget: FingerPrintSecurityNavTarget.back));
  }

  void _onNavConsumed(
      FingerPrintSecurityNavConsumed event,
      Emitter<FingerPrintSecurityState> emit,
      ) {
    emit(state.copyWith(navTarget: FingerPrintSecurityNavTarget.none));
  }
}
