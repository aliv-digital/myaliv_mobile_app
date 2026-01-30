import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/help_repository.dart';
import 'help_event.dart';
import 'help_state.dart';

class HelpBloc extends Bloc<HelpEvent, HelpState> {
  HelpBloc({
    required HelpRepository repository,
  })  : _repository = repository,
        super(HelpState.initial()) {
    on<HelpStarted>(_onStarted);
    on<HelpHomePressed>(_onHomePressed);
    on<HelpNavConsumed>(_onNavConsumed);
  }

  final HelpRepository _repository;

  Future<void> _onStarted(
      HelpStarted event,
      Emitter<HelpState> emit,
      ) async {
    emit(state.copyWith(status: HelpStatus.loading, errorMessage: null));
    try {
      final content = await _repository.fetchContent();
      emit(state.copyWith(status: HelpStatus.ready, content: content));
    } catch (e) {
      emit(state.copyWith(status: HelpStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onHomePressed(HelpHomePressed event, Emitter<HelpState> emit) {
    emit(state.copyWith(navTarget: HelpNavTarget.home));
  }

  void _onNavConsumed(HelpNavConsumed event, Emitter<HelpState> emit) {
    emit(state.copyWith(navTarget: HelpNavTarget.none));
  }
}
