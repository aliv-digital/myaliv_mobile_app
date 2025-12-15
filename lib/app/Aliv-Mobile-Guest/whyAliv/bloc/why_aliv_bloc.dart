// lib/features/why_aliv/why_aliv/bloc/why_aliv_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/why_aliv_repository.dart';
import 'why_aliv_event.dart';
import 'why_aliv_state.dart';

class WhyAlivBloc extends Bloc<WhyAlivEvent, WhyAlivState> {
  WhyAlivBloc({required this.repository}) : super(const WhyAlivState()) {
    on<WhyAlivStarted>(_onStarted);
  }

  final WhyAlivRepository repository;

  Future<void> _onStarted(WhyAlivStarted event, Emitter<WhyAlivState> emit) async {

    emit(state.copyWith(status: WhyAlivStatus.loading, errorMessage: null));
    try {
      await repository.initialize();
      emit(state.copyWith(status: WhyAlivStatus.ready));
    } catch (_) {
      emit(
        state.copyWith(
          status: WhyAlivStatus.failure,
          errorMessage: null,
        ),
      );

    }
  }
}
