import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/rev_payment_method_prepaid_repository.dart';
import 'rev_payment_method_prepaid_event.dart';
import 'rev_payment_method_prepaid_state.dart';

class RevPaymentMethodPrepaidBloc
    extends Bloc<RevPaymentMethodPrepaidEvent, RevPaymentMethodPrepaidState> {
  final RevPaymentMethodPrepaidRepository repository;

  RevPaymentMethodPrepaidBloc({required this.repository})
      : super(RevPaymentMethodPrepaidState.initial()) {
    on<RevPaymentMethodPrepaidStarted>(_onStarted);
    on<RevPaymentMethodSelected>(_onSelected);
    on<RevPayWithCardPressed>(_onPayWithCard);
    on<RevPayNowPressed>(_onPayNow);
    on<RevPaymentNavConsumed>(_onNavConsumed);
  }

  Future<void> _onStarted(
      RevPaymentMethodPrepaidStarted event,
      Emitter<RevPaymentMethodPrepaidState> emit,
      ) async {
    emit(state.copyWith(status: RevPaymentMethodPrepaidStatus.loading, errorMessage: null));

    try {
      final methods = await repository.fetchPaymentMethods();
      emit(
        state.copyWith(
          status: RevPaymentMethodPrepaidStatus.ready,
          methods: methods,
          selectedMethodId: methods.isNotEmpty ? methods.first.id : null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RevPaymentMethodPrepaidStatus.failure,
          errorMessage: 'Failed to load payment methods',
        ),
      );
    }
  }

  void _onSelected(
      RevPaymentMethodSelected event,
      Emitter<RevPaymentMethodPrepaidState> emit,
      ) {
    emit(state.copyWith(selectedMethodId: event.methodId));
  }

  void _onPayWithCard(
      RevPayWithCardPressed event,
      Emitter<RevPaymentMethodPrepaidState> emit,
      ) {
    emit(state.copyWith(navTarget: RevPaymentMethodNavTarget.addCard));
  }

  Future<void> _onPayNow(
      RevPayNowPressed event,
      Emitter<RevPaymentMethodPrepaidState> emit,
      ) async {
    if (!state.isPayNowEnabled) return;

    emit(state.copyWith(status: RevPaymentMethodPrepaidStatus.submitting, errorMessage: null));

    try {
      await repository.payNow(methodId: state.selectedMethodId!);
      emit(
        state.copyWith(
          status: RevPaymentMethodPrepaidStatus.success,
          navTarget: RevPaymentMethodNavTarget.paid,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RevPaymentMethodPrepaidStatus.failure,
          errorMessage: 'Payment failed. Try again.',
        ),
      );
    }
  }

  void _onNavConsumed(
      RevPaymentNavConsumed event,
      Emitter<RevPaymentMethodPrepaidState> emit,
      ) {
    emit(state.copyWith(navTarget: RevPaymentMethodNavTarget.none));
  }
}
