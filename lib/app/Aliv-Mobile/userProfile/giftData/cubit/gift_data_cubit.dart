import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/cubit/gift_data_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/data_share_status.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/repository/gift_data_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/repository/services/gift_data_api_client.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';

class GiftDataCubit extends Cubit<GiftDataState> {
  GiftDataCubit({
    required GiftDataRepository repository,
    required AccountInfoCubit accountInfoCubit,
    required DeviceLimitsCubit deviceLimitsCubit,
  }) : _repository = repository,
       _accountInfoCubit = accountInfoCubit,
       _deviceLimitsCubit = deviceLimitsCubit,
       super(GiftDataState.initial());

  final GiftDataRepository _repository;
  final AccountInfoCubit _accountInfoCubit;
  final DeviceLimitsCubit _deviceLimitsCubit;

  /// Sender MSISDN sourced from the authenticated account; prefers the
  /// device-aware `primaryPhoneNumber`, falls back to `phoneNumber` for
  /// older account payloads that don't include it.
  String get _senderMsisdn {
    final account = _accountInfoCubit.state.accountInfo;
    if (account == null) return '';
    final primary = account.primaryPhoneNumber.trim();
    if (primary.isNotEmpty) return primary;
    return account.phoneNumber.trim();
  }

  Future<void> load() async {
    emit(state.copyWith(status: GiftDataStatus.loading, clearError: true));

    if (_senderMsisdn.isEmpty) {
      emit(
        state.copyWith(
          status: GiftDataStatus.failure,
          errorMessage: 'account phone number is not available',
        ),
      );
      return;
    }

    // Resolve device account id from /Account/devices via DeviceLimitsCubit.
    // That cubit is a GetIt singleton; `/Account/devices` is already fetched
    // during home-screen boot (see HomeScreen.loadDeviceLimits call), so we
    // just read the cached state here.
    final deviceAccountId =
        _deviceLimitsCubit.state.deviceLimits?.deviceId ?? 0;

    // On load we only fetch the sender's quota window (`data-share-status`),
    // which powers the "until <date> you can gift up to <Xgb>" banner. The
    // sender's `can-send-data-share` call is deliberately NOT fired here —
    // the chip catalog comes from the recipient's `can-send-data-share`
    // response (see `_checkRecipient`) once the two recipient fields match.
    DataShareStatus? shareStatus;
    if (deviceAccountId > 0) {
      try {
        shareStatus = await _repository.fetchDataShareStatus(deviceAccountId);
      } catch (_) {
        shareStatus = null;
      }
    }

    emit(
      state.copyWith(
        status: GiftDataStatus.ready,
        shareStatus: shareStatus,
        clearShareStatus: shareStatus == null,
        clearIneligibleReason: true,
      ),
    );
  }

  /// Monotonic generation for recipient-eligibility checks. Each new fetch
  /// bumps this counter and captures the value; stale responses (from a
  /// slower earlier request, or a response that lands after the user cleared
  /// a digit) are detected and dropped so the UI never shows older data.
  int _recipientCheckGen = 0;

  /// Debounce window between the last recipient keystroke and the API call.
  /// Prevents hammering `can-send-data-share` while the user is still
  /// typing or correcting digits.
  static const Duration _recipientDebounceWindow = Duration(milliseconds: 400);
  Timer? _recipientDebounce;

  void recipientChanged(String value) {
    emit(state.copyWith(recipient: value, clearError: true));
    _maybeCheckRecipient();
  }

  void confirmRecipientChanged(String value) {
    emit(state.copyWith(confirmRecipient: value, clearError: true));
    _maybeCheckRecipient();
  }

  /// Decides whether to fire `can-send-data-share` for the current recipient:
  /// - If the two fields no longer match / are no longer 10 digits, we drop
  ///   any previously-loaded recipient catalog + any pending debounced call
  ///   so the chip grid + banner both hide and the current selection clears.
  /// - If both fields match a 10-digit number we haven't fetched before,
  ///   enter the "checking" state immediately (so the shimmer shows) and
  ///   schedule the real request after the debounce window.
  /// - Cached (same digits already fetched) — no-op.
  void _maybeCheckRecipient() {
    final s = state;

    if (!s.isRecipientComplete) {
      _recipientDebounce?.cancel();
      final hasStaleData =
          s.amountOptions.isNotEmpty ||
          s.amountOptionsFor != null ||
          s.isCheckingRecipient ||
          s.recipientErrorMessage != null;
      if (!hasStaleData) return;
      _recipientCheckGen++;
      emit(
        s.copyWith(
          amountOptions: const <GiftAmountOption>[],
          clearAmountOptionsFor: true,
          isCheckingRecipient: false,
          clearSelectedAmount: true,
          clearRecipientErrorMessage: true,
        ),
      );
      return;
    }

    final digits = s.recipient.replaceAll(RegExp(r'\D'), '');
    if (s.amountOptionsFor == digits) return;

    // Entering a new recipient — the previously-loaded catalog (if any) is
    // now stale. Clear it immediately so the shimmer replaces real chips
    // rather than the user briefly seeing options for the wrong number.
    _recipientDebounce?.cancel();
    _recipientCheckGen++;
    emit(
      s.copyWith(
        amountOptions: const <GiftAmountOption>[],
        clearAmountOptionsFor: true,
        isCheckingRecipient: true,
        clearSelectedAmount: true,
        clearRecipientErrorMessage: true,
      ),
    );

    _recipientDebounce = Timer(_recipientDebounceWindow, () {
      // Guard: user may have invalidated the request during the debounce
      // (edited a digit, mismatched the confirm field, etc.).
      if (!state.isRecipientComplete) return;
      final latestDigits = state.recipient.replaceAll(RegExp(r'\D'), '');
      if (latestDigits != digits) return;
      _checkRecipient(digits);
    });
  }

  Future<void> _checkRecipient(String digits) async {
    final gen = _recipientCheckGen;
    try {
      final result = await _repository.fetchSendDataShareOptions(digits);
      if (gen != _recipientCheckGen) return;
      emit(
        state.copyWith(
          amountOptions: result.options,
          amountOptionsFor: digits,
          isCheckingRecipient: false,
          // Any previously-picked amount belongs to a prior catalog — drop it
          // so the user re-picks from the new recipient's options.
          clearSelectedAmount: true,
          clearRecipientErrorMessage: true,
        ),
      );
    } catch (e) {
      if (gen != _recipientCheckGen) return;
      final message = e is GiftDataApiException
          ? e.message
          : 'could not verify recipient — please try again';
      emit(
        state.copyWith(
          amountOptions: const <GiftAmountOption>[],
          amountOptionsFor: digits,
          isCheckingRecipient: false,
          clearSelectedAmount: true,
          recipientErrorMessage: message,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _recipientDebounce?.cancel();
    return super.close();
  }

  void amountSelected(GiftAmountOption option) {
    emit(state.copyWith(selectedAmount: option, clearError: true));
  }

  Future<String?> submit() async {
    if (!state.isFormValid || state.isSubmitting) return null;
    emit(state.copyWith(status: GiftDataStatus.submitting, clearError: true));
    try {
      final orderId = await _repository.submitGift(
        senderMsisdn: _senderMsisdn,
        recipientMsisdn: state.recipient,
        planId: state.selectedAmount!.planId,
      );
      final orderRef = orderId.toString();
      emit(
        state.copyWith(
          status: GiftDataStatus.success,
          orderReference: orderRef,
        ),
      );
      return orderRef;
    } catch (e) {
      // Stay on the form (status: ready) and surface the clean server message
      // via `errorMessage` — the screen listens and shows it in a toast
      // rather than switching to the full-screen error view.
      final message = e is GiftDataApiException
          ? e.message.toLowerCase()
          : 'could not send gift — please try again';
      emit(state.copyWith(status: GiftDataStatus.ready, errorMessage: message));
      return null;
    }
  }
}
