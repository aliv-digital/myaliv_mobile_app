import 'package:equatable/equatable.dart';
import '../model/profile_prepaid_models.dart';

sealed class ProfilePrepaidEvent extends Equatable {
  const ProfilePrepaidEvent();

  @override
  List<Object?> get props => [];
}

final class ProfilePrepaidStarted extends ProfilePrepaidEvent {
  const ProfilePrepaidStarted();
}

final class ProfilePrepaidBackPressed extends ProfilePrepaidEvent {
  const ProfilePrepaidBackPressed();
}

final class ProfilePrepaidItemPressed extends ProfilePrepaidEvent {
  final ProfileMenuItemModel item;
  const ProfilePrepaidItemPressed(this.item);

  @override
  List<Object?> get props => [item];
}
