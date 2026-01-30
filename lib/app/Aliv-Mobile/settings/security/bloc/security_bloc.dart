import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/security_repository.dart';
import 'security_event.dart';
import 'security_state.dart';

class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  SecurityBloc({
    required SecurityRepository repository,
  })  : _repository = repository,
        super(SecurityState.initial()) {
    on<SecurityStarted>(_onStarted);
    on<SecurityHomePressed>(_onHomePressed);
    on<SecurityNavConsumed>(_onNavConsumed);
  }

  final SecurityRepository _repository;

  Future<void> _onStarted(
      SecurityStarted event,
      Emitter<SecurityState> emit,
      ) async {
    emit(state.copyWith(status: SecurityStatus.loading, errorMessage: null));
    try {
      final content = await _repository.fetchContent();
      emit(state.copyWith(status: SecurityStatus.ready, content: content));
    } catch (e) {
      emit(state.copyWith(status: SecurityStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onHomePressed(SecurityHomePressed event, Emitter<SecurityState> emit) {
    emit(state.copyWith(navTarget: SecurityNavTarget.home));
  }

  void _onNavConsumed(SecurityNavConsumed event, Emitter<SecurityState> emit) {
    emit(state.copyWith(navTarget: SecurityNavTarget.none));
  }
}
