import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/auto_renew_auth_prepaid_repository.dart';
import '../verification/auto_renew_authorization_submission.dart';
import 'auto_renew_auth_prepaid_event.dart';
import 'auto_renew_auth_prepaid_state.dart';

class AutoRenewAuthPrepaidBloc
    extends Bloc<AutoRenewAuthPrepaidEvent, AutoRenewAuthPrepaidState> {
  final AutoRenewAuthPrepaidRepository repository;

  /// The one-use OTP capability obtained upstream in the Setup screen.
  final AutoRenewAuthorizationVerifiedResult verifiedResult;

  bool _submissionInProgress = false;
  bool _closing = false;

  AutoRenewAuthPrepaidBloc({
    required this.repository,
    required this.verifiedResult,
  }) : super(AutoRenewAuthPrepaidState.initial()) {
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
    emit(
      state.copyWith(
        loadStatus: AutoRenewAuthLoadStatus.loading,
        paymentMethod: event.paymentMethod,
        cardToken: event.cardToken,
        clearError: true,
      ),
    );

    try {
      final content = await repository.fetchContent(
        cardLastDigits: event.cardLastDigits,
      );
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
    if (_closing ||
        _submissionInProgress ||
        state.submitStatus == AutoRenewAuthSubmitStatus.success) {
      return;
    }
    _submissionInProgress = true;
    try {
      await _submit(emit);
    } finally {
      _submissionInProgress = false;
    }
  }

  Future<void> _submit(Emitter<AutoRenewAuthPrepaidState> emit) async {
    final name = state.name;
    if (name.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter your name.'));
      return;
    }

    if (RegExp(r'[^\p{L} ]', unicode: true).hasMatch(name)) {
      emit(
        state.copyWith(
          errorMessage:
              'Only alphabetical characheters are allowed. Try again.',
        ),
      );
      return;
    }

    // Validate the exact displayed name before calling the API.
    if (!state.isNameValid) {
      emit(
        state.copyWith(
          errorMessage:
              'Name does not match. Please enter your name exactly as displayed.',
        ),
      );
      return;
    }

    final submission = AutoRenewAuthorizationSubmission(
      attemptId: verifiedResult.attemptId,
      name: name,
      paymentMethod: state.paymentMethod,
      cardToken: state.cardToken,
    );

    // Guard against snapshot/result drift and consume the one-use capability.
    // Any failure here means the OTP is stale/consumed; retry needs a fresh
    // apply from Setup, so route the screen back there.
    if (!identical(verifiedResult.attemptId, submission.attemptId) ||
        verifiedResult.paymentMethod != submission.paymentMethod ||
        state.name != submission.name ||
        state.paymentMethod != submission.paymentMethod ||
        state.cardToken != submission.cardToken ||
        !state.isNameValid ||
        !verifiedResult.consume()) {
      emit(
        state.copyWith(
          submitStatus: AutoRenewAuthSubmitStatus.failure,
          errorMessage: 'Failed to submit. Please try again.',
          navTarget: AutoRenewAuthNavTarget.backToSetup,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitStatus: AutoRenewAuthSubmitStatus.submitting,
        clearError: true,
      ),
    );

    try {
      final success = await repository.submitAuthorization(
        name: name,
        paymentMethod: submission.paymentMethod,
        cardToken: submission.cardToken,
      );

      if (_closing || isClosed || emit.isDone) {
        return;
      }

      if (success) {
        emit(
          state.copyWith(
            submitStatus: AutoRenewAuthSubmitStatus.success,
            navTarget: AutoRenewAuthNavTarget.success,
          ),
        );
      } else {
        // One-use OTP is now consumed; retry needs a fresh apply from Setup.
        emit(
          state.copyWith(
            submitStatus: AutoRenewAuthSubmitStatus.failure,
            errorMessage: 'Failed to enable auto-renew. Please try again.',
            navTarget: AutoRenewAuthNavTarget.backToSetup,
          ),
        );
      }
    } catch (_) {
      if (_closing || isClosed || emit.isDone) {
        return;
      }
      emit(
        state.copyWith(
          submitStatus: AutoRenewAuthSubmitStatus.failure,
          errorMessage: 'Failed to submit. Please try again.',
          navTarget: AutoRenewAuthNavTarget.backToSetup,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _closing = true;
    return super.close();
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
