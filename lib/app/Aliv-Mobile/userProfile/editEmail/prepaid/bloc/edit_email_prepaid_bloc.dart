import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/edit_email_prepaid_repository.dart';
import 'edit_email_prepaid_event.dart';
import 'edit_email_prepaid_state.dart';

class EditEmailPrepaidBloc extends Bloc<EditEmailPrepaidEvent, EditEmailPrepaidState> {
  final EditEmailPrepaidRepository repository;

  EditEmailPrepaidBloc(this.repository) : super(EditEmailPrepaidState.initial()) {
    on<EditEmailPrepaidStarted>(_onStarted);
    on<EditEmailPrepaidBackPressed>(_onBack);
    on<EditEmailPrepaidHomePressed>(_onHome);
    on<EditEmailPrepaidEmailChanged>(_onEmailChanged);
    on<EditEmailPrepaidSavePressed>(_onSave);
  }

  Future<void> _onStarted(
      EditEmailPrepaidStarted event,
      Emitter<EditEmailPrepaidState> emit,
      ) async {
    try {
      emit(state.copyWith(status: EditEmailPrepaidStatus.loading, errorMessage: null));
      final data = await repository.fetchEditEmailData();
      emit(state.copyWith(
        status: EditEmailPrepaidStatus.ready,
        data: data,
        email: data.email,
        errorMessage: null,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: EditEmailPrepaidStatus.failure,
        errorMessage: 'Failed to load',
      ));
    }
  }

  void _onBack(EditEmailPrepaidBackPressed event, Emitter<EditEmailPrepaidState> emit) {
    // navigation তুমি screen-level এ handle করতে পারো,
    // এখন simple: back
    // (তুমি চাইলে এখানে state-based navAction add করতে পারো)
  }

  void _onHome(EditEmailPrepaidHomePressed event, Emitter<EditEmailPrepaidState> emit) {
    // same note as back
  }

  void _onEmailChanged(EditEmailPrepaidEmailChanged event, Emitter<EditEmailPrepaidState> emit) {
    emit(state.copyWith(email: event.email, errorMessage: null));
  }

  Future<void> _onSave(EditEmailPrepaidSavePressed event, Emitter<EditEmailPrepaidState> emit) async {
    if (!state.isEmailValid) {
      emit(state.copyWith(
        status: EditEmailPrepaidStatus.failure,
        errorMessage: 'Invalid email',
      ));
      emit(state.copyWith(status: EditEmailPrepaidStatus.ready, errorMessage: null));
      return;
    }

    try {
      emit(state.copyWith(status: EditEmailPrepaidStatus.submitting, errorMessage: null));
      await repository.updateEmail(state.email.trim());
      emit(state.copyWith(status: EditEmailPrepaidStatus.success, errorMessage: null));
      emit(state.copyWith(status: EditEmailPrepaidStatus.ready));
    } catch (_) {
      emit(state.copyWith(
        status: EditEmailPrepaidStatus.failure,
        errorMessage: 'Failed to save',
      ));
      emit(state.copyWith(status: EditEmailPrepaidStatus.ready, errorMessage: null));
    }
  }
}
