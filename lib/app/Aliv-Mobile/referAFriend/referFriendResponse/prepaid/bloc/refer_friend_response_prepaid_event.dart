import 'package:equatable/equatable.dart';

sealed class ReferFriendResponsePrepaidEvent extends Equatable {
  const ReferFriendResponsePrepaidEvent();

  @override
  List<Object?> get props => [];
}

class ReferFriendResponsePrepaidStarted extends ReferFriendResponsePrepaidEvent {
  const ReferFriendResponsePrepaidStarted();
}

class ReferFriendResponsePrepaidCopyPressed extends ReferFriendResponsePrepaidEvent {
  final String code;
  const ReferFriendResponsePrepaidCopyPressed(this.code);

  @override
  List<Object?> get props => [code];
}

class ReferFriendResponsePrepaidBackHomePressed extends ReferFriendResponsePrepaidEvent {
  const ReferFriendResponsePrepaidBackHomePressed();
}

class ReferFriendResponsePrepaidToastConsumed extends ReferFriendResponsePrepaidEvent {
  const ReferFriendResponsePrepaidToastConsumed();
}
