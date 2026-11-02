import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import '../model/home_plans_payment_method_models.dart';
import '../repository/home_plans_payment_method_repository.dart';
import 'home_plans_payment_method_event.dart';
import 'home_plans_payment_method_state.dart';

class HomePlansPaymentMethodBloc
    extends Bloc<HomePlansPaymentMethodEvent, HomePlansPaymentMethodState> {
  final HomePlansPaymentMethodRepository repository;
  final AnalyticsService _analyticsService;

  HomePlansPaymentMethodBloc({
    required this.repository,
    AnalyticsService? analyticsService,
  }) : _analyticsService =
           analyticsService ??
           (instance.isRegistered<AnalyticsService>()
               ? instance<AnalyticsService>()
               : AnalyticsService()),
       super(HomePlansPaymentMethodState.initial()) {
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
    on<HomePlans3DSPayWithCardSucceeded>(_on3DSSucceeded);
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
        bonuses: event.bonuses,
        forceNow: event.forceNow,
        purchaseContext: event.purchaseContext,
        hasConfirmed3DSPayment: false,
        walletPaymentSucceeded: false,
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
    _fireAddPaymentInfoIfChanged(HomePlansPaymentMode.card);
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
    _fireAddPaymentInfoIfChanged(HomePlansPaymentMode.chargeToMyAccount);
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
    _fireAddPaymentInfoIfChanged(HomePlansPaymentMode.payWithCard);
    emit(state.copyWith(paymentMode: HomePlansPaymentMode.payWithCard));
  }

  // Pure selection: just flip the radio. Navigation happens when PAY NOW is tapped.
  void _onPayFromWallet(
    HomePlansPayFromWalletPressed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) {
    _fireAddPaymentInfoIfChanged(HomePlansPaymentMode.payFromWallet);
    emit(state.copyWith(paymentMode: HomePlansPaymentMode.payFromWallet));
  }

  Future<void> _onPayFromWalletConfirmed(
    HomePlansPayFromWalletConfirmed event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) async {
    // Do not hit the wallet payment API unless balance can cover the order.
    if (!_hasEnoughWalletBalance(event.walletBalance)) {
      await _analyticsService.logPurchaseFailed(
        failureReason: AnalyticsPurchaseFailureReason.insufficientWalletBalance,
        paymentMethod: _paymentMethodLabel(state.paymentMode),
        value: state.amount,
      );
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
        bonuses: state.bonuses,
        forceNow: state.forceNow,
        selectedBeginDate: state.selectedBeginDate,
      ),
      'Wallet payment failed. Try again.',
      walletPayment: state.isPrepaidUser,
    );
  }

  Future<void> _onChargeToAccountRequested(
    HomePlansChargeToAccountRequested event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) async {
    // Postpaid charges do not depend on wallet balance. The shared service
    // automatically sends postpaid plan orders to /Order/payment.
    await _submitChangeBundle(
      emit,
      () => repository.chargeToAccount(
        amount: state.amount,
        selectedItems: state.selectedItems,
        promoCodes: state.promoCodes,
        bonuses: state.bonuses,
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
        bonuses: state.bonuses,
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
        bonuses: state.bonuses,
        forceNow: state.forceNow,
        selectedBeginDate: state.selectedBeginDate,
      ),
      'Card payment failed. Try again.',
    );
  }

  /// Wraps the submit → success/failure transition for any change-bundle call.
  /// Centralises the [HomePlansPaymentMethodStatus.submitting] guard, error
  /// mapping, and nav-target on success so wallet and saved-card paths stay
  /// in lockstep. The [invoke] callback returns the [OrderId] from the API
  /// (null when the API omits it), which is stored in state for the receipt.
  Future<void> _submitChangeBundle(
    Emitter<HomePlansPaymentMethodState> emit,
    Future<int?> Function() invoke,
    String failureFallback, {
    bool walletPayment = false,
  }) async {
    if (state.status == HomePlansPaymentMethodStatus.submitting) return;

    emit(
      state.copyWith(
        status: HomePlansPaymentMethodStatus.submitting,
        errorMessage: null,
        walletPaymentSucceeded: false,
      ),
    );

    await _firePurchaseAttempted();
    try {
      final orderId = await invoke();
      await _logPurchaseAnalytics(transactionId: orderId?.toString());
      emit(
        state.copyWith(
          status: HomePlansPaymentMethodStatus.success,
          navTarget: HomePlansPaymentMethodNavTarget.paid,
          orderId: orderId?.toString(),
          walletPaymentSucceeded: walletPayment,
        ),
      );
    } catch (error) {
      await _firePurchaseFailed(error);
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
        walletPaymentSucceeded: false,
      ),
    );

    await _firePurchaseAttempted();
    try {
      await repository.payNow(methodId: state.selectedMethodId!);
      await _logPurchaseAnalytics();
      emit(
        state.copyWith(
          status: HomePlansPaymentMethodStatus.success,
          navTarget: HomePlansPaymentMethodNavTarget.paid,
        ),
      );
    } catch (error) {
      await _firePurchaseFailed(error);
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

  Future<void> _on3DSSucceeded(
    HomePlans3DSPayWithCardSucceeded event,
    Emitter<HomePlansPaymentMethodState> emit,
  ) async {
    if (state.replacementPrimaryPlanTitle != null) {
      emit(state.copyWith(hasConfirmed3DSPayment: true));
    }
    await _logPurchaseAnalytics(transactionId: event.orderId);
    emit(
      state.copyWith(
        status: HomePlansPaymentMethodStatus.success,
        navTarget: HomePlansPaymentMethodNavTarget.paid,
        orderId: event.orderId,
        walletPaymentSucceeded: false,
      ),
    );
  }

  // Fires GA4's standard `purchase` event; `item_category` discriminates
  // bundle (primary plan type) from add-on in Monetisation → Ecommerce reports.
  Future<void> _logPurchaseAnalytics({String? transactionId}) async {
    if (state.selectedItems.isEmpty) return;
    final item = state.selectedItems.first;
    final isPrimary = item.planType == HomePlansPaymentPlanType.primary;
    final paymentMethod = _paymentMethodLabel(state.paymentMode);
    final promoCode = _resolvedPromoCode();

    await _analyticsService.logPurchase(
      itemId: item.id,
      itemName: item.title,
      itemCategory: isPrimary
          ? AnalyticsItemCategory.plan
          : AnalyticsItemCategory.addon,
      amount: state.amount,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      // "funding attributes of a purchase" per spec — promo code wins over
      // payment method when both are present (that was the actual funding
      // choice; the card/wallet was just the top-up medium).
      fundingSource: promoCode != null ? 'promo_code' : paymentMethod,
      promoCode: promoCode,
      planType: _planTypeLabel(),
    );
  }

  Future<void> _firePurchaseAttempted() async {
    await _analyticsService.logPurchaseAttempted(
      paymentMethod: _paymentMethodLabel(state.paymentMode),
      value: state.amount,
      planType: _planTypeLabel(),
    );
  }

  Future<void> _firePurchaseFailed(Object error) async {
    await _analyticsService.logPurchaseFailed(
      failureReason: AnalyticsPurchaseFailureReason.classify(error),
      paymentMethod: _paymentMethodLabel(state.paymentMode),
      value: state.amount,
    );
  }

  void _fireAddPaymentInfoIfChanged(HomePlansPaymentMode newMode) {
    if (state.paymentMode == newMode) return;
    _analyticsService.logAddPaymentInfo(
      paymentType: _paymentMethodLabel(newMode),
      value: state.amount,
      items: _itemsForAnalytics(),
    );
  }

  List<AnalyticsEventItem> _itemsForAnalytics() {
    return state.selectedItems
        .map(
          (item) => AnalyticsEventItem(
            itemId: item.id,
            itemName: item.title,
            itemCategory: item.planType == HomePlansPaymentPlanType.primary
                ? AnalyticsItemCategory.plan
                : AnalyticsItemCategory.addon,
            price: item.price,
            quantity: 1,
          ),
        )
        .toList();
  }

  String? _resolvedPromoCode() {
    if (state.promoCodes.isEmpty) return null;
    // The spec expects a single `promo_code` string. If multiple codes are
    // applied, join their IDs — rare, and non-sensitive IDs are safe to send.
    final ids = state.promoCodes
        .map((p) => p.promoCodeId.toString())
        .where((s) => s.isNotEmpty)
        .toList();
    if (ids.isEmpty) return null;
    return ids.join(',');
  }

  String _planTypeLabel() {
    if (!instance.isRegistered<AppUiConfigCubit>()) {
      // Fallback for test contexts where DI isn't fully bootstrapped.
      return state.subscriberType == HomePlansSubscriberType.postpaid
          ? 'postpaid'
          : 'prepaid';
    }
    return instance<AppUiConfigCubit>().state.userType.label;
  }

  /// Maps the internal [HomePlansPaymentMode] enum to the GA4 fixed vocab in
  /// [AnalyticsPaymentType]. Both `card` (saved card) and `payWithCard`
  /// (new card entry) collapse into `credit_card` because the backend does
  /// not distinguish debit from credit (Open Q10: splitting requires
  /// Finance sign-off + an IT change request). `chargeToMyAccount` is kept
  /// outside the spec's 4-value vocab because the spec has no term for it.
  String _paymentMethodLabel(HomePlansPaymentMode mode) {
    switch (mode) {
      case HomePlansPaymentMode.card:
      case HomePlansPaymentMode.payWithCard:
        return AnalyticsPaymentType.creditCard;
      case HomePlansPaymentMode.payFromWallet:
        return AnalyticsPaymentType.wallet;
      case HomePlansPaymentMode.chargeToMyAccount:
        return AnalyticsPaymentType.chargeToAccount;
    }
  }
}
