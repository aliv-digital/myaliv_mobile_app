import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/bloc/top_up_payment_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/bloc/top_up_payment_prepaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/models/payment_summary.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/repository/top_up_payment_prepaid_repository.dart';

class TopUpPaymentPrepaidBloc
    extends Bloc<TopUpPaymentPrepaidEvent, TopUpPaymentPrepaidState> {
  final TopUpPaymentPrepaidRepository repository;

  TopUpPaymentPrepaidBloc(this.repository)
    : super(TopUpPaymentPrepaidState.initial()) {
    on<TopUpPaymentStarted>(_onStarted);
    on<PaymentMethodSelected>(_onSelected);
    on<PayWithCardPressed>(_onPayWithCard);
    on<PaySavedCardConfirmed>(_onPaySavedCardConfirmed);
    on<PayWithCardConfirmed>(_onPayWithCardConfirmed);
    on<PaymentNavConsumed>(_onNavConsumed);
  }

  void _onStarted(
    TopUpPaymentStarted event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) {
    final amount = event.amount ?? 0.0;
    emit(
      state.copyWith(
        status: TopUpPaymentStatus.ready,
        summary: PaymentSummary(
          total: amount,
          recipientPhone: event.recipientPhone,
          vatInclusive: false,
        ),
      ),
    );
  }

  void _onSelected(
    PaymentMethodSelected event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) {
    emit(
      state.copyWith(
        paymentMode: TopUpPaymentMode.card,
        selectedMethodId: event.paymentMethodId,
      ),
    );
  }

  void _onPayWithCard(
    PayWithCardPressed event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) {
    emit(state.copyWith(paymentMode: TopUpPaymentMode.payWithCard));
  }

  Future<void> _onPaySavedCardConfirmed(
    PaySavedCardConfirmed event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) async {
    final token = state.selectedMethodId?.trim() ?? '';
    if (token.isEmpty) {
      emit(
        state.copyWith(
          status: TopUpPaymentStatus.failure,
          errorMessage: 'Please select a saved card first.',
        ),
      );
      return;
    }

    final phone = _accountPrimaryPhone();
    if (phone.isEmpty) {
      emit(
        state.copyWith(
          status: TopUpPaymentStatus.failure,
          errorMessage: 'Account phone number unavailable. Please try again.',
        ),
      );
      return;
    }

    await _submit(
      emit,
      () => repository.payWithSavedCard(
        amount: state.summary.total,
        primaryPhoneNumber: phone,
        cardToken: token,
      ),
      'Top-up failed. Try again.',
    );
  }

  Future<void> _onPayWithCardConfirmed(
    PayWithCardConfirmed event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) async {
    final phone = _accountPrimaryPhone();
    if (phone.isEmpty) {
      emit(
        state.copyWith(
          status: TopUpPaymentStatus.failure,
          errorMessage: 'Account phone number unavailable. Please try again.',
        ),
      );
      return;
    }

    await _submit(
      emit,
      () => repository.payWithNewCard(
        amount: state.summary.total,
        primaryPhoneNumber: phone,
        details: event.details,
      ),
      'Top-up failed. Try again.',
    );
  }

  /// Top-up URL requires the account holder's primary phone number, which is
  /// owned by [AccountInfoCubit]. The `recipientPhone` on state.summary is
  /// display metadata only and is not appropriate for the API path.
  String _accountPrimaryPhone() {
    final account = instance<AccountInfoCubit>().state.accountInfo;
    final primary = account?.primaryPhoneNumber.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return account?.phoneNumber.trim() ?? '';
  }

  /// Shared submit → success/failure transition for both funding paths.
  /// Guards against double-submits, maps exceptions onto `errorMessage`, and
  /// arms the nav target on success so the view can push the receipt route.
  Future<void> _submit(
    Emitter<TopUpPaymentPrepaidState> emit,
    Future<bool> Function() invoke,
    String failureFallback,
  ) async {
    if (state.status == TopUpPaymentStatus.paying) return;

    emit(
      state.copyWith(
        status: TopUpPaymentStatus.paying,
        clearErrorMessage: true,
      ),
    );

    try {
      final ok = await invoke();
      emit(
        state.copyWith(
          status: ok
              ? TopUpPaymentStatus.success
              : TopUpPaymentStatus.failure,
          navTarget: ok
              ? TopUpPaymentNavTarget.paid
              : TopUpPaymentNavTarget.none,
          errorMessage: ok ? null : failureFallback,
          clearErrorMessage: ok,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: TopUpPaymentStatus.failure,
          errorMessage: _cleanErrorMessage(error, fallback: failureFallback),
        ),
      );
    }
  }

  String _cleanErrorMessage(Object error, {required String fallback}) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? fallback : message;
  }

  void _onNavConsumed(
    PaymentNavConsumed event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) {
    emit(state.copyWith(navTarget: TopUpPaymentNavTarget.none));
  }
}
