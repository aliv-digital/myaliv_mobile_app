// lib/features/guest_top_up/guest_top_up/bloc/guest_top_up_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/guest_topup_repository.dart';
import 'guest_topup_event.dart';
import 'guest_topup_state.dart';



class GuestTopUpBloc extends Bloc<GuestTopUpEvent, GuestTopUpState> {
  GuestTopUpBloc({required this.repository}) : super(const GuestTopUpState()) {
    on<GuestTopUpStarted>(_onStarted);
  }

  final GuestTopUpRepository repository;

  Future<void> _onStarted(
      GuestTopUpStarted event,
      Emitter<GuestTopUpState> emit,
      ) async {
    emit(state.copyWith(status: GuestTopUpStatus.loading, errorMessage: null));
    try {
      await repository.initialize();
      emit(state.copyWith(status: GuestTopUpStatus.ready));
    } catch (_) {
      emit(
        state.copyWith(
          status: GuestTopUpStatus.failure,
          errorMessage: null,
        ),
      );
    }
  }
}
