import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/guest_payment_method_prepaid_repository.dart';
import 'guest_payment_method_prepaid_event.dart';
import 'guest_payment_method_prepaid_state.dart';

class GuestPaymentMethodPrepaidBloc extends Bloc<GuestPaymentMethodPrepaidEvent,
    GuestPaymentMethodPrepaidState> {
  final GuestPaymentMethodPrepaidRepository repository;

  GuestPaymentMethodPrepaidBloc({required this.repository})
      : super(GuestPaymentMethodPrepaidState.initial()) {
    on<GuestPaymentMethodPrepaidStarted>(_onStarted);
    on<GuestPaymentMethodSelected>(_onSelected);
    on<GuestPayWithCardPressed>(_onPayWithCard);
    on<GuestPayNowPressed>(_onPayNow);
    on<GuestPaymentNavConsumed>(_onNavConsumed);
  }

  Future<void> _onStarted(
    GuestPaymentMethodPrepaidStarted event,
    Emitter<GuestPaymentMethodPrepaidState> emit,
  ) async {
    emit(state.copyWith(
        status: GuestPaymentMethodPrepaidStatus.loading, errorMessage: null));

    try {
      final methods = await repository.fetchPaymentMethods();
      emit(
        state.copyWith(
          status: GuestPaymentMethodPrepaidStatus.ready,
          methods: methods,
          selectedMethodId: methods.isNotEmpty ? methods.first.id : null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: GuestPaymentMethodPrepaidStatus.failure,
          errorMessage: 'Failed to load payment methods',
        ),
      );
    }
  }

  void _onSelected(
    GuestPaymentMethodSelected event,
    Emitter<GuestPaymentMethodPrepaidState> emit,
  ) {
    emit(state.copyWith(selectedMethodId: event.methodId));
  }

  void _onPayWithCard(
    GuestPayWithCardPressed event,
    Emitter<GuestPaymentMethodPrepaidState> emit,
  ) {
    emit(state.copyWith(navTarget: GuestPaymentMethodNavTarget.addCard));
  }

  Future<void> _onPayNow(
    GuestPayNowPressed event,
    Emitter<GuestPaymentMethodPrepaidState> emit,
  ) async {
    if (!state.isPayNowEnabled) return;

    emit(state.copyWith(
        status: GuestPaymentMethodPrepaidStatus.submitting,
        errorMessage: null));

    try {
      await repository.payNow(methodId: state.selectedMethodId!);
      emit(
        state.copyWith(
          status: GuestPaymentMethodPrepaidStatus.success,
          navTarget: GuestPaymentMethodNavTarget.paid,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: GuestPaymentMethodPrepaidStatus.failure,
          errorMessage: 'Payment failed. Try again.',
        ),
      );
    }
  }

  void _onNavConsumed(
    GuestPaymentNavConsumed event,
    Emitter<GuestPaymentMethodPrepaidState> emit,
  ) {
    emit(state.copyWith(navTarget: GuestPaymentMethodNavTarget.none));
  }
}
