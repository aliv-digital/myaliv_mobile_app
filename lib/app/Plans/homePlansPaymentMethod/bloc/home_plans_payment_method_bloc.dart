import 'package:core/core.dart';
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
    on<HomePlansChargeToAccountSelected>(_onChargeToAccountSelected);
    on<HomePlansPayWithCardPressed>(_onPayWithCard);
    on<HomePlansPayFromWalletPressed>(_onPayFromWallet);
    on<HomePlansPayFromWalletConfirmed>(_onPayFromWalletConfirmed);
    on<HomePlansChargeToAccountRequested>(_onChargeToAccountRequested);
    on<HomePlansPaySavedCardConfirmed>(_onPaySavedCardConfirmed);
    on<HomePlansPayWithCardConfirmed>(_onPayWithCardConfirmed);
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
        promoCodes: event.promoCodes,
        forceNow: event.forceNow,
        selectedBeginDate: event.selectedBeginDate,
      ),
    );

    try {
      // Load payment methods based on subscriber type.
      final List<HomePlansSavedPaymentMethod> methods = await repository
          .fetchPaymentMethods(subscriberType: event.subscriberType);

      // Select the first available method by default.
      final HomePlansSavedPaymentMethod? defaultMethod = methods.isNotEmpty
          ? methods.first
          : null;
      emit(
        state.copyWith(
          status: HomePlansPaymentMethodStatus.ready,
          methods: methods,
          selectedMethodId: defaultMethod?.id,
          paymentMode: _paymentModeForDefaultMethod(defaultMethod),
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
    emit(
      state.copyWith(
        paymentMode: HomePlansPaymentMode.card,
        selectedMethodId: event.methodId,
      ),
    );
  }

  HomePlansPaymentMode _paymentModeForDefaultMethod(
    HomePlansSavedPaymentMethod? method,
  ) {
    if (method != null && method.isChargeToMyAccount) {
      return HomePlansPaymentMode.chargeToMyAccount;
    }

    return HomePlansPaymentMode.card;
  }

  void _onChargeToAccountSelected(
    HomePlansChargeToAccountSelected event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) {
    emit(
      state.copyWith(
        paymentMode: HomePlansPaymentMode.chargeToMyAccount,
        selectedMethodId: event.methodId,
      ),
    );
  }

  // Pure selection: just flip the radio. Navigation happens when PAY NOW is tapped.
  void _onPayWithCard(
    HomePlansPayWithCardPressed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) {
    emit(state.copyWith(paymentMode: HomePlansPaymentMode.payWithCard));
  }

  // Pure selection: just flip the radio. Navigation happens when PAY NOW is tapped.
  void _onPayFromWallet(
    HomePlansPayFromWalletPressed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) {
    emit(state.copyWith(paymentMode: HomePlansPaymentMode.payFromWallet));
  }

  Future<void> _onPayFromWalletConfirmed(
    HomePlansPayFromWalletConfirmed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) async {
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

    await _submitChangeBundle(
      emit,
      () => repository.payFromWallet(
        amount: state.amount,
        selectedItems: state.selectedItems,
        promoCodes: state.promoCodes,
        forceNow: state.forceNow,
        selectedBeginDate: state.selectedBeginDate,
      ),
      'Wallet payment failed. Try again.',
    );
  }

  Future<void> _onChargeToAccountRequested(HomePlansChargeToAccountRequested event, Emitter<HomePlansPaymentMethodState> emit) async {
    // Postpaid charges do not depend on wallet balance. The shared service
    // automatically sends postpaid plan orders to /Order/payment.
    await _submitChangeBundle(
      emit,
      () => repository.chargeToAccount(
        amount: state.amount,
        selectedItems: state.selectedItems,
        promoCodes: state.promoCodes,
        forceNow: state.forceNow,
        selectedBeginDate: state.selectedBeginDate,
      ),
      'Account charge failed. Try again.',
    );
  }

  Future<void> _onPaySavedCardConfirmed(
    HomePlansPaySavedCardConfirmed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) async {
    // In card mode the section widget passes the saved-card vault token as
    // the method id (see HomePlansPaymentMethodSection._buildSavedCardTile),
    // so [selectedMethodId] is the token we need for `CardPayment.CardNumber`.
    final token = state.selectedMethodId?.trim() ?? '';
    if (token.isEmpty) {
      emit(
        state.copyWith(
          status: HomePlansPaymentMethodStatus.failure,
          errorMessage: 'Please select a saved card first.',
        ),
      );
      return;
    }

    await _submitChangeBundle(
      emit,
      () => repository.payWithSavedCard(
        amount: state.amount,
        cardToken: token,
        selectedItems: state.selectedItems,
        promoCodes: state.promoCodes,
        forceNow: state.forceNow,
        selectedBeginDate: state.selectedBeginDate,
      ),
      'Card payment failed. Try again.',
    );
  }

  Future<void> _onPayWithCardConfirmed(
    HomePlansPayWithCardConfirmed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) {
    // Stash the details so the receipt builder can forward them as
    // `cardToSave` for the save-card affordance.
    emit(state.copyWith(lastNewCardDetails: event.details));
    return _submitChangeBundle(
      emit,
      () => repository.payWithCardDetails(
        amount: state.amount,
        details: event.details,
        selectedItems: state.selectedItems,
        promoCodes: state.promoCodes,
        forceNow: state.forceNow,
        selectedBeginDate: state.selectedBeginDate,
      ),
      'Card payment failed. Try again.',
    );
  }

  /// Wraps the submit → success/failure transition for any change-bundle call.
  /// Centralises the [HomePlansPaymentMethodStatus.submitting] guard, error
  /// mapping, and nav-target on success so wallet and saved-card paths stay
  /// in lockstep.
  Future<void> _submitChangeBundle(
    Emitter<HomePlansPaymentMethodState> emit,
    Future<bool> Function() invoke,
    String failureFallback,
  ) async {
    if (state.status == HomePlansPaymentMethodStatus.submitting) return;

    emit(
      state.copyWith(
        status: HomePlansPaymentMethodStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      final ok = await invoke();
      if (ok) await _logPurchaseAnalytics();
      emit(
        state.copyWith(
          status: ok
              ? HomePlansPaymentMethodStatus.success
              : HomePlansPaymentMethodStatus.failure,
          navTarget: ok
              ? HomePlansPaymentMethodNavTarget.paid
              : HomePlansPaymentMethodNavTarget.paymentFailed,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HomePlansPaymentMethodStatus.failure,
          navTarget: HomePlansPaymentMethodNavTarget.paymentFailed,
          errorMessage: _cleanErrorMessage(error, fallback: failureFallback),
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
      await _logPurchaseAnalytics();
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
          navTarget: HomePlansPaymentMethodNavTarget.paymentFailed,
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

  // Fires the correct GA4 event based on whether the purchase is a plan
  // bundle (primary plan type) or an add-on (secondary / standalone).
  Future<void> _logPurchaseAnalytics() async {
    if (state.selectedItems.isEmpty) return;
    final item = state.selectedItems.first;
    final paymentMethod = _paymentMethodLabel(state.paymentMode);
    final analytics = instance<AnalyticsService>();

    if (item.planType == HomePlansPaymentPlanType.primary) {
      await analytics.logPlanPurchase(
        planId: item.id,
        planName: item.title,
        amount: state.amount,
        paymentMethod: paymentMethod,
      );
    } else {
      await analytics.logAddonPurchase(
        addonId: item.id,
        addonName: item.title,
        amount: state.amount,
        paymentMethod: paymentMethod,
      );
    }
  }

  String _paymentMethodLabel(HomePlansPaymentMode mode) {
    switch (mode) {
      case HomePlansPaymentMode.card:
        return 'saved_card';
      case HomePlansPaymentMode.payWithCard:
        return 'new_card';
      case HomePlansPaymentMode.payFromWallet:
        return 'wallet';
      case HomePlansPaymentMode.chargeToMyAccount:
        return 'charge_to_account';
    }
  }
}
