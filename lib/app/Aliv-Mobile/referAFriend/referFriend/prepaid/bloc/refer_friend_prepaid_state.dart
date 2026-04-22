import 'package:equatable/equatable.dart';

import '../models/refer_friend_prepaid_models.dart';

enum ReferFriendPrepaidSubmitStatus { idle, submitting, success, failure }

class ReferFriendPrepaidState extends Equatable {
  final int selectedTab;

  final String friendPhone;
  final String friendEmail;

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
      friendPhone.trim().isNotEmpty &&
      friendEmail.trim().contains('@') &&
      friendEmail.trim().contains('.');

  bool get canRedeem => redeemCode.trim().length >= 5;

  ReferFriendPrepaidState copyWith({
    int? selectedTab,
    String? friendPhone,
    String? friendEmail,
    String? redeemCode,
    ReferFriendPrepaidSubmitStatus? shareStatus,
    ReferFriendPrepaidSubmitStatus? redeemStatus,
    String? referralCode,
    int? shareSuccessRequestId,
    String? toastMessage,
    String? errorMessage,
    List<ReferralHistoryItem>? history,
  }) {
    return ReferFriendPrepaidState(
      selectedTab: selectedTab ?? this.selectedTab,
      friendPhone: friendPhone ?? this.friendPhone,
      friendEmail: friendEmail ?? this.friendEmail,
      redeemCode: redeemCode ?? this.redeemCode,
      shareStatus: shareStatus ?? this.shareStatus,
      redeemStatus: redeemStatus ?? this.redeemStatus,
      referralCode: referralCode ?? this.referralCode,
      shareSuccessRequestId:
          shareSuccessRequestId ?? this.shareSuccessRequestId,
      toastMessage: toastMessage,
      errorMessage: errorMessage,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
        selectedTab,
        friendPhone,
        friendEmail,
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
