import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/auto_renew_auth_prepaid_repository.dart';
import 'auto_renew_auth_prepaid_event.dart';
import 'auto_renew_auth_prepaid_state.dart';

class AutoRenewAuthPrepaidBloc
    extends Bloc<AutoRenewAuthPrepaidEvent, AutoRenewAuthPrepaidState> {
  final AutoRenewAuthPrepaidRepository repository;

  AutoRenewAuthPrepaidBloc({required this.repository})
      : super(AutoRenewAuthPrepaidState.initial()) {
    on<AutoRenewAuthPrepaidStarted>(_onStarted);
    on<AutoRenewAuthNameChanged>(_onNameChanged);
    on<AutoRenewAuthSubmitPressed>(_onSubmitPressed);
    on<AutoRenewAuthHomePressed>(_onHomePressed);
    on<AutoRenewAuthNavigationConsumed>(_onNavigationConsumed);
  }

  Future<void> _onStarted(
      AutoRenewAuthPrepaidStarted event,
      Emitter<AutoRenewAuthPrepaidState> emit,
      ) async {
    emit(state.copyWith(
      loadStatus: AutoRenewAuthLoadStatus.loading,
      paymentMethod: event.paymentMethod,
      cardToken: event.cardToken,
      clearError: true,
    ));

    try {
      final content = await repository.fetchContent();
      emit(
        state.copyWith(
          loadStatus: AutoRenewAuthLoadStatus.ready,
          content: content,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadStatus: AutoRenewAuthLoadStatus.failure,
          errorMessage: 'Failed to load authorization text.',
        ),
      );
    }
  }

  void _onNameChanged(
      AutoRenewAuthNameChanged event,
      Emitter<AutoRenewAuthPrepaidState> emit,
      ) {
    emit(state.copyWith(name: event.name, clearError: true));
  }

  Future<void> _onSubmitPressed(
      AutoRenewAuthSubmitPressed event,
      Emitter<AutoRenewAuthPrepaidState> emit,
      ) async {
    final name = state.name.trim();
    if (name.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter your name.'));
      return;
    }

    // Validate name matches expected name (case-insensitive)
    if (!state.isNameValid) {
      emit(state.copyWith(
        errorMessage: 'Name does not match. Please enter your name exactly as displayed.',
      ));
      return;
    }

    emit(state.copyWith(submitStatus: AutoRenewAuthSubmitStatus.submitting, clearError: true));

    try {
      final success = await repository.submitAuthorization(
        name: name,
        paymentMethod: state.paymentMethod,
        cardToken: state.cardToken,
      );

      if (success) {
        emit(
          state.copyWith(
            submitStatus: AutoRenewAuthSubmitStatus.success,
            navTarget: AutoRenewAuthNavTarget.success,
          ),
        );
      } else {
        emit(
          state.copyWith(
            submitStatus: AutoRenewAuthSubmitStatus.failure,
            errorMessage: 'Failed to enable auto-renew. Please try again.',
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          submitStatus: AutoRenewAuthSubmitStatus.failure,
          errorMessage: 'Failed to submit. Please try again.',
        ),
      );
    }
  }

  void _onHomePressed(
      AutoRenewAuthHomePressed event,
      Emitter<AutoRenewAuthPrepaidState> emit,
      ) {
    emit(state.copyWith(navTarget: AutoRenewAuthNavTarget.home));
  }

  void _onNavigationConsumed(
      AutoRenewAuthNavigationConsumed event,
      Emitter<AutoRenewAuthPrepaidState> emit,
      ) {
    emit(state.copyWith(navTarget: AutoRenewAuthNavTarget.none));
  }
}
