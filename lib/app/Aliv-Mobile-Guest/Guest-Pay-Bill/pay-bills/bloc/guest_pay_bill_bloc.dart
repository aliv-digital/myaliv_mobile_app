import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/model/guest_pay_bill_models.dart';
import '../repository/guest_pay_bill_repository.dart';
import 'guest_pay_bill_event.dart';
import 'guest_pay_bill_state.dart';

class GuestPayBillBloc extends Bloc<GuestPayBillEvent, GuestPayBillState> {
  final GuestPayBillRepository repo;

  GuestPayBillBloc({GuestPayBillRepository? repo})
      : repo = repo ?? GuestPayBillRepository(),
        super(GuestPayBillState.initial()) {
    on<GuestPayBillStarted>(_onStarted);
    on<GuestPayBillServiceChanged>(_onServiceChanged);

    on<GuestPayBillAccountNumberChanged>(_onAccountChanged);
    on<GuestPayBillNameChanged>(_onNameChanged);

    on<GuestPayBillMobileChanged>(_onMobileChanged);
    on<GuestPayBillConfirmMobileChanged>(_onConfirmMobileChanged);
    on<GuestPayBillCountryChanged>(_onCountryChanged);

    on<GuestPayBillAmountChanged>(_onAmountChanged);
    on<GuestPayBillVerifyPressed>(_onVerifyPressed);
    on<GuestPayBillSubmitPressed>(_onSubmitPressed);
  }

  Future<void> _onStarted(
    GuestPayBillStarted event,
    Emitter<GuestPayBillState> emit,
  ) async {
    emit(state.copyWith(loadStatus: GuestPayBillLoadStatus.loading));
    try {
      final services = await repo.fetchServices();
      emit(state.copyWith(
        loadStatus: GuestPayBillLoadStatus.ready,
        services: services,
        // optional: default select ALIV Postpaid like screenshot
        selectedService: services.first,
      ));
    } catch (_) {
      emit(state.copyWith(
        loadStatus: GuestPayBillLoadStatus.failure,
        errorMessage: 'Failed to load network',
      ));
    }
  }

  void _onServiceChanged(
    GuestPayBillServiceChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    emit(state.copyWith(
      selectedService: event.service,
      selectedCountry: PayBillCountry.defaultCountry,
      // reset all inputs + verification
      accountNumber: '',
      name: '',
      mobileNumber: '',
      confirmMobileNumber: '',
      accountInfo: null,
      verifyStatus: GuestPayBillVerifyStatus.idle,
      submitStatus: GuestPayBillSubmitStatus.idle,
      errorMessage: null,
    ));
  }

  void _onCountryChanged(
    GuestPayBillCountryChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    emit(state.copyWith(
      selectedCountry: event.country,
      accountInfo: null,
      verifyStatus: GuestPayBillVerifyStatus.idle,
      errorMessage: null,
    ));
  }

  void _onAccountChanged(
    GuestPayBillAccountNumberChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    emit(state.copyWith(
      accountNumber: event.value,
      accountInfo: null,
      verifyStatus: GuestPayBillVerifyStatus.idle,
      errorMessage: null,
    ));
  }

  void _onNameChanged(
    GuestPayBillNameChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    emit(state.copyWith(
      name: event.value,
      accountInfo: null,
      verifyStatus: GuestPayBillVerifyStatus.idle,
      errorMessage: null,
    ));
  }

  void _onMobileChanged(
    GuestPayBillMobileChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    emit(state.copyWith(
      mobileNumber: event.value,
      accountInfo: null,
      verifyStatus: GuestPayBillVerifyStatus.idle,
      errorMessage: null,
    ));
  }

  void _onConfirmMobileChanged(
    GuestPayBillConfirmMobileChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    emit(state.copyWith(
      confirmMobileNumber: event.value,
      accountInfo: null,
      verifyStatus: GuestPayBillVerifyStatus.idle,
      errorMessage: null,
    ));
  }

  void _onAmountChanged(
    GuestPayBillAmountChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    emit(state.copyWith(amountText: event.value, errorMessage: null));
  }

  Future<void> _onVerifyPressed(
    GuestPayBillVerifyPressed event,
    Emitter<GuestPayBillState> emit,
  ) async {
    if (!state.canVerify) return;

    emit(state.copyWith(
      verifyStatus: GuestPayBillVerifyStatus.loading,
      errorMessage: null,
      accountInfo: null,
    ));

    try {
      final info = state.isAlivPostpaid
          ? await repo.verifyAlivPostpaid(
              mobileNumber: state.mobileNumber,
              confirmMobileNumber: state.confirmMobileNumber,
            )
          : state.isAlivFibr
              ? await repo.verifyAlivFibr(
                  accountNumberOrUsername: state.accountNumber,
                  enteredName: state.name,
                )
              : await repo.verifyRev(
                  accountNumber: state.accountNumber,
                  enteredName: state.name,
                );

      emit(state.copyWith(
        verifyStatus: GuestPayBillVerifyStatus.success,
        accountInfo: info,
      ));
    } catch (_) {
      emit(state.copyWith(
        verifyStatus: GuestPayBillVerifyStatus.failure,
        errorMessage: state.isAlivPostpaid
            ? 'Mobile number mismatch or invalid.'
            : 'Account not found. Please check details.',
        accountInfo: null,
      ));
    }
  }

  Future<void> _onSubmitPressed(
    GuestPayBillSubmitPressed event,
    Emitter<GuestPayBillState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(
      submitStatus: GuestPayBillSubmitStatus.loading,
      errorMessage: null,
    ));

    try {
      final identifier = state.isAlivPostpaid
          ? state.mobileNumber.trim()
          : state.accountNumber.trim();

      await repo.submitBillPayment(
        serviceCode: state.selectedService!.code,
        identifier: identifier,
        amount: state.amountValue,
      );

      emit(state.copyWith(submitStatus: GuestPayBillSubmitStatus.success));
    } catch (_) {
      emit(state.copyWith(
        submitStatus: GuestPayBillSubmitStatus.failure,
        errorMessage: 'Payment failed. Try again.',
      ));
    }
  }
}
