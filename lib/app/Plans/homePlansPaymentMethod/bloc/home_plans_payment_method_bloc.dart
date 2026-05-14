import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/home_plans_payment_method_models.dart';
import '../repository/home_plans_payment_method_repository.dart';
import 'home_plans_payment_method_event.dart';
import 'home_plans_payment_method_state.dart';

class HomePlansPaymentMethodBloc
    extends Bloc<HomePlansPaymentMethodEvent, HomePlansPaymentMethodState> {
  final HomePlansPaymentMethodRepository repository;

  HomePlansPaymentMethodBloc({required this.repository})
      : super(HomePlansPaymentMethodState.initial()) {
    on<HomePlansPaymentMethodStarted>(_onStarted);
    on<HomePlansPaymentMethodSelected>(_onSelected);
    on<HomePlansPayWithCardPressed>(_onPayWithCard);
    on<HomePlansPayFromWalletPressed>(_onPayFromWallet);
    on<HomePlansPayFromWalletConfirmed>(_onPayFromWalletConfirmed);
    on<HomePlansPayNowPressed>(_onPayNow);
    on<HomePlansPaymentNavConsumed>(_onNavConsumed);
  }

  Future<void> _onStarted(
    HomePlansPaymentMethodStarted event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) async {
    // Keep this bloc focused on the payment flow. Account balance lives in
    // BalanceCubit, so the payment screen can always show the latest wallet data.
    emit(
      state.copyWith(
        status: HomePlansPaymentMethodStatus.loading,
        errorMessage: null,
        subscriberType: event.subscriberType,
        phoneNumber: event.phoneNumber,
        amount: event.amount,
        vatNote: event.vatNote,
        selectedItems: event.selectedItems,
      ),
    );

    try {
      // Load payment methods based on subscriber type.
      final List<HomePlansSavedPaymentMethod> methods = await repository
          .fetchPaymentMethods(subscriberType: event.subscriberType);

      // Select the first available method by default.
      emit(
        state.copyWith(
          status: HomePlansPaymentMethodStatus.ready,
          methods: methods,
          selectedMethodId: methods.isNotEmpty ? methods.first.id : null,
        ),
      );
    } catch (_) {
      // Keep message user-friendly for UI snackbar.
      emit(
        state.copyWith(
          status: HomePlansPaymentMethodStatus.failure,
          errorMessage: 'Failed to load payment methods',
        ),
      );
    }
  }

  void _onSelected(
    HomePlansPaymentMethodSelected event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) {
    emit(state.copyWith(selectedMethodId: event.methodId));
  }

  void _onPayWithCard(
    HomePlansPayWithCardPressed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) {
    emit(state.copyWith(navTarget: HomePlansPaymentMethodNavTarget.addCard));
  }

  void _onPayFromWallet(
    HomePlansPayFromWalletPressed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) {
    emit(state.copyWith(navTarget: HomePlansPaymentMethodNavTarget.wallet));
  }

  Future<void> _onPayFromWalletConfirmed(
    HomePlansPayFromWalletConfirmed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) async {
    if (state.status == HomePlansPaymentMethodStatus.submitting) return;

    // Do not hit the wallet payment API unless balance can cover the order.
    if (!_hasEnoughWalletBalance(event.walletBalance)) {
      emit(
        state.copyWith(
          walletWarningMessage: 'Insufficient wallet balance',
          walletWarningRequestId: state.walletWarningRequestId + 1,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: HomePlansPaymentMethodStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      await repository.payFromWallet(
        amount: state.amount,
        selectedItems: state.selectedItems,
      );

      emit(
        state.copyWith(
          status: HomePlansPaymentMethodStatus.success,
          navTarget: HomePlansPaymentMethodNavTarget.paid,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HomePlansPaymentMethodStatus.failure,
          errorMessage: _cleanErrorMessage(
            error,
            fallback: 'Wallet payment failed. Try again.',
          ),
        ),
      );
    }
  }

  bool _hasEnoughWalletBalance(double walletBalance) {
    return walletBalance >= state.amount;
  }

  String _cleanErrorMessage(Object error, {required String fallback}) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? fallback : message;
  }

  Future<void> _onPayNow(
    HomePlansPayNowPressed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) async {
    if (!state.isPayNowEnabled) return;

    emit(
      state.copyWith(
        status: HomePlansPaymentMethodStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      await repository.payNow(methodId: state.selectedMethodId!);
      emit(
        state.copyWith(
          status: HomePlansPaymentMethodStatus.success,
          navTarget: HomePlansPaymentMethodNavTarget.paid,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: HomePlansPaymentMethodStatus.failure,
          errorMessage: 'Payment failed. Try again.',
        ),
      );
    }
  }

  void _onNavConsumed(
    HomePlansPaymentNavConsumed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) {
    emit(state.copyWith(navTarget: HomePlansPaymentMethodNavTarget.none));
  }
}
