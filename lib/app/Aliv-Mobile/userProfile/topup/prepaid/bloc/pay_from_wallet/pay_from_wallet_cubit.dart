import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/pay_from_wallet/pay_from_wallet_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/send_topup_repository.dart';

class PayFromWalletCubit extends Cubit<PayFromWalletState> {
  final SendTopupRepository _repository;

  PayFromWalletCubit(this._repository) : super(const PayFromWalletState());

  Future<void> submitTransfer({
    required String toNumber,
    required double amount,
  }) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(
      status: PayFromWalletStatus.submitting,
      clearError: true,
    ));

    try {
      await _repository.transfer(toNumber: toNumber, amount: amount);
      emit(state.copyWith(status: PayFromWalletStatus.success));
    } on SendTopupException catch (e) {
      emit(state.copyWith(
        status: PayFromWalletStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: PayFromWalletStatus.failure,
        errorMessage: 'Could not complete the transfer. Please try again.',
      ));
    }
  }
}
