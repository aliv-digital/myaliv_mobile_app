import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';

import '../repository/make_payment_confirmation_postpaid_repository.dart';
import 'make_payment_confirmation_postpaid_event.dart';
import 'make_payment_confirmation_postpaid_state.dart';

class MakePaymentConfirmationPostPaidBloc extends Bloc<
    MakePaymentConfirmationPostPaidEvent,
    MakePaymentConfirmationPostPaidState> {
  final MakePaymentConfirmationPostPaidRepository repository;

  MakePaymentConfirmationPostPaidBloc({required this.repository})
      : super(MakePaymentConfirmationPostPaidState.initial()) {
    on<MakePaymentConfirmationPostPaidStarted>(_onStarted);
    on<MakePaymentPromoCodeChanged>(_onPromoChanged);
    on<MakePaymentPromoApplyPressed>(_onApplyPromo);
    on<MakePaymentContinuePressed>(_onContinue);
    on<MakePaymentNavConsumed>(_onNavConsumed);
  }

  Future<void> _onStarted(
    MakePaymentConfirmationPostPaidStarted event,
    Emitter<MakePaymentConfirmationPostPaidState> emit,
  ) async {
    final data = await repository.fetchConfirmation();

    final deviceLimitsState = instance<DeviceLimitsCubit>().state;
    final email = instance<AccountInfoCubit>().state.accountInfo?.email ?? '';
    final balanceState = instance<BalanceCubit>().state;

    final customerName = deviceLimitsState.fullName ?? _nameFromEmail(email);
    final accountNumber =
        _formatPhone(deviceLimitsState.deviceLimits?.tn ?? '');
    final amount = BalanceCurrencyFormatterService.format(
      balanceState.walletBalance,
    );

    emit(
      state.copyWith(
        title: data.title,
        customerName: customerName,
        accountNumber: accountNumber,
        headerLabel: data.headerLabel,
        amountPill: amount,
        subtotal: amount,
        vat: data.vat,
        total: amount,
        bottomSubtitle: data.bottomSubtitle,
        bottomAmount: amount,
      ),
    );
  }

  String _nameFromEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return '';
    return email.split('@').first;
  }

  String _formatPhone(String phone) {
    if (phone.isEmpty) return '';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    if (digits.length == 11 && digits.startsWith('1')) {
      return '${digits.substring(1, 4)}-${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    return phone;
  }

  void _onPromoChanged(
    MakePaymentPromoCodeChanged event,
    Emitter<MakePaymentConfirmationPostPaidState> emit,
  ) {
    final trimmed = event.value.trim();
    emit(
      state.copyWith(
        promoCode: event.value,
        canApplyPromo: trimmed.isNotEmpty,
      ),
    );
  }

  Future<void> _onApplyPromo(
    MakePaymentPromoApplyPressed event,
    Emitter<MakePaymentConfirmationPostPaidState> emit,
  ) async {
    if (!state.canApplyPromo) return;
    await repository.applyPromo(code: state.promoCode.trim());
  }

  void _onContinue(
    MakePaymentContinuePressed event,
    Emitter<MakePaymentConfirmationPostPaidState> emit,
  ) {
    emit(state.copyWith(navTarget: MakePaymentConfirmationNavTarget.next));
  }

  void _onNavConsumed(
    MakePaymentNavConsumed event,
    Emitter<MakePaymentConfirmationPostPaidState> emit,
  ) {
    emit(state.copyWith(navTarget: MakePaymentConfirmationNavTarget.none));
  }
}
