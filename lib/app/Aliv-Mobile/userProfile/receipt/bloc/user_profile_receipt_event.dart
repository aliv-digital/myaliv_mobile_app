import 'package:equatable/equatable.dart';

import '../models/user_profile_receipt_route_args.dart';

sealed class UserProfileReceiptEvent extends Equatable {
  const UserProfileReceiptEvent();

  @override
  List<Object?> get props => [];
}

final class UserProfileReceiptStarted extends UserProfileReceiptEvent {
  final UserProfileReceiptRouteArgs args;

  const UserProfileReceiptStarted(this.args);

  @override
  List<Object?> get props => [args];
}

final class UserProfileReceiptBackHomePressed extends UserProfileReceiptEvent {
  const UserProfileReceiptBackHomePressed();
}
