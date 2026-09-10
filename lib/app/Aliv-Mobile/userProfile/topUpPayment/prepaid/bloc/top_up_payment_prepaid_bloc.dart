import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/bloc/top_up_payment_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/bloc/top_up_payment_prepaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/models/payment_summary.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/repository/top_up_payment_prepaid_repository.dart';
import 'package:core/core.dart';

class TopUpPaymentPrepaidBloc
    extends Bloc<TopUpPaymentPrepaidEvent, TopUpPaymentPrepaidState> {
  TopUpPaymentPrepaidBloc({TopUpPaymentPrepaidRepository? repository})
    : _repository = repository ?? TopUpPaymentPrepaidRepositoryImpl(),
      super(TopUpPaymentPrepaidState.initial()) {
    on<TopUpPaymentStarted>(_onStarted);
    on<PaymentMethodSelected>(_onSelected);
    on<PayWithCardPressed>(_onPayWithCard);
    on<PaySavedCardConfirmed>(_onPaySavedCardConfirmed);
    on<PayPostpaidSavedCard>(_onPayPostpaidSavedCard);
    on<PaymentNavConsumed>(_onNavConsumed);
  }

  final TopUpPaymentPrepaidRepository _repository;

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
    if (token.isEmpty) return;
    await _submit(
      emit: emit,
      phone: _accountPrimaryPhone(),
      cardToken: token,
    );
  }

  Future<void> _onPayPostpaidSavedCard(
    PayPostpaidSavedCard event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) async {
    final token = state.selectedMethodId?.trim() ?? '';
    if (token.isEmpty) return;
    final recipient = state.summary.recipientPhone?.trim() ?? '';
    if (recipient.isEmpty) return;
    await _submit(
      emit: emit,
      phone: recipient,
      cardToken: token,
    );
  }

  void _onNavConsumed(
    PaymentNavConsumed event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) {
    emit(state.copyWith(navTarget: TopUpPaymentNavTarget.none));
  }

  Future<void> _submit({
    required Emitter<TopUpPaymentPrepaidState> emit,
    required String phone,
    required String cardToken,
  }) async {
    if (phone.isEmpty) {
      emit(
        state.copyWith(
          status: TopUpPaymentStatus.failure,
          errorMessage: 'Phone number unavailable. Please try again.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: TopUpPaymentStatus.paying,
        clearErrorMessage: true,
      ),
    );

    try {
      await _repository.payWithSavedCard(
        amount: state.summary.total,
        primaryPhoneNumber: phone,
        cardToken: cardToken,
      );
      emit(
        state.copyWith(
          status: TopUpPaymentStatus.success,
          navTarget: TopUpPaymentNavTarget.paid,
        ),
      );
    } catch (e) {
      _cleanErrorMessage(emit, e.toString());
    }
  }

  void _cleanErrorMessage(
    Emitter<TopUpPaymentPrepaidState> emit,
    String raw,
  ) {
    final msg = raw.replaceFirst('Exception: ', '');
    emit(
      state.copyWith(
        status: TopUpPaymentStatus.failure,
        errorMessage: msg,
      ),
    );
  }

  String _accountPrimaryPhone() {
    final account = instance<AccountInfoCubit>().state.accountInfo;
    final primary = account?.primaryPhoneNumber.trim() ?? '';
    if (primary.isNotEmpty) return primary;
    return account?.phoneNumber.trim() ?? '';
  }
}
