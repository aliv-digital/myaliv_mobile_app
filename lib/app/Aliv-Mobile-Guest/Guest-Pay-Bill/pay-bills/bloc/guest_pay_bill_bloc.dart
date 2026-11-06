import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/core/model/line_status.dart';
import '../model/guest_pay_bill_models.dart';
import '../theme/guest_pay_bill_theme.dart';
import '../repository/guest_pay_bill_repository.dart';
import 'guest_pay_bill_event.dart';
import 'guest_pay_bill_state.dart';

class GuestPayBillBloc extends Bloc<GuestPayBillEvent, GuestPayBillState> {
  final GuestPayBillRepository repo;
  int _verificationRevision = 0;

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
      BillService defaultService = services.first;
      final targetCode = event.initialServiceCode?.trim().toUpperCase();
      if (targetCode != null && targetCode.isNotEmpty) {
        defaultService = services.firstWhere(
          (s) => s.code.toUpperCase() == targetCode,
          orElse: () => services.first,
        );
      }
      emit(
        state.copyWith(
          loadStatus: GuestPayBillLoadStatus.ready,
          services: services,
          selectedService: defaultService,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loadStatus: GuestPayBillLoadStatus.failure,
          errorMessage: 'Failed to load network',
        ),
      );
    }
  }

  void _onServiceChanged(
    GuestPayBillServiceChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    _verificationRevision++;
    emit(
      state.copyWith(
        selectedService: event.service,
        selectedCountry: PayBillCountry.defaultCountry,
        // reset all inputs + verification
        accountNumber: '',
        name: '',
        mobileNumber: '',
        confirmMobileNumber: '',
        amountText: '',
        clearAccountInfo: true,
        verifyStatus: GuestPayBillVerifyStatus.idle,
        submitStatus: GuestPayBillSubmitStatus.idle,
        errorMessage: null,
      ),
    );
  }

  void _onCountryChanged(
    GuestPayBillCountryChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    _verificationRevision++;
    emit(
      state.copyWith(
        selectedCountry: event.country,
        clearAccountInfo: true,
        verifyStatus: GuestPayBillVerifyStatus.idle,
        errorMessage: null,
      ),
    );
  }

  void _onAccountChanged(
    GuestPayBillAccountNumberChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    _verificationRevision++;
    emit(
      state.copyWith(
        accountNumber: event.value,
        clearAccountInfo: true,
        verifyStatus: GuestPayBillVerifyStatus.idle,
        errorMessage: null,
      ),
    );
  }

  void _onNameChanged(
    GuestPayBillNameChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    _verificationRevision++;
    emit(
      state.copyWith(
        name: event.value,
        clearAccountInfo: true,
        verifyStatus: GuestPayBillVerifyStatus.idle,
        errorMessage: null,
      ),
    );
  }

  void _onMobileChanged(
    GuestPayBillMobileChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    _verificationRevision++;
    emit(
      state.copyWith(
        mobileNumber: event.value,
        clearAccountInfo: true,
        verifyStatus: GuestPayBillVerifyStatus.idle,
        errorMessage: null,
      ),
    );
  }

  void _onConfirmMobileChanged(
    GuestPayBillConfirmMobileChanged event,
    Emitter<GuestPayBillState> emit,
  ) {
    _verificationRevision++;
    emit(
      state.copyWith(
        confirmMobileNumber: event.value,
        clearAccountInfo: true,
        verifyStatus: GuestPayBillVerifyStatus.idle,
        errorMessage: null,
      ),
    );
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

    final requestState = state;
    final revision = ++_verificationRevision;
    emit(
      state.copyWith(
        verifyStatus: GuestPayBillVerifyStatus.loading,
        errorMessage: null,
        clearAccountInfo: true,
      ),
    );

    try {
      final info = requestState.isAlivPostpaid
          ? await repo.verifyAlivPostpaid(
              mobileNumber: requestState.mobileNumber,
              confirmMobileNumber: requestState.confirmMobileNumber,
            )
          : requestState.isAlivFibr
          ? await repo.verifyAlivFibr(
              accountNumberOrUsername: requestState.accountNumber,
              enteredName: requestState.name,
            )
          : await repo.verifyRev(
              accountNumber: requestState.accountNumber,
              enteredName: requestState.name,
            );

      // A response belongs only to the service and inputs that requested it.
      if (emit.isDone || revision != _verificationRevision) {
        return;
      }
      emit(
        state.copyWith(
          verifyStatus: GuestPayBillVerifyStatus.success,
          accountInfo: info,
        ),
      );
    } catch (e) {
      if (emit.isDone || revision != _verificationRevision) {
        return;
      }
      final serverMessage = _extractMessage(e);
      emit(
        state.copyWith(
          verifyStatus: GuestPayBillVerifyStatus.failure,
          errorMessage:
              serverMessage ??
              (requestState.isAlivPostpaid
                  ? 'Mobile number mismatch or invalid.'
                  : 'Account not found. Please check details.'),
          clearAccountInfo: true,
        ),
      );
    }
  }

  Future<void> _onSubmitPressed(
    GuestPayBillSubmitPressed event,
    Emitter<GuestPayBillState> emit,
  ) async {
    if (!state.canSubmit) return;

    // Previous prepaid-only check retained for reference.
    // if (state.isAlivPostpaid &&
    //     state.accountInfo?.paymentOption ==
    //         GuestPayBillTheme.paymentOptionPrePay) {
    //   emit(
    //     state.copyWith(
    //       submitStatus: GuestPayBillSubmitStatus.failure,
    //       errorMessage: GuestPayBillTheme.prepaidNumberErrorMessage,
    //     ),
    //   );
    //   return;
    // }

    final accountInfo = state.accountInfo;
    if (state.isAlivPostpaid &&
        (!LineStatus.fromCode(accountInfo?.status).isActive ||
            accountInfo?.paymentOption?.trim().toLowerCase() !=
                GuestPayBillTheme.paymentOptionPostPay.toLowerCase())) {
      // Clear a previous rejection so each retry can show the toast again.
      emit(
        state.copyWith(
          submitStatus: GuestPayBillSubmitStatus.idle,
          errorMessage: null,
        ),
      );
      emit(
        state.copyWith(
          submitStatus: GuestPayBillSubmitStatus.failure,
          errorMessage: GuestPayBillTheme.invalidActivePostpaidErrorMessage,
        ),
      );
      return;
    }

    if (state.isAlivFibr &&
        !LineStatus.fromCode(accountInfo?.status).isActive) {
      // Clear a previous rejection so each retry can show the toast again.
      emit(
        state.copyWith(
          submitStatus: GuestPayBillSubmitStatus.idle,
          errorMessage: null,
        ),
      );
      emit(
        state.copyWith(
          submitStatus: GuestPayBillSubmitStatus.failure,
          errorMessage: GuestPayBillTheme.invalidActiveFibrErrorMessage,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        submitStatus: GuestPayBillSubmitStatus.loading,
        errorMessage: null,
      ),
    );

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
      emit(
        state.copyWith(
          submitStatus: GuestPayBillSubmitStatus.failure,
          errorMessage: 'Payment failed. Try again.',
        ),
      );
    }
  }

  /// Extracts the server's `Message` field from a [NetworkException] response
  /// body. Returns null if the exception carries no useful message so the
  /// caller can fall back to a generic string.
  String? _extractMessage(Object e) {
    if (e is! NetworkException) return null;
    final data = e.data;
    if (data is Map) {
      final msg = data['Message'] ?? data['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
    final msg = e.message.trim();
    if (msg.isNotEmpty && msg != 'An error occurred') return msg;
    return null;
  }
}
