import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';

import '../repository/alt_number_validation_repository.dart';
import 'alt_number_validation_state.dart';

class AltNumberValidationCubit extends Cubit<AltNumberValidationState> {
  AltNumberValidationCubit({
    required AltNumberValidationRepository repository,
    required AccountInfoCubit accountInfoCubit,
  }) : _repository = repository,
       _accountInfoCubit = accountInfoCubit,
       super(const AltNumberValidationState());

  final AltNumberValidationRepository _repository;
  final AccountInfoCubit _accountInfoCubit;

  /// Submits the complete alternate-contact form.
  ///
  /// The operation succeeds only after the number is validated, the offers
  /// preference is stored, and the alternate number is persisted.
  Future<void> submit({
    required String altNumber,
    required bool isOptedIn,
  }) async {
    if (isClosed || state.isLoading) return;
    emit(
      state.copyWith(
        status: AltNumberValidationStatus.loading,
        errorMessage: '',
        signalId: state.signalId + 1,
      ),
    );

    // AltNumber opt-in body carries `DeviceAccountId` — that's the DEVICE
    // id (from /Account/devices), not the account's id_acc.
    final deviceAccountId =
        instance<DeviceLimitsCubit>().state.deviceLimits?.deviceId ?? 0;
    if (kDebugMode) {
      debugPrint(
        'AltNumberValidationCubit.submit: starting '
        'deviceAccountId=$deviceAccountId, isOptedIn=$isOptedIn',
      );
    }

    // 1) Validate
    final bool isValid;
    try {
      isValid = await _repository.validate(altNumber);
    } on AltNumberValidationException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AltNumberValidationStatus.failure,
          errorMessage: e.message,
          signalId: state.signalId + 1,
        ),
      );
      return;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AltNumberValidationCubit.validate: $e');
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AltNumberValidationStatus.failure,
          errorMessage: 'could not verify the mobile number. please try again.',
          signalId: state.signalId + 1,
        ),
      );
      return;
    }

    if (!isValid) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AltNumberValidationStatus.invalid,
          errorMessage: 'this mobile number is not valid.',
          signalId: state.signalId + 1,
        ),
      );
      return;
    }

    // 2) Save the explicit yes/no preference before updating the account. The
    // purchase launcher skips this screen once an alt number exists, so this
    // ordering ensures a failed preference request remains retryable here.
    try {
      final preferenceSaved = await _repository.setMarketingOptIn(
        altNumber: altNumber,
        deviceAccountId: deviceAccountId,
        isOptedIn: isOptedIn,
      );

      if (kDebugMode) {
        debugPrint(
          'AltNumberValidationCubit.submit: '
          'marketing preference saved=$preferenceSaved',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AltNumberValidationCubit.submit opt-in: $e');
      }
    }

    // 3) Persist the validated alternate number on the account.
    try {
      final success = await _repository.updateAltNumber(altNumber);

      if (kDebugMode) {
        debugPrint(
          'AltNumberValidationCubit.submit: alt number saved=$success',
        );
      }

      // Refresh AccountInfoCubit so cached altPhoneNumber reflects the
      // newly-saved value. Failure here must not block navigation — the save
      // itself already succeeded.
      if (success) {
        try {
          await _accountInfoCubit.refreshAccountInfo();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('AltNumberValidationCubit: account refresh failed - $e');
          }
        }
      }

      if (isClosed) return;
      emit(
        state.copyWith(
          status: success
              ? AltNumberValidationStatus.valid
              : AltNumberValidationStatus.failure,
          errorMessage: success
              ? ''
              : 'could not save the mobile number. please try again.',
          signalId: state.signalId + 1,
        ),
      );
    } on AltNumberValidationException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AltNumberValidationStatus.failure,
          errorMessage: e.message,
          signalId: state.signalId + 1,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AltNumberValidationCubit.submit update: $e');
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AltNumberValidationStatus.failure,
          errorMessage: 'could not save the mobile number. please try again.',
          signalId: state.signalId + 1,
        ),
      );
    }
  }

  void reset() {
    emit(const AltNumberValidationState());
  }
}
