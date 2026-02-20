import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/auto_renew_prepaid_models.dart';
import '../repository/auto_renew_prepaid_repository.dart';
import 'auto_renew_prepaid_event.dart';
import 'auto_renew_prepaid_state.dart';

class AutoRenewPrepaidBloc extends Bloc<AutoRenewPrepaidEvent, AutoRenewPrepaidState> {
  final AutoRenewPrepaidRepository repository;

  AutoRenewPrepaidBloc({required this.repository}) : super(AutoRenewPrepaidState.initial()) {
    on<AutoRenewPrepaidStarted>(_onStarted);
    on<AutoRenewMethodSelected>(_onSelected);
    on<AutoRenewAddNewCardPressed>(_onAddNewCardPressed);
    on<AutoRenewSaveNewCardPressed>(_onSaveNewCardPressed);
    on<AutoRenewProceedPressed>(_onProceedPressed);
    on<AutoRenewHomePressed>(_onHomePressed);
    on<AutoRenewNavigationConsumed>(_onNavigationConsumed);
  }

  Future<void> _onStarted(
      AutoRenewPrepaidStarted event,
      Emitter<AutoRenewPrepaidState> emit,
      ) async {
    emit(
      state.copyWith(
        loadStatus: AutoRenewLoadStatus.loading,
        clearError: true,
      ),
    );

    try {
      final cards = await repository.fetchSavedCards();

      final methods = <AutoRenewPaymentMethod>[
        ...cards.map(AutoRenewPaymentMethod.card),
        // AutoRenewPaymentMethod.wallet,
        AutoRenewPaymentMethod.none,
      ];

      // default select first card (match figma)
      final selectedId = methods.firstOrNull?.id;

      emit(
        state.copyWith(
          loadStatus: AutoRenewLoadStatus.ready,
          methods: methods,
          selectedMethodId: selectedId,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadStatus: AutoRenewLoadStatus.failure,
          errorMessage: 'Failed to load payment methods.',
        ),
      );
    }
  }

  Future<void> _onSelected(
      AutoRenewMethodSelected event,
      Emitter<AutoRenewPrepaidState> emit,
      ) async {
    emit(
      state.copyWith(
        selectedMethodId: event.methodId,
        clearError: true,
      ),
    );
  }

  void _onAddNewCardPressed(
      AutoRenewAddNewCardPressed event,
      Emitter<AutoRenewPrepaidState> emit,
      ) {
    emit(state.copyWith(navTarget: AutoRenewNavTarget.addCard));
  }

  Future<void> _onSaveNewCardPressed(
      AutoRenewSaveNewCardPressed event,
      Emitter<AutoRenewPrepaidState> emit,
      ) async {
    try {
      final card =
      await repository.saveNewCard(month: event.month, year: event.year);

      final newMethods = <AutoRenewPaymentMethod>[
        AutoRenewPaymentMethod.card(card),
        ...state.methods.where((m) => m.id != card.id),
      ];

      emit(
        state.copyWith(
          methods: newMethods,
          selectedMethodId: card.id,
        ),
      );
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Failed to save card.'));
    }
  }

  Future<void> _onProceedPressed(
      AutoRenewProceedPressed event,
      Emitter<AutoRenewPrepaidState> emit,
      ) async {
    final selected = state.selectedMethodId;
    if (selected == null) {
      emit(state.copyWith(errorMessage: 'Please select a payment method.'));
      return;
    }

    emit(state.copyWith(savingSelection: true, clearError: true));

    try {
      await repository.saveSelectedMethod(selected);
      emit(
        state.copyWith(
          savingSelection: false,
          navTarget: AutoRenewNavTarget.proceed,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          savingSelection: false,
          errorMessage: 'Failed to proceed. Try again.',
        ),
      );
    }
  }

  void _onHomePressed(
      AutoRenewHomePressed event,
      Emitter<AutoRenewPrepaidState> emit,
      ) {
    emit(state.copyWith(navTarget: AutoRenewNavTarget.home));
  }

  void _onNavigationConsumed(
      AutoRenewNavigationConsumed event,
      Emitter<AutoRenewPrepaidState> emit,
      ) {
    emit(state.copyWith(navTarget: AutoRenewNavTarget.none));
  }
}

extension _FirstOrNullX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
