import 'package:equatable/equatable.dart';

class ReferFriendResponsePrepaidState extends Equatable {
  final String referralCode;
  final String? toastMessage;

  const ReferFriendResponsePrepaidState({
    this.referralCode = '',
    this.toastMessage,
  });

  ReferFriendResponsePrepaidState copyWith({
    String? referralCode,
    String? toastMessage,
  }) {
    return ReferFriendResponsePrepaidState(
      referralCode: referralCode ?? this.referralCode,
      toastMessage: toastMessage,
    );
  }

  @override
  List<Object?> get props => [referralCode, toastMessage];
}
