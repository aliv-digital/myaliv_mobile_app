import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/utils/login_phone_number_helper.dart';

import '../../../../../Home/balance/balance_injection.dart';
import '../../../../account-information/cubit/account_info_cubit.dart';
import '../repository/refer_friend_prepaid_repository.dart';
import '../utils/refer_friend_prepaid_email_helper.dart';
import 'refer_friend_prepaid_event.dart';
import 'refer_friend_prepaid_state.dart';

class ReferFriendPrepaidBloc
    extends Bloc<ReferFriendPrepaidEvent, ReferFriendPrepaidState> {
  final ReferFriendPrepaidRepository repository;
  final LoginPhoneNumberHelper phoneNumberHelper;
  final ReferFriendPrepaidEmailHelper emailHelper;

  ReferFriendPrepaidBloc({
    required this.repository,
    LoginPhoneNumberHelper? phoneNumberHelper,
    ReferFriendPrepaidEmailHelper? emailHelper,
  }) : phoneNumberHelper = phoneNumberHelper ?? const LoginPhoneNumberHelper(),
       emailHelper = emailHelper ?? const ReferFriendPrepaidEmailHelper(),
       super(const ReferFriendPrepaidState()) {
    on<ReferFriendPrepaidStarted>(_onStarted);
    on<ReferFriendPrepaidTabChanged>(_onTabChanged);

    on<ReferFriendPrepaidFriendPhoneChanged>(_onPhoneChanged);
    on<ReferFriendPrepaidCountryChanged>(_onCountryChanged);
    on<ReferFriendPrepaidFriendEmailChanged>(_onEmailChanged);
    on<ReferFriendPrepaidSharePressed>(_onSharePressed);

    on<ReferFriendPrepaidRedeemCodeChanged>(_onRedeemCodeChanged);
    on<ReferFriendPrepaidRedeemPressed>(_onRedeemPressed);

    on<ReferFriendPrepaidCopyPressed>(_onCopyPressed);

    on<ReferFriendPrepaidToastConsumed>(
      (e, emit) => emit(state.copyWith(toastMessage: null)),
    );
    on<ReferFriendPrepaidErrorConsumed>(
      (e, emit) => emit(state.copyWith(errorMessage: null)),
    );
  }

  Future<void> _onStarted(
    ReferFriendPrepaidStarted event,
    Emitter<ReferFriendPrepaidState> emit,
  ) async {
    final history = await repository.fetchHistory();
    emit(state.copyWith(history: history));
  }

  Future<void> _onTabChanged(
    ReferFriendPrepaidTabChanged event,
    Emitter<ReferFriendPrepaidState> emit,
  ) async {
    emit(state.copyWith(selectedTab: event.index));

    // load history on demand too (safe)
    if (event.index == 2 && state.history.isEmpty) {
      final history = await repository.fetchHistory();
      emit(state.copyWith(history: history));
    }
  }

  void _onPhoneChanged(
    ReferFriendPrepaidFriendPhoneChanged event,
    Emitter<ReferFriendPrepaidState> emit,
  ) {
    emit(
      state.copyWith(
        friendPhone: event.value,
        friendPhoneFieldError: false,
        errorMessage: null,
      ),
    );
  }

  void _onCountryChanged(
    ReferFriendPrepaidCountryChanged event,
    Emitter<ReferFriendPrepaidState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCountry: event.selectedCountry,
        friendPhoneFieldError: false,
        errorMessage: null,
      ),
    );
  }

  void _onEmailChanged(
    ReferFriendPrepaidFriendEmailChanged event,
    Emitter<ReferFriendPrepaidState> emit,
  ) {
    emit(
      state.copyWith(
        friendEmail: event.value,
        friendEmailFieldError: false,
        errorMessage: null,
      ),
    );
  }

  Future<void> _onSharePressed(
    ReferFriendPrepaidSharePressed event,
    Emitter<ReferFriendPrepaidState> emit,
  ) async {
    if (state.shareStatus == ReferFriendPrepaidSubmitStatus.submitting) {
      return;
    }

    final bool isPhoneMissing = state.friendPhone.trim().isEmpty;
    final bool isEmailMissing = state.friendEmail.trim().isEmpty;

    if (isPhoneMissing || isEmailMissing) {
      emit(
        state.copyWith(
          friendPhoneFieldError: isPhoneMissing,
          friendEmailFieldError: isEmailMissing,
          errorMessage: null,
        ),
      );
      return;
    }

    final LoginPhoneValidationResult phoneValidationResult = phoneNumberHelper
        .validateAndBuildApiUsername(
          rawPhoneNumber: state.friendPhone,
          selectedCountry: state.selectedCountry,
        );

    final bool hasInvalidPhone =
        !phoneValidationResult.isValid ||
        phoneValidationResult.phoneNumberForApi == null;
    final bool hasInvalidEmail = !emailHelper.isValid(state.friendEmail);

    if (hasInvalidPhone || hasInvalidEmail) {
      emit(
        state.copyWith(
          friendPhoneFieldError: hasInvalidPhone,
          friendEmailFieldError: hasInvalidEmail,
          errorMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        shareStatus: ReferFriendPrepaidSubmitStatus.submitting,
        errorMessage: null,
        toastMessage: null,
        friendPhoneFieldError: false,
        friendEmailFieldError: false,
      ),
    );

    try {
      final accountInfo = _readReferralAccountInfo();

      final isValidToRefer = await repository.isValidReferral(
        userPhoneNumber: phoneValidationResult.phoneNumberForApi!,
      );

      if (!isValidToRefer) {
        emit(
          state.copyWith(
            shareStatus: ReferFriendPrepaidSubmitStatus.failure,
            toastMessage: 'You are not valid to refer a friend.',
          ),
        );
        emit(state.copyWith(shareStatus: ReferFriendPrepaidSubmitStatus.idle));
        return;
      }

      final referralCode = await repository.postReferAFriend(
        deviceAccountID: accountInfo.deviceAccountId,
        referredNumber: phoneValidationResult.phoneNumberForApi!,
        email: state.friendEmail.trim(),
      );

      emit(
        state.copyWith(
          shareStatus: ReferFriendPrepaidSubmitStatus.success,
          referralCode: referralCode,
          shareSuccessRequestId: state.shareSuccessRequestId + 1,
          toastMessage: 'Referral sent!',
        ),
      );
      //REF0304EB30E38
      // back to idle for UI
      emit(state.copyWith(shareStatus: ReferFriendPrepaidSubmitStatus.idle));
    } catch (error) {
      emit(
        state.copyWith(
          shareStatus: ReferFriendPrepaidSubmitStatus.failure,
          errorMessage: _extractErrorMessage(error),
        ),
      );
      emit(state.copyWith(shareStatus: ReferFriendPrepaidSubmitStatus.idle));
    }
  }

  void _onRedeemCodeChanged(
    ReferFriendPrepaidRedeemCodeChanged event,
    Emitter<ReferFriendPrepaidState> emit,
  ) {
    emit(state.copyWith(redeemCode: event.value, errorMessage: null));
  }

  Future<void> _onRedeemPressed(
    ReferFriendPrepaidRedeemPressed event,
    Emitter<ReferFriendPrepaidState> emit,
  ) async {
    if (state.redeemStatus == ReferFriendPrepaidSubmitStatus.submitting) {
      return;
    }

    if (!state.canRedeem) {
      emit(
        state.copyWith(errorMessage: 'Please enter the full referral code.'),
      );
      return;
    }

    emit(
      state.copyWith(
        redeemStatus: ReferFriendPrepaidSubmitStatus.submitting,
        errorMessage: null,
        toastMessage: null,
      ),
    );

    try {
      final phoneValidationResult = phoneNumberHelper.validateAndBuildApiUsername(
        rawPhoneNumber: state.friendPhone,
        selectedCountry: state.selectedCountry,
      );

      if (!phoneValidationResult.isValid || phoneValidationResult.phoneNumberForApi == null) {
        throw const ReferFriendPrepaidException(
          'User phone number is invalid.',
        );
      }

      await repository.redeemReferral(
        code: state.redeemCode.trim(),
        referredNumber: phoneValidationResult.phoneNumberForApi!,
      );

      emit(
        state.copyWith(
          redeemCode: '',
          redeemStatus: ReferFriendPrepaidSubmitStatus.success,
          toastMessage:
              'success! you will receive bonus wallet credit via the myALIV app within 24 hours',
        ),
      );

      emit(state.copyWith(redeemStatus: ReferFriendPrepaidSubmitStatus.idle));
    } on ReferFriendPrepaidException catch (error) {
      emit(
        state.copyWith(
          redeemStatus: ReferFriendPrepaidSubmitStatus.failure,
          errorMessage: error.message,
        ),
      );
      emit(state.copyWith(redeemStatus: ReferFriendPrepaidSubmitStatus.idle));
    } catch (_) {
      emit(
        state.copyWith(
          redeemStatus: ReferFriendPrepaidSubmitStatus.failure,
          errorMessage: 'Could not redeem referral. Try again.',
        ),
      );
      emit(state.copyWith(redeemStatus: ReferFriendPrepaidSubmitStatus.idle));
    }
  }

  _ReferralAccountInfo _readReferralAccountInfo() {
    final accountInfoCubit = instance<AccountInfoCubit>();
    final account = accountInfoCubit.state.accountInfo;

    if (account == null) {
      throw Exception('Account information is not available.');
    }

    final deviceAccountId = account.idAcc.toString().trim();
    final phoneNumber = _firstNotEmpty([
      account.tNs.isNotEmpty ? account.tNs.first : '',
      account.primaryPhoneNumber,
      account.phoneNumber,
    ]);

    if (deviceAccountId.isEmpty || deviceAccountId == '0') {
      throw Exception('Device account ID is not available.');
    }

    if (phoneNumber.isEmpty) {
      throw Exception('User phone number is not available.');
    }

    debugPrint('phone number : $phoneNumber');

    return _ReferralAccountInfo(
      deviceAccountId: deviceAccountId,
      phoneNumber: phoneNumber,
    );
  }

  String _firstNotEmpty(List<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return '';
  }

  Future<void> _onCopyPressed(
    ReferFriendPrepaidCopyPressed event,
    Emitter<ReferFriendPrepaidState> emit,
  ) async {
    // UI handles Clipboard; here only toast
    emit(state.copyWith(toastMessage: 'Copied ${event.code}'));
  }

  String _extractErrorMessage(Object error) {
    if (error is ReferFriendPrepaidException) {
      return error.message;
    }

    final rawMessage = error.toString().trim();
    const String exceptionPrefix = 'Exception:';

    if (rawMessage.startsWith(exceptionPrefix)) {
      final String cleanedMessage = rawMessage
          .substring(exceptionPrefix.length)
          .trim();

      if (cleanedMessage.isNotEmpty) {
        return cleanedMessage;
      }
    }

    return rawMessage.isEmpty
        ? 'Failed to send referral. Try again.'
        : rawMessage;
  }
}

class _ReferralAccountInfo {
  final String deviceAccountId;
  final String phoneNumber;

  const _ReferralAccountInfo({
    required this.deviceAccountId,
    required this.phoneNumber,
  });
}
