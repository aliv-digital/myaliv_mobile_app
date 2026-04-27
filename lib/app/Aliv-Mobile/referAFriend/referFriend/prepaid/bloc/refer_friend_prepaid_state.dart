import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';

import '../models/refer_friend_prepaid_models.dart';

enum ReferFriendPrepaidSubmitStatus { idle, submitting, success, failure }

class ReferFriendPrepaidState extends Equatable {
  static const Object _noChange = Object();

  final int selectedTab;

  final String friendPhone;
  final String friendEmail;
  final LoginCountrySelection selectedCountry;
  final bool friendPhoneFieldError;
  final bool friendEmailFieldError;

  final String redeemCode;

  final ReferFriendPrepaidSubmitStatus shareStatus;
  final ReferFriendPrepaidSubmitStatus redeemStatus;
  final String referralCode;
  final int shareSuccessRequestId;

  final String? toastMessage;
  final String? errorMessage;

  final List<ReferralHistoryItem> history;

  const ReferFriendPrepaidState({
    this.selectedTab = 0,
    this.friendPhone = '',
    this.friendEmail = '',
    this.selectedCountry = LoginCountrySelection.defaultBahamas,
    this.friendPhoneFieldError = false,
    this.friendEmailFieldError = false,
    this.redeemCode = '',
    this.shareStatus = ReferFriendPrepaidSubmitStatus.idle,
    this.redeemStatus = ReferFriendPrepaidSubmitStatus.idle,
    this.referralCode = '',
    this.shareSuccessRequestId = 0,
    this.toastMessage,
    this.errorMessage,
    this.history = const [],
  });

  bool get canShare =>
      friendPhone.trim().isNotEmpty && friendEmail.trim().isNotEmpty;

  bool get canRedeem => redeemCode.trim().length >= 5;

  ReferFriendPrepaidState copyWith({
    int? selectedTab,
    String? friendPhone,
    String? friendEmail,
    LoginCountrySelection? selectedCountry,
    bool? friendPhoneFieldError,
    bool? friendEmailFieldError,
    String? redeemCode,
    ReferFriendPrepaidSubmitStatus? shareStatus,
    ReferFriendPrepaidSubmitStatus? redeemStatus,
    String? referralCode,
    int? shareSuccessRequestId,
    Object? toastMessage = _noChange,
    Object? errorMessage = _noChange,
    List<ReferralHistoryItem>? history,
  }) {
    return ReferFriendPrepaidState(
      selectedTab: selectedTab ?? this.selectedTab,
      friendPhone: friendPhone ?? this.friendPhone,
      friendEmail: friendEmail ?? this.friendEmail,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      friendPhoneFieldError:
          friendPhoneFieldError ?? this.friendPhoneFieldError,
      friendEmailFieldError:
          friendEmailFieldError ?? this.friendEmailFieldError,
      redeemCode: redeemCode ?? this.redeemCode,
      shareStatus: shareStatus ?? this.shareStatus,
      redeemStatus: redeemStatus ?? this.redeemStatus,
      referralCode: referralCode ?? this.referralCode,
      shareSuccessRequestId:
          shareSuccessRequestId ?? this.shareSuccessRequestId,
      toastMessage: identical(toastMessage, _noChange)
          ? this.toastMessage
          : toastMessage as String?,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
        selectedTab,
        friendPhone,
        friendEmail,
        selectedCountry,
        friendPhoneFieldError,
        friendEmailFieldError,
        redeemCode,
        shareStatus,
        redeemStatus,
        referralCode,
        shareSuccessRequestId,
        toastMessage,
        errorMessage,
        history,
      ];
}
