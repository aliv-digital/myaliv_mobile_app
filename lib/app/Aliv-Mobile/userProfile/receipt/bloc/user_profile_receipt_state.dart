import 'package:equatable/equatable.dart';

import '../models/user_profile_receipt_data.dart';

enum UserProfileReceiptStatus { initial, ready }

class UserProfileReceiptState extends Equatable {
  final UserProfileReceiptStatus status;
  final UserProfileReceiptData? data;
  final int backHomeRequestId;

  const UserProfileReceiptState({
    required this.status,
    required this.data,
    required this.backHomeRequestId,
  });

  factory UserProfileReceiptState.initial() {
    return const UserProfileReceiptState(
      status: UserProfileReceiptStatus.initial,
      data: null,
      backHomeRequestId: 0,
    );
  }

  UserProfileReceiptState copyWith({
    UserProfileReceiptStatus? status,
    UserProfileReceiptData? data,
    int? backHomeRequestId,
  }) {
    return UserProfileReceiptState(
      status: status ?? this.status,
      data: data ?? this.data,
      backHomeRequestId: backHomeRequestId ?? this.backHomeRequestId,
    );
  }

  @override
  List<Object?> get props => [status, data, backHomeRequestId];
}
